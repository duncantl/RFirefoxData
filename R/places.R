# https://gist.github.com/olejorgenb/9418bef65c65cd1f489557cfc08dde96


# datetime fields, e.g., last_visit_date.
# https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwj32Zvqg4_1AhWKAp0JHZKOACcQFnoECAQQAQ&url=https%3A%2F%2Fwiki.mozilla.org%2Fimages%2Fd%2Fd5%2FPlaces.sqlite.schema3.pdf&usg=AOvVaw1gOr8Z8MxpGrIVNVbAJyWy
# https://tableplus.com/blog/2018/07/sqlite-how-to-use-datetime-value.html




places =
function(file = file.path(ProfileDir, "places.sqlite"), con = connectPlaces(file))
{
    ans = dbGetQuery(con, "SELECT * from moz_places")
    #  slow(er) but no need to depend on another package for a single function.
    ans$host = substring(sapply(strsplit(ans$rev_host, ""), function(x) paste(rev(x), collapse = "")), 2)

    # could do this in the query above and have only one query. See downloads below.
    timestamp = dbGetQuery(con, "SELECT datetime(last_visit_date/1000000, 'unixepoch', 'localtime') FROM moz_places")[[1]]
    ans$last_visit_date = mkTimestamp(timestamp)
    ans
}

connectPlaces = conPlacesDB =
    #
    #  connect to the database, copying it to tempdir() if the database is locked.
    #
function(file = file.path(ProfileDir, "places.sqlite"),
         driver = SQLite(...), ...)
{
    # dbConnect doesn't throw an error if the database is locked; it is only
    # a query that throws the error.
    # However, dbConnect() does show the error but just doesn't throw it!
    con = tryCatch( { con = dbConnect(driver, file)
                      dbListTables(con);
                      con
                     },
                     error = function(e) {
                         if(!grepl("locked", e$message))
                             stop(e)

                         file2 = file.path(tempdir(), "places.sqlite")
                         file.copy(file, file2)
                         # remove it when finished with it.
                         con = dbConnect(driver, file2)
                         # RSQLite will close the connection but we need to remove
                         # the file we copied.
                         reg.finalizer(con@ptr, function(obj)  file.remove(file2) )
                         con
                     })
}


downloads = 
function(file = file.path(ProfileDir, "places.sqlite"), con = connectPlaces(file))
{
   annos = dbGetQuery(con, "SELECT *, 
                            datetime(A.dateAdded/1000000, 'unixepoch', 'localtime') AS DateAdded,
                            datetime(A.lastModified/1000000, 'unixepoch', 'localtime') AS LastModified
                            FROM moz_annos AS A, moz_places AS P WHERE A.place_id = P.id")
   
#                            datetime(A.expiration/1000000, 'unixepoch', 'localtime') AS Expiration

   tmVars = c("DateAdded", "LastModified") # , "Expiration")
   annos[tolowerFirst(tmVars)] = lapply(annos[tmVars], mkTimestamp)
   annos[, !(names(annos) %in% tmVars)] 
}


mkTimestamp =
function(tm)
    as.POSIXct(strptime(tm, "%Y-%m-%d %H:%M:%S"))

tolowerFirst =
function(x)
  paste0(tolower(substring(x, 1, 1)), substring(x, 2))        



visits =
function(file = file.path(ProfileDir, "places.sqlite"), con = connectPlaces(file))
{
    ans = dbGetQuery(con, "SELECT *,
                                datetime( visit_date/1000000, 'unixepoch', 'localtime') AS visit_date,
                                datetime( last_visit_date/1000000, 'unixepoch', 'localtime') AS last_visit_date
                                   FROM moz_historyvisits AS V,
                                        moz_places AS P
                                   WHERE P.id = V.place_id")

    tmVars = c("visit_date", "last_visit_date")
    ans = ans[ , - match(tmVars, names(ans))]
    ans[tmVars] = lapply(ans[tmVars], mkTimestamp)
    
    ans$visit_type = factor(names(TransitionTypes)[match(ans$visit_type, TransitionTypes)])
    
    ans
}



# From https://searchfox.org/mozilla-esr60/source/toolkit/components/places/nsINavHistoryService.idl#1185
#  as pointed to by https://gist.github.com/olejorgenb/9418bef65c65cd1f489557cfc08dde96

TransitionTypes =
c(LINK = 1,
TYPED = 2,
BOOKMARK = 3,
EMBED = 4,
REDIRECT_PERMANENT = 5,
REDIRECT_TEMPORARY = 6,
DOWNLOAD = 7,
FRAMED_LINK = 8,
RELOAD = 9)
