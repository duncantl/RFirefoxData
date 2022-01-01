# https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwj32Zvqg4_1AhWKAp0JHZKOACcQFnoECAQQAQ&url=https%3A%2F%2Fwiki.mozilla.org%2Fimages%2Fd%2Fd5%2FPlaces.sqlite.schema3.pdf&usg=AOvVaw1gOr8Z8MxpGrIVNVbAJyWy
# https://tableplus.com/blog/2018/07/sqlite-how-to-use-datetime-value.html

places =
function(file = file.path(ProfileDir, "places.sqlite"), con = connectPlaces(file))
{
    ans = dbGetQuery(con, "SELECT * from moz_places")
    #  slow(er) but no need to depend on another package for a single function.
    ans$host = substring(sapply(strsplit(ans$rev_host, ""), function(x) paste(rev(x), collapse = "")), 2)

    timestamp = dbGetQuery(con, "SELECT datetime(last_visit_date/1000000, 'unixepoch', 'localtime') FROM moz_places")[[1]]
    ans$last_visit_date = as.POSIXct(strptime(timestamp, "%Y-%m-%d %H:%M:%S"))
    ans
}

connectPlaces =
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
                         reg.finalizer(con@Id, function(obj)  file.remove(file2) )
                         con
                     })
}
