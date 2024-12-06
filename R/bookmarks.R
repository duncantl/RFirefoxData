ProfileDir = "~/Library/Application Support/Firefox/Profiles/qszunwne.default"

bookmarks =
function(file = mostRecent(".*", dir = dir),
         dir = file.path(ProfileDir, "bookmarkbackups"))
{
   structure(readJSONlz4(file), class = "Bookmarks")
}

bookmarkURLs =
function(b = bookmarks())
{
    ans = character()
    if("uri" %in% names(b))
        ans = c(ans, structure(b$uri, names = b$title))

    tmp = lapply(b$children, bookmarkURLs)
    c(ans, unlist(tmp, use.names = TRUE))
}

bookmarkDF =
function(b = bookmarks(), ancestor = "", depth = 0)
{
    ans = data.frame(title = b$title, uri = valOrNA(b$uri), ancestors = ancestor, depth = depth,
                     id = b$id,
                     index = valOrNA(b$index), dateAdded = b$dateAdded, lastModified = valOrNA(b$lastModified))
    ancestor = paste(c(ancestor, b$title), collapse = ";")
    tmp = lapply(b$children, bookmarkDF, ancestor, depth + 1L)
    ans = rbind(ans, do.call(rbind, tmp))

    if(depth == 0) {
        v = c("dateAdded", "lastModified")
        ans[ v ] = lapply( ans[v], function(x) structure(x/1000000, class = c("POSIXct", "POSIXt")))
    }
            
    ans
}

valOrNA =
function(x)
  if(is.null(x)) NA else x
