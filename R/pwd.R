# firefox_decrypt from https://github.com/unode/firefox_decrypt.git
# 

if(FALSE) {
getPasswords =
function(firefox_decrypt = path.expand("~/Downloads/firefox_decrypt/firefox_decrypt.py"))
{
    # Can't set DYLD_LIBRARY_PATH after process has started.
#    prev = Sys.getenv("DYLD_LIBRARY_PATH")
#    on.exit(Sys.setenv(DYLD_LIBRARY_PATH = prev))
#    Sys.setenv(DYLD_LIBRARY_PATH = "/Applications/Firefox Developer Edition.app/Contents/MacOS")
#browser()
    #    txt = system2("python3", c(path.expand("~/Downloads/firefox_decrypt/firefox_decrypt.py"), "--format", "csv"))

    cmd = sprintf("export DYLD_LIBRARY_PATH='/Applications/Firefox Developer Edition.app/Contents/MacOS'; python3 %s --format csv -n --choice=4", firefox_decrypt)
    txt = system(cmd, intern = TRUE)    
    ans = structure(read.csv(textConnection(txt), sep = ";"), class = c("FirefoxPasswords", "data.frame"))
    class(ans[[3]]) = "Passwords"
    ans
}

`[.FirefoxPasswords` =
    # use partial matching of the host name, and not just the beginning.
    # e.g., x["ucdavis", ]  will match www.ucdavis.edu, etc.
function(x, i, j, hide = TRUE, ...) 
{
    if(!hide || missing(i) || is.numeric(i) || is.logical(i))
        ans = NextMethod()
    else {
        rows = grep(i, x[[1]])
        ans = base::`[`(x, rows, j, ...)
    }

    if(is.data.frame(ans) &&  "password" %in% names(ans))
        class(ans) = "FirefoxPasswords"

    ans
}

} # end if(FALSE)



print.Passwords =
function(x, hide = TRUE, ...)
{
    if(hide)
        print(rep("XXX", length(x)), ...)
    else
        NextMethod()
}



print.FirefoxPasswords =
    # Don't print the password.
function(x, ...)
{
    x[, "password"] = "XXX"
    NextMethod()
}



############################

getPasswords = readPasswords =
    # From JSON.
function(profile = getProfile(), decrypt = TRUE, full = FALSE)    
{
    if(!file.exists(profile))
       profile = getProfile(profile)

    f = file.path(profile, "logins.json")
    if(!file.exists(f))
        stop("no logins.json file for profile ", basename(profile))

    info = RJSONIO::fromJSON(f)
    logins = info$logins

    if(full) {
        ans = exRbind(lapply(logins, objToDF))
        v = c("timeCreated", "timeLastUsed", "timePasswordChanged")
        ans[v] = lapply(ans[v], function(x) structure(x/1000, class = c("POSIXct", "POSIXt")))
    } else {
        v = c("hostname", "encryptedUsername", "encryptedPassword")
        ans = as.data.frame(lapply(v, function(v) sapply(logins, `[[`, v)))
        names(ans) = v
    }

    if(decrypt) {
        ans$password = structure(decryptString(ans$encryptedPassword, profile), class = "Passwords")
        ans$login = decryptString(ans$encryptedUsername, profile)
        ans = ans[ !( names(ans) %in% c( "encryptedUsername", "encryptedPassword")) ]
        class(ans) = c("FirefoxPasswords", class(ans))
    }
    
    ans
}





