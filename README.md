# RFirefoxData

R tools that allow me to query information from my Firefox profile data.

+ open windows and tabs
+ pages visited
+ bookmarks

<!--
There are many other things we can programmatically extract and may add, e.g.,
+ downloads to be able to find the origin of a downloaded file.
-->

See also [RBrowserCookies](https://github.com/duncantl/RBrowserCookies.git) for reading cookies.

## Tabs

I tend to have a large number of tabs open - currently 347 across 37 windows, but that is better
than before. I used to have over 500 open persistently, growing to 750 at one point.

The functions `oldTabs()`, `tabInfo()` and `fxTabList()` provide information 
about tabs.

`oldTabs()` returns returns a data.frame with a row for each currently open tab.

+ title
+ url
+ lastAccessed
+ window
+ winNum  
+ tabNum

The title, URL and last accessed give us plenty of context.
The window  (the title of the window) and the window and tab number help us find the tab in the open
browser.


## Bookmarks

`bookmarkDF()` returns a data.frame describing the hierarchy of bookmarks, i.e., 
identify a bookmark and the folder it is in, etc.

It is useful for 
+ finding duplicates, 
+ finding ones that might be in the wrong folder

Each row in the data.frame corresponds to a bookmark.
We have the
+ title of the bookmark
+ URI
+ sequence of ancestor folders, as string separated by ";"
+ depth in the hierarchy of this bookmark.


## Visited sites

`places()` returns a data.frame with a row for each page visited.
There are 17 columns (not in order)
+ title  - title of the page that appears in the <title>
+ description - possible longer of description of the page
+ url   - the page's URL
+ visit_count - how many times we visited this
+ last_visit_date - the date and time (POSIXct) that we visited this page
+ host
+ typed
+ id
+ rev_host
+ hidden
+ frecency
+ guid
+ foreign_count
+ url_hash
+ preview_image_url
+ origin_id


(`site_name` is all NAs, at least in my database.)
