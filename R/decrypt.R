NSSState = new.env()
NSSState$initialized = FALSE

decryptString =
function(str)
{
    if(!NSSState$initialized)
        if(.Call("R_NSS_Init", paste0("sql:", getProfile())) != 0)
            stop("Failed to initialize NSS3 correctly")

    if(is.character(str)) {
        data = lapply(str, base64decode)
    } else if(is.list(str))
        data = str
    else
        stop("Don't understand ", typeof(str), " as input")

    .Call("R_decrypt", data, sapply(data, length))
}
