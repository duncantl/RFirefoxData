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

readPasswords =
    # From JSON.
function(profile = getProfile(), decrypt = TRUE)    
{
    if(!file.exists(profile))
       profile = getProfile(profile)

    f = file.path(profile, "logins.json")
    if(!file.exists(f))
        stop("no logins.json file for profile ", basename(profile))

    info = RJSONIO::fromJSON(f)
    logins = info$logins

    v = c("hostname", "encryptedUsername", "encryptedPassword")
    ans = as.data.frame(lapply(v, function(v) sapply(logins, `[[`, v)))
    names(ans) = c("host", "login", "password")

    if(decrypt) {
        ans$password = structure(decryptString(ans$password, profile), class = "Passwords")
        class(ans) = c("FirefoxPasswords", class(ans))
    }
    
    
    
    ans
}

getProfile =
function(id = getOption("FirefoxProfile", NA), base = "~/Library/Application Support/Firefox/Profiles")
{
    ff = listProfiles(base)

    if(!is.na(id))
       return(if(length(i <- grep(id, basename(ff)))) ff[i] else NA)
    
    info = file.info(ff)
    info = info[info$isdir,]
    rownames(info)[ which.max(info$atime) ]
}

listProfiles =
function(base = "~/Library/Application Support/Firefox/Profiles", full = FALSE)
{
    ans = list.files(base, full.names = TRUE)
    if(!full)
        return(ans)
    

    ini = readINI(file.path(base, "profiles.ini"), ans)
    mergePaths(ini, ans)
}

readINI =
function(f)    
{
    ll = readLines(f)
    w = grepl("^\\[", ll)

    z = lapply(split(ll, cumsum(w)), mkProfileInfo)
    exRbind(z)
}

exRbind =
function(x)
{
    vars = unique(unlist(lapply(x, names)))

    tmp = lapply(x, function(x)  {
                       m = setdiff(vars, names(x))
                       if(length(m))
                          x[m] = NA
                       x
                   })
    do.call(rbind, tmp)
}


mkProfileInfo =
function(x)
{
    x = trimws(x)
    x = x [ x != "" ]
    els = strsplit(x[-1], "=")

    vals = sapply(els, `[`, 2)
    ans = as.data.frame(as.list(vals))
    names(ans) = sapply(els, `[`, 1)
    ans$label = gsub("^\\[|\\]$", "", x[1])
    ans
}
