#' Reads a knowledge graph file as an igraph object.
#'
#' @param edgelist Text file containing the named edgelist.
#' @param nodes Text file containing the node names.
#' @param node_attrs Text file containing the node attributes.
#' @param cluster_args Named list with arguments for read_clusters. Used to append the clusters as vertex attributes.
#'
#' @return A igraph object.
#' @export
#' @examples
#' \dontrun{
#' read_KG(
#'  edgelist = 'data-raw/edgelists/2021/String_HPO_2021.phenotypic_branch.numbered.edgelist.txt',
#'  nodes = 'data-raw/edgelists/2021/String_HPO_2021.phenotypic_branch.nodenames.txt',
#'  node_attrs = 'data-raw/edgelists/2021/String_HPO_2021.phenotypic_branch.nodeattributes.txt'
#' )
#' }
read_KG <-
  function(edgelist,
           nodes,
           node_attrs,
           node_names,
           cluster_args = NULL) {
    el <-
      suppressMessages(suppressWarnings(readr::read_delim(
        edgelist, delim = '\t', col_names = FALSE
      )))
    cnames <- if (ncol(el) == 2) {
      cnames <- c('from', 'to')
    } else if (ncol(el) == 3) {
      cnames <- c('from', 'to', 'weight')
    } else if (ncol(el) > 3) {
      cnames <- c('from', 'to', 'weight')[colnames(el)[4:ncol(el)]]
    }

    el <- purrr::set_names(el, cnames)
    if (nrow(el) != nrow(dplyr::distinct(el))) {
      stop('Multi-edges exist.')
    }
    if (any(el[, 1] == el[, 2])) {
      stop('Self-loops exist.')
    }

    nattr <- suppressMessages(suppressWarnings(
      node_attrs %>%
        readr::read_delim(., delim = '\t', col_names = FALSE) %>%
        purrr::set_names(., c('nodeID', 'gene'))
    ))

    nl <- suppressMessages(
      suppressWarnings(
        nodes %>%
          readr::read_delim(., delim = '\t', col_names = FALSE) %>%
          purrr::set_names(., c('nodeID', 'name')) %>%
          dplyr::left_join(., nattr, by = 'nodeID') %>%
          dplyr::select(., dplyr::any_of(c('nodeID', 'name')), dplyr::everything())
      )
    )

    if (!is.null(cluster_args)) {
      comms <-
        read_clusters(
          path = cluster_args$path,
          pattern = cluster_args$pattern,
          recursive = cluster_args$recursive,
          names = TRUE,
          long = TRUE
        )
      nl <- nl %>%
        dplyr::left_join(., comms, by = 'nodeID') %>%
        dplyr::distinct(., .keep_all = TRUE) %>%
        dplyr::group_by(., method, clusterID) %>%
        dplyr::mutate(., coi = ifelse(any(gene == 0) &
                                        any(gene == 1) &
                                        n() >= 3, 1, 0)) %>%
        dplyr::ungroup() %>%
        dplyr::arrange(., node, method, clusterID) %>%
        dplyr::mutate(.,
                      nodeID2 = nodeID,
                      node2 = node,
                      gene2 = gene) %>%
        tidyr::nest(., clusters = c(nodeID, node, gene, method, clusterID, coi)) %>%
        dplyr::rename(.,
                      nodeID = nodeID2,
                      node = node2,
                      gene = gene2) %>%
        dplyr::select(., nodeID, node, gene, dplyr::everything())
    } else{
      nl <- nl %>%
        dplyr::mutate(., node = nodeID) %>%
        dplyr::select(., nodeID, node, gene, dplyr::everything())
    }

    G <-
      igraph::graph_from_data_frame(d = el,
                                    vertices = nl,
                                    directed = FALSE)

    # add attributes
    is_gene <- igraph::vertex_attr(G, name = 'gene')
    G <- igraph::set_vertex_attr(G, name = 'color',
                                 value = ifelse(is_gene == '1', '#FFC000', '#7CDDEE'))
    # write edge type
    el <- as.data.frame(igraph::as_edgelist(G))
    v1_phe <- stringr::str_sub(el$V1, 1, 3) == 'HP:'
    v2_phe <- stringr::str_sub(el$V2, 1, 3) == 'HP:'
    etype <- dplyr::case_when(
      v1_phe & v2_phe ~ 'P2P',
      !v1_phe & !v2_phe ~ 'G2G',
      TRUE ~ 'G2P'
    )
    G <- igraph::set_edge_attr(G, name = 'type', value = etype)

    return(G)
  }
