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
   sapply(x$tabs, function(x) { i = x$index; structure(x$entries[[i]]$url, names = x$entries[[i]]$title) })
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
    
    structure(d[order(d$lastAccessed),], class = c("TimeOrderedTabs", "data.frame"))
}


print.TimeOrderedTabs =
function(x, ...)
{
    x = x[, 1:5]
    w = options()$width
    w1 = w2 = w*.8/2
    x[[1]] = substring(x[[1]], 1, w1)
    x[[5]] = substring(x[[5]], 1, w2)
    NextMethod("print")
}
