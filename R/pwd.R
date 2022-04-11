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
function(x, i, j, ...) 
{
    if(missing(i) || is.numeric(i) || is.logical(i))
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

readPasswords =
    # From JSON.
function(profile = getProfile(), decrypt = TRUE)    
{
    f = file.path(profile, "logins.json")
    if(!file.exists(f))
        stop("no logins.json file for profile ", basename(profile))

    info = RJSONIO::fromJSON(f)
    logins = info$logins

    v = c("hostname", "encryptedUsername", "encryptedPassword")
    ans = as.data.frame(lapply(v, function(v) sapply(logins, `[[`, v)))
    names(ans) = c("host", "login", "password")

    if(decrypt) {
        ans$password = structure(decryptString(ans$password), class = "Passwords")
        class(ans) = c("FirefoxPasswords", class(ans))
    }
    
    
    
    ans
}

getProfile =
function(base = "~/Library/Application Support/Firefox/Profiles")
{
    ff = list.files(base, full = TRUE)
    info = file.info(ff)
    info = info[info$isdir,]
    rownames(info)[ which.max(info$atime) ]
}
