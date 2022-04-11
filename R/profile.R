getProfile =
function(id = getOption("FirefoxProfile", NA), base = "~/Library/Application Support/Firefox/Profiles")
{
    if(!is.na(id)) {
        ff = list.files(base, full = TRUE)
        return(if(length(i <- grep(id, basename(ff)))) ff[i] else NA)
    }

    ff = listProfiles(dirname(base), full = TRUE)    

    ff2 = ff[ff$Default, ]
    i = !is.na(ff2$Name) & ff2$Name == "default"
    if(any(i) && sum(i) == 1) 
        return(ff2$dir[i])

    info = file.info(ff2$dir)
    info = info[info$isdir,]
    rownames(info)[ which.max(info$atime) ]
}

listProfiles =
function(base = "~/Library/Application Support/Firefox", full = FALSE)
{
    ans = list.files(file.path(base, "Profiles"),  full.names = TRUE)
    if(!full)
        return(ans)
    
    ini = readINI(file.path(base, "profiles.ini"))
    ans = mergePaths(ini, ans, base)

    lvars = c("Default", "Locked", "IsRelative", "StartWithLastProfile")
    ans[lvars] = lapply(ans[lvars], function(x) !is.na(x))

    ivars = c("Version")
    ans[ivars] = lapply(ans[ivars], as.integer)
    
    ans
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

objToDF =
function(x)    
{
    w = sapply(x, length) == 0
    x[w] = NA
    as.data.frame(x)
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


mergePaths =
function(df, files, base)
{
    m = match(basename(df$Path), basename(files))
    df$dir[!is.na(m)] = files[m [ !is.na(m)] ]
    df
}
