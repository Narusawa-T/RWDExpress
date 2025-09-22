/*** HELP START ***//*

`%small_world` is a macro to extract data with subjects in subject_level_ds using WHERE expression. Optionally, the number of subjects can be specify to extract smaller number of subjects from large size datasets.

### Parameters
 - `inlib`  :  libname where original datasets are located. dataset with index is preferable
 - `outlib`:  libname output datasets extracted with specific subjects to be stored
 - `subject_level_ds`: subject level dataset e.g: work.DM, inds.ADSL 
 - `subject_id_var`: variable with subject / patient id. e.g: usubjid patientid
 - `no_sub` : Number of subjects you would like to extract. If this parameter is blank, all subjects in subject_level_ds is extracted
 - `ds_select_cond(optional)`: Condition to extract datasets.
				Note that condition to extract the datasets from output of proc contents.
							e.g: index(memname,"D_")
### Sample code

Extract subjects in PATIENT from datasets in library rwd and store them in library out

~~~sas
%small_world(inlib=rwd, outlib=out, 
	     subject_level_ds=PATIENT, 
	     subject_id_var=patid);
~~~

Use this macro with %index_single_key to shorten execution time for extraction.
Extract first 1000 subjects in rwdx.PATIENT from datasets in rwdx then store them in swd.
~~~sas
%index_single_key(inlib=rwd, outlib=rwdx, indexkey=patid);
%small_world(inlib=rwdx, outlib=swd, 
	     subject_level_ds=rwdx.PATIENT, 
	     subject_id_var=patid, no_sub=1000);
~~~

### Note:
If the original datasets have index of subject_id_var, the macro can extract dataset extlemely fast.

---

*//*** HELP END ***/

/* inlib  :  libname where original datasets are located. dataset with index is preferable */
/* outlib:  libname output datasets extracted with specific subjects to be stored */
/* subject_level_ds: subject level dataset e.g: work.DM, inds.ADSL  */
/* subject_id_var: variable with subject / patient id. e.g: usubjid patientid */
/* no_sub : Number of subjects you would like to extract. If this parameter is blank, all subjects in subject_level_ds is extracted */
/* ds_select_cond(optional): Condition to extract datasets. */
/* 				Note that condition to extract the datasets from output of proc contents. */
/* 							e.g: index(memname,"D_") */


%macro small_world(inlib=, outlib=, subject_level_ds=, subject_id_var=, no_sub=, ds_select_cond =);

    ********** Error message and abort if library does not exist **** ;

	%if &inlib EQ %then %do;
	    %put %str(ER)%str(ROR: SASPAC inlib is a mandatory parameter. Please provide the library reference where original datasets are located.); 
	    %goto exit;
	%end;    
	
	%if &outlib EQ %then %do;
	    %put %str(ER)%str(ROR: SASPAC outlib is a mandatory parameter. Please provide the library reference where output datasets with index data to be stored.); 
	    %goto exit;
	%end;   

    %if %sysfunc(libref(&inlib.)) ne 0 %then %do;
        %put %str(ER)%str(ROR: LIBRARY "&inlib." DOES NOT EXIST. Please provide the library reference where original datasets are located.); 
        %goto exit;
    %end;
    %if %sysfunc(libref(&outlib.)) ne 0 %then %do;
        %put %str(ER)%str(ROR: LIBRARY "&outlib." DOES NOT EXIST. Please provide the library reference where output datasets with index data to be stored.); 
        %goto exit;
    %end;


    ********** subject_level_ds **** ;
	
	%if &subject_level_ds EQ %then %do;
	    %put %str(ER)%str(ROR: SASPAC subject_level_ds is a mandatory parameter. Please provide the subject level dataset.); 
	    %goto exit;
	%end;


    ********** subject_id_var **** ;

	%if &subject_id_var EQ %then %do;
	    %put %str(ER)%str(ROR: SASPAC subject_id_var is a mandatory parameter. Please provide the variable with subject / patient id.); 
	    %goto exit;
	%end;


    *** Count the number of variables separated by spaces ;
    %let _count_space = %sysfunc(countw(strip(&subject_id_var), %str( ))) ;
    %if &_count_space > 1 %then %do;
	    %put %str(ER)%str(ROR: Specify only one variable for subject_id_var. (subject_id_var : &subject_id_var)); 
        %goto exit;
    %end;


    ************** ;

	data _null_;
	    call symput("_date",put(date(),e8601da.));
   	    call symput("_datetime",put(datetime(),e8601dt.));
	    call symput("p_inlib",strip(pathname("&inlib.")));
	    call symput("p_outlib",strip(pathname("&outlib.")));
	run;
	%put macro execution time: &_datetime.;
	%put original datasets located in <&p_inlib.>;
	%put extracted datasets will be output to <&p_outlib.>;


    ********** subject_level_ds existence check >> remove **** ;

	proc contents data=&inlib.._all_ out=x__dslist0(keep=memname name type) noprint; 
	data _null_;
		set x__dslist0;
		if upcase(name) = "%upcase(&subject_id_var)" 
		then call symput("v_type",strip(put(type,best.)));
	run;
	%put &v_type. ;   
	
	
    ********** ds_select_cond existence check **** ;

   %if %length(&ds_select_cond.) > 0  %then %do;
	data _null_;
        set x__dslist0 ;
            where &ds_select_cond.;
            %put "NOTE: where condition applied";
    run ;

    proc sql noprint;
        select count(*) into :count_filtered from x__dslist0 where &ds_select_cond.;
    quit;

    %if &count_filtered = 0 %then %do;
        %put %str(ER)%str(ROR: No datasets match the condition specified in ds_select_cond: &ds_select_cond.);
        %goto exit;
    %end;
  %end;

    ********** subject_id_var existence check **** ;

	proc sort data=x__dslist0 out=x__dslistw(keep=memname name); 
		by name memname ; 
		where upcase(name) = "%upcase(&subject_id_var.)";
	run;


	proc sql noprint;
		select compress(put(count(*),best.)) into :NOC from x__dslistw;
	quit;

	%if &NOC eq 0 %then %do;
        %put %str(ER)%str(ROR: SASPAC There was no dataset extracted by conditions with parameter subject_id_var, please confirm.); 
        %goto exit;
  	%end;   	


    ***** Verify that subject_label_ds is a unique dataset *** ;
    *** Create a working dataset for duplicate checking ;
    proc sort data=&subject_level_ds out=x__ds_unique dupout=x__ds_dupout  nodupkey;
        by &subject_id_var;
    run;

    proc sql noprint;
        select count(*)
        into :dupout_count
        from x__ds_dupout;
    quit;

    *** Processing for duplicates ;
    %if &dupout_count >0  %then %do;
        %put %str(NOTE: It is not at the Subject Level, but it will be used after Nodup. Sort and extract the first No_SUB.); 

        *** Output unique datasets as x__subject_level_ds ;
        data x__subject_level_ds;
            set x__ds_unique;
        run;
    %end;
    %else %do ;
        *** Output unique datasets as subject_level_ds ;
        data x__subject_level_ds;
            set &subject_level_ds;
        run;
    %end;
    

	********** ;

	proc sort data=x__dslist0 out=x__dslist(keep=memname) ; 
		by memname;
		where upcase(name) = "%upcase(&subject_id_var.)";
	run ;

	********** applies where condition ****;
	data x__dslist ;
		set x__dslist;
	    %if %length(&ds_select_cond.) > 0  %then %do;
		  where &ds_select_cond.;
	    %end;
		key1=1;
	run;
		
	*extract first &no_sub subjects;
	data x__sub;
		set x__subject_level_ds;
		%if %eval(&no_sub. > 0) %then %do;
			if _n_ <= &no_sub;
		%end;
		
		key2=1;
		keep &subject_id_var. key2;
	run;
	
	proc sql;
	  create table x__dslist_sub as
	  select a.*, b.*
	  from x__dslist as a
	  full join x__sub as b
	  on a.key1 = b.key2;
	quit;

	proc sort data=x__dslist_sub; by  memname &subject_id_var.; run;

	data _null_;
			set x__dslist_sub end=eof;
			by memname &subject_id_var.;
		if _n_=1 then call execute("options nosource nomprint;");
		if first.memname then do;
			call execute("data &outlib.."||compress(memname)||";");
			call execute("set &inlib.."||compress(memname)||";");	
			call execute("where &subject_id_var. in (");
		end;
		%if &v_type. = 2 %then %do;
			call execute("'"||compress(&subject_id_var)||"' ");
		%end;
		%else %if &v_type. = 1 %then %do;
			call execute(""||compress(&subject_id_var)||" ");
		%end;
		
		if last.memname then do;
		call execute(");");
		call execute("run;");
		if eof then call execute("options source;");
	end;
	run;

	%EXIT:
	
	proc datasets nolist;
	    delete  x__:;
	quit;
	
%mend small_world;
