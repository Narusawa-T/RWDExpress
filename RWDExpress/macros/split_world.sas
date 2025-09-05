/*** HELP START ***//*

`%split_world` is a macro which allow user to split the large dataset in to small piecies. so that user can process one by one.

### Parameters
 - `inlib`  :  libname where target dataset are located.
 - `indata` :  target dataset e.g: act
 - `outlib(defaul to work)` :  libname split datasets (e.g: act001,act002...) to be stored
nperBlock : the number of records split dataset will have in one dataset
 - `blockstart(defaul to 1)` : the start of block. It starts from the first block if not specified.
 - `blockend` : the end of blok, if not specified, it ends with the last block if not specified.
### Sample code

Split disease dataset in rwd into small datasets with 100000 observations.

~~~sas
%split_world(inlib=rwd, indata=disease, nperBlock=100000);
~~~

Split disease dataset in rwd into small datasets with 100000 observations.
You can specify which datasets you want and store them in the library split.
~~~sas
* from 3rd dataset to 5th datasets;
%split_world(inlib=rwd, indata=d02_actdata, outlib=split, nperBlock=100000, blockstart=3, blockend=5);
* from 6th to the end;
%split_world(inlib=rwd, indata=d02_actdata, outlib=split, nperBlock=100000, blockstart=6);

~~~
`%split_world` is a macro 

### Parameters
 - `inlib`  :  libname where target dataset are located.
 - `indata` :  target dataset e.g: act
 - `outlib(defaul to work)` :  libname split datasets (e.g: act001,act002...) to be stored
nperBlock : the number of records split dataset will have in one dataset
 - `blockstart(defaul to 1)` : the start of block. It starts from the first block if not specified.
 - `blockend` : the end of blok, if not specified, it ends with the last block if not specified.
### Sample code

Split disease dataset in rwd into small datasets with 100000 observations.

~~~sas
%split_world(inlib=rwd, indata=disease, nperBlock=100000);
~~~

Split disease dataset in rwd into small datasets with 100000 observations.
You can specify which datasets you want and store them in the library split.
~~~sas
* from 3rd dataset to 5th datasets;
%split_world(inlib=rwd, indata=d02_actdata, outlib=split, nperBlock=100000, blockstart=3, blockend=5);
* from 6th to the end;
%split_world(inlib=rwd, indata=d02_actdata, outlib=split, nperBlock=100000, blockstart=6);

~~~


### Note:

---

*//*** HELP END ***/

/*=======================================================================*/
/* inlib  :  libname where target dataset are located. */
/* indata :  target dataset e.g: act*/
/* outlib(defaul to work) :  libname split datasets (e.g: act001,act002...) to be stored*/
/* nperBlock : the number of records split dataset will have in one dataset*/
/* blockstart(defaul to 1) : the start of block. It starts from the first block if not specified.*/
/* blockend : the end of blok, if not specified, it ends with the last block if not specified.*/
/*=======================================================================*/

%macro split_world(inlib=, indata=, outlib=WORK, nperBlock=, blockstart=1, blockend=);
	
	 %local nobs nBlock digit;
	  data _null_;
	    if 0 then set &inlib..&indata nobs=n;
	    call symputx('nobs', n);
	  run;
	  %let nBlock = %sysevalf(%sysfunc(ceil(%sysevalf(&nobs / &nperBlock))), CEIL);
	  %let digit = %length(%sysfunc(strip(&nBlock)));	  
	  
	  %local start end block;
	  %let block = %eval(&blockstart);   
	  %let start = %eval((&block - 1) * &nperBlock + 1);
	  
	  %if &blockend. = %str() %then %let blockend =  &nBlock.; 

	  %do %while((&start <= &nobs) &  (&block. <= &blockend.));
	    %let end = %eval(&start + &nperBlock - 1);
	    %if &end > &nobs %then %let end = &nobs;

	    data &outlib..&indata.%sysfunc(putn(&block, z&digit..));
	      set  &inlib..&indata(firstobs=&start obs=&end);
	    run;

	    %let start = %eval(&start + &nperBlock);
	    %let block = %eval(&block + 1);
	  %end;
%mend;
