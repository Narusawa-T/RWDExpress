/*** HELP START ***//*

Will be added. 


*//*** HELP END ***/

/*=======================================================================*/
/*inlib  :  library reference where original datasets are located*/
/*outlib:   library reference where output datasets with index data to be stored*/
/*indexkey: index key variable for all datasets.e.g: %str(patientid)	*/
/*in_ds(optional): datasets to be extracted. e.g: %str("AE" "CM" "DM")  */		
/*ex_ds(optional): datasets to be excluded. e.g: %str("XX" "XY" "XS")  */	   
/*ds_select_cond(optional): Condition to extract datasets.
				Note that condition to extract the datasets from output of proc contents.
							e.g: index(memname,"D_") */
/*=======================================================================*/

%macro index_single_key(inlib=, outlib=, indexkey=, in_ds=, ex_ds=, ds_select_cond =);

	data _null_;
	    call symput("_date",put(date(),e8601da.));
	    call symput("_datetime",put(datetime(),e8601dt.));
	    call symput("p_inlib",compress(pathname("&inlib.")));
	    call symput("p_outlib",compress(pathname("&outlib.")));
	run;
	%put macro execution time: &_datetime.;
	%put original datasets located in <&p_inlib.>;
	%put datasets with index will be output to <&p_outlib.>;

	
	
	  %if &inlib EQ %then %do;
	       %put %str(ER)%str(ROR: SASPAC inlib is a mandatory parameter. Please provide the library reference where original datasets are located.); 
	       %goto exit;
	  %end;    
	
	  %if &outlib EQ %then %do;
	       %put %str(ER)%str(ROR: SASPAC outlib is a mandatory parameter. Please provide the library reference where output datasets with index data to be stored.); 
	       %goto exit;
	  %end;   
	
	  %if &indexkey EQ %then %do;
	       %put %str(ER)%str(ROR: SASPAC indexkey is a mandatory parameter. Please provide the variable for inedex key for all datasets.); 
	       %goto exit;
	  %end;   		
	
	  %if &in_ds NE & &ex_ds NE  %then %do;
	       %put %str(ER)%str(ROR: SASPAC both parameter in_ds and ex_ds can not be provided at the same time, please provide only one parameter of those.); 
	       %goto exit;
	  %end;   		
  
	proc contents data=&inlib.._all_ out=x__dslist0 noprint; 
	proc sort data=x__dslist0 out=x__dslist(keep=memname name); 
		by memname; 
		where upcase(name) = "%upcase(&indexkey)";
	run;

	********** applies where condition ****;
	data x__dslist;
		set x__dslist;
		%if &in_ds. ne %then %do;
			if upcase(memname) in (%upcase(&in_ds.));
			put "NOTE: in_ds datasets extracted";
		%end;
		%else %if &ex_ds. ne %then %do;
			if upcase(memname) not in (%upcase(&ex_ds.));
			put "NOTE: ex_ds datasets excluded";			
		%end;		
		%else %do; 
			%put Target all datasets with variable %UNQUOTE(&indexkey.);
		%end;
		
		%if &ds_select_cond. ne %then %do;
			where &ds_select_cond.;
			put "NOTE: where condition applied";
		%end;
		
	run;
	
	proc sql noprint;
		select compress(put(count(*),best.)) into :NOC from x__dslist;
	quit;
	
	 %if &NOC eq 0  %then %do;
       %put %str(ER)%str(ROR: SASPAC There was no dataset extracted by conditions with parameters in_ds/ex_ds/ds_select_cond, please confirm.); 
       %goto exit;
  	%end;   	
	
	data _null_;
			set x__dslist end=eof;			
			call execute("proc sort data=&inlib.."||compress(memname)||" out=x_"||compress(memname)||"; by &indexkey.; run;");
			call execute("data &outlib.."||compress(memname)||"(index=(&indexkey.));");
			call execute("set x_"||compress(memname)||";");	
			call execute("run;");
	run;
	
	%EXIT:
	proc datasets nolist;
	 delete  x__:;
	quit;
	
%mend index_single_key ;

