#ifdef HAVE_NSS

#if 0
#include <nss/pk11sdr.h>
#include <nss/nss.h>
#else
#include <pk11sdr.h>
#include <nss.h>
#endif

#include <Rdefines.h>

SEXP
R_decrypt(SEXP str, SEXP nels)
{
    SEXP ans;
    SECItem inp, out;
    SECStatus status;
	
    PROTECT(ans = Rf_allocVector(STRSXP, Rf_length(str)));

    inp.type = 0;
    out.type = 0;
    for(unsigned int i = 0; i < Rf_length(str); i++) {
	inp.data = RAW(VECTOR_ELT(str, i)); // CHAR(STRING_ELT(str, i));
	inp.len = INTEGER(nels)[i];
        out.data = NULL;
        out.len = 0;	
	status = PK11SDR_Decrypt(&inp, &out, NULL);
	SET_STRING_ELT(ans, i, status == SECSuccess ? mkCharLen(out.data, out.len) : R_NaString);
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

#else

#include <Rdefines.h>

#ifndef PROBLEM

#define R_PROBLEM_BUFSIZE	4096
#define PROBLEM			{char R_problem_buf[R_PROBLEM_BUFSIZE];(snprintf)(R_problem_buf, R_PROBLEM_BUFSIZE,
#define ERROR			),Rf_error(R_problem_buf);}
#define WARNING(x)		),Rf_warning(R_problem_buf);}
#define WARN			WARNING(NULL)

#endif


SEXP
R_decrypt(SEXP str, SEXP nels)
{
    PROBLEM "NSS_Init is not available"
	ERROR;
}


SEXP
R_NSS_Init(SEXP config)
{
    PROBLEM "NSS_Init is not available"
	ERROR;
}
#endif
