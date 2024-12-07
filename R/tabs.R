if(FALSE) {
    tabs = fxTabList()
    byWin = tabInfo(tabs)
    byWin

    oldTabs(tabs)

    oldTabs() # gets the very current data so windows and tabs match what is being displayed in Firefox.
}


fxTabList =
function(file = '/Users/duncan/Library/Application Support/Firefox/Profiles/qszunwne.default/sessionstore-backups/recovery.jsonlz4')
{    
    rw = readJSONlz4(file)
    structure(rw, class = "FXSessionInfo")
}

readJSONlz4 =
function(file)    
  RJSONIO::fromJSON( system(sprintf("lz4jsoncat '%s'", path.expand(file)), intern = TRUE))

tabInfo =  # by window
function(x = fxTabList(), combine = TRUE)    
{
    ans = lapply(x$windows, winTabInfo)
    names(ans) = mapply(function(x, w)  names(x)[w$selected], ans, x$windows)
    ans
}


winTabInfo =  # helper functon for tabInfo
function(x)
{
    sapply(x$tabs, function(t) {
                          i = t$index
                          if(i <= length(t$entries)) {
                              e = t$entries[[i]]
                              if(is.list(e))
                                  structure(e$url, names = e$title)
                              else
                                  structure(e["url"], names = e["title"])                                  
                          } else
                              structure(NA, names = NA)
                })
}



oldTabs =
function(tabs = fxTabList(), info = tabInfo(tabs))
{
    la = sapply(tabs$windows, function(w) structure(sapply(w$tabs, `[[`, "lastAccessed")/1000, class = c("POSIXt", "POSIXct")))

    d = data.frame(title = unlist(lapply(info, names)),
                   winNum = rep(seq(along.with = info), sapply(info, length)),
                   tabNum = unlist(lapply(la, function(x) seq_len(length(x)))),
                   lastAccessed = structure(unlist(la), class = c("POSIXt", "POSIXct")),
                   window = rep(names(info), sapply(info, length)),
                   url = unlist(info)
        )
    rownames(d) = NULL

    if(require(XML))
        d$host = sapply(d$url, function(x) tryCatch(parseURI(x)$server, error  = function(...) NA))
    
    structure(d[order(d$lastAccessed),], class = c("TimeOrderedTabs", "data.frame"))
}


print.TimeOrderedTabs =
function(x, pct = .7, ...)
{
    x = x[, 1:5]
    w = options()$width
    w1 = w2 = w*pct/2
    x[[1]] = substring(x[[1]], 1, w1)
    x[[5]] = substring(x[[5]], 1, w2)
    NextMethod("print")
}

dupTabs =
function(tabs)
{
    w = duplicated(tabs$url)
    if(!any(w))
        return(list())
    
    tb2 = tabs[ tabs$url %in% tabs$url[w], ]
    split(tb2, tb2$url)
}


windows =
    # Get the names of the windows and the corresponding number.
    # Currently a data.frame with 2 columns.
    # Could be a character vector with the window numbers being implicit.
    # Or an integer vector with names being the window titles/labels.
function(tdf)
{
    id = tapply(tdf, tdf$winNum, function(x) x$window)
    data.frame(winNum = as.integer(names(id)),
               name = as.character(id))
}
