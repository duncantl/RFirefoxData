#include <nss/pk11sdr.h>
#include <nss/nss.h>
#include <Rdefines.h>

SEXP
R_decrypt(SEXP str, SEXP nels)
{
    SEXP ans;
    SECItem inp, out;
    
    PROTECT(ans = Rf_allocVector(STRSXP, Rf_length(str)));

    inp.type = 0;
    out.type = 0;
    for(unsigned int i = 0; i < Rf_length(str); i++) {
	inp.data = RAW(VECTOR_ELT(str, i)); // CHAR(STRING_ELT(str, i));
	inp.len = INTEGER(nels)[i];
        out.data = NULL;
        out.len = 0;	
	PK11SDR_Decrypt(&inp, &out, NULL);
	SET_STRING_ELT(ans, i, mkCharLen(out.data, out.len));
    }
    UNPROTECT(1);
    return(ans);
}


SEXP
R_NSS_Init(SEXP config)
{
    int val;
    val = NSS_Init(CHAR(STRING_ELT(config, 0)));
    return(ScalarInteger(val));
}
