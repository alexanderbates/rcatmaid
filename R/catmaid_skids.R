#' Find skeleton ids (skids) for various inputs including textual queries
#' 
#' An efficient way to find neuron skeleton ids interactively or in any function
#' that can take skids as an input.
#' 
#' @details If the inputs are numeric or have length > 1 they are assumed 
#'   already to be skids and are simply converted to integers. If the the input 
#'   is a string starting with "name:" or "annotation:" they are used for a 
#'   query by catmaid_query_by_annotation or 
#'   \code{\link{catmaid_query_by_annotation}}, respectively.
#'   
#' @param x one or more skids or a query expression (see details)
#' @param several.ok Logical indicating whether we can allow multiple skids.
#' @param ... additional parameters passed to \code{catmaid_query_by_annotation}
#' @inheritParams catmaid_fetch
#' @return \code{integer} vector of skids (of length 0 on failure).
#' @export
#' @importFrom jsonlite rbind.pages
#' @examples 
#' \dontrun{
#' # these are just passed through
#' catmaid_skids(1:10)
#' 
#' # nb these are all regex matches
#' catmaid_skids("name:ORN")
#' catmaid_skids("name:PN")
#' # there will be multiple annotations that match this
#' catmaid_skids("annotation:ORN")
#' # but only one that matches this (see regex for details)
#' catmaid_skids("annotation:^ORN$")
#' }
catmaid_skids<-function(x, several.ok=TRUE, conn=NULL, ...) {
  if(is.factor(x)) {
    x=as.character(x)
  }
  skids=integer()
  if(is.numeric(x)) {
    skids= as.integer(x)
  } else if(length(x) > 1) {
    intx=as.integer(x)
    if(all(is.finite(intx))) {
      skids=intx
    } else stop("Multiple values provided but they do not look like skids!")
  } else {
    # just one value provided
    intx=suppressWarnings(as.integer(x))
    if(is.finite(intx)) {
      return(intx)
    } else if(substr(x,1,5)=="name:") {
      # query by name
      df=catmaid_query_by_name(substr(x, 6, nchar(x)), type = 'neuron', conn=conn, ...)
    } else if(substr(x,1,11)=="annotation:") {
      # query by annotation
      df=catmaid_query_by_annotation(substr(x, 12, nchar(x)), type = 'neuron', conn=conn, ...)
    } else {
      stop("Unrecognised skid specification!")
    }
    if(is.null(df)) warning("No matches for query ",x,"!")
    else {
      # handle multiple returned data.frames
      if(!is.data.frame(df)) df=rbind.pages(df)
      skids = df$skid
    }
  }
  if(!several.ok && length(skids)>1) 
    stop("Only expecting one skid but I have: ", length(x), "!")
  skids
}
