# RFirefoxData

R tools that allow me to query information from my Firefox profile data.

These include 

+ open windows and tabs
+ pages visited
+ bookmarks
+ downloads
+ visit path
+ query passwords by host (and decrypt them)

and general access to the places.sqlite database.

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

`places()` returns a data.frame with a row for each page visited in the browser history.

This can be useful to find, for example, 
+ all stackoverflow pages one has visited and by date. This can help find pages you recall, but
  don't fully remember and need to find.
+ what pages you visit most ofen
+ 


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


## Downloads

`downloads()` allows us to find out when we downloaded a file and from where,
and the collection of files from a particular site.

`downloads()` returns a data.frame with 25 columns, joining
the `moz_annos` table with the `moz_places` table in the `places.sqlite` database.

+ content
+ type
+ url
+ title
+ description



## Connecting Places & Visits

`visits()` joins the moz_historyvisits and moz_places table.
This allows us to 
+ find the path we took to a particular page and the type of "hops" we took, e.g., following a link,
  a bookmark, a download, a reload
+ when we visited pages



## Accessing the places.sqlite Database

```
db = conPlacesDB()
dbListTable(db)
```


## Profiles

`getProfile()` returns the full path to the unique default profile, or the most recently used
default profile.

If you want a different profile, you can specify the uniquely identifying
string  for that profile, e.g., 
`getProfile("qs")` or `getProfile("^qs")` or `getProfile("Protected")`.

You set the profile identified as an option with, e.g.,
```r
options(FirefoxProfile = "^qs")
```


`listProfiles(, TRUE)` lists all of the profiles.
It returns a data.frame describing each profile.
This includes 
+ the Name, 
+ the directory
+ whether this is a default profile
+ the label
+ the version of the profile
+ whether it is locked oor not
+ whether StartWithLastProfile is TRUE or FALSE



## Passwords

`readPasswords()` gets the passwords for the specified profile.
By default, this returns a data.frame containing 
+ host
+ password
+ login/user name

By default, the password is decrypted, but will print as XXX.
The actual decrypted value(s) can be accessed directly
to use as inputs to calls or to view.

We can also get all of the information for each login-password pair with
```r
readPasswords(full = TRUE)
```
For each login-password, the resulting data.frame  includes the associated 
+ host
+ password
+ login
+ times the login was created, changed, last used
+ number of times used
+ URL for the form and corresponding fields in the HTML form






## References

+ See https://medium.com/geekculture/how-to-hack-firefox-passwords-with-python-a394abf18016
for information about the steps for accessing and decrypting the passwords.

+ [firefox_decrypt](https://github.com/unode/firefox_decrypt.git) is a Python application/program to access Firefox passwords 
  for any of the profiles. 
  
