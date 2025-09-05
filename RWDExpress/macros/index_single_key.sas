/*** HELP START ***//*

`%index_single_key` is a macro that creates an index for datasets in a library all at once. The index key should be a single variable, such as `patientid`, that exists in all target datasets. 

### Parameters
  - `inlib`  :  Library reference containing the original datasets.
  - `outlib` :   Library reference where output datasets with index data to be stored
  - `indexkey`: index key variable for all datasets.e.g: patientid	
  - `in_ds(optional)` : datasets to be extracted. e.g: AE CM DM 		
  - `ex_ds(optional)` : datasets to be excluded. e.g: XX XY XS 	   
  - `ds_select_cond(optional)` : Condition to extract datasets.
				Note that condition to extract the datasets from output of proc contents.
							e.g: index(memname,"D_")
### Sample code
create single index for variable patid on all datasets in rwd library and store them in rwdx
~~~sas
%index_single_key(inlib=rwd, outlib=rwdx, indexkey=patid);
~~~
You can specify the target datasets using the optional parameter in_ds or ex_ds.
~~~sas
%index_single_key(inlib=rwd, outlib=rwdx, indexkey=patid, in_ds = DISEASE DRUG);
%index_single_key(inlib=rwd, outlib=rwdx, indexkey=patid, ex_ds = MASTER_DRUG);
~~~
You can specify the target datasets using condition using the optional parameterds_select_cond.
~~~sas
%index_single_key(inlib=rwd, outlib=rwdx, indexkey=patid, in_ds = index(memname,"MASTER_")=0);
~~~

### Note:
This macro creates a single index key to all datasets, supporting streamlined patient data extraction. Remember, only one key variable should be specified, typically the patient ID.
---

*//*** HELP END ***/

/*=======================================================================*/
/*inlib  :  library reference where original datasets are located*/
/*outlib:   library reference where output datasets with index data to be stored*/
/*indexkey: index key variable for all datasets.e.g: patientid	*/
/*in_ds(optional): datasets to be extracted. e.g: AE CM DM  */		
/*ex_ds(optional): datasets to be excluded. e.g: XX XY XS  */	   
/*ds_select_cond(optional): Condition to extract datasets.
				Note that condition to extract the datasets from output of proc contents.
							e.g: index(memname,"D_") */
/*=======================================================================*/

%macro index_single_key(inlib=, outlib=, indexkey=, in_ds=, ex_ds=, ds_select_cond =);

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


	data _null_;
	    call symput("_date",put(date(),e8601da.));
	    call symput("_datetime",put(datetime(),e8601dt.));
	    call symput("p_inlib",strip(pathname("&inlib.")));
	    call symput("p_outlib",strip(pathname("&outlib.")));
	run;
	%put macro execution time: &_datetime.;
	%put original datasets located in <&p_inlib.>;
	%put datasets with index will be output to <&p_outlib.>;

	
    ********** Error checking for parameters **** ;
	
	%if &indexkey EQ %then %do;
	    %put %str(ER)%str(ROR: SASPAC indexkey is a mandatory parameter. Please provide the variable for inedex key for all datasets.); 
	    %goto exit;
	%end;   		

    ***** Error message if more than one indexkey were given ;
              
    *** Count the number of variables separated by spaces ;
    %let _count_space = %sysfunc(countw(strip(&indexkey), %str( ))) ;
    %if &_count_space > 1 %then %do;
	    %put %str(ER)%str(ROR: Specify only one variable for indexkey. (indexkey : &indexkey)); 
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
            %let in_ds_list =; 
            
            %do i = 1 %to %sysfunc(countw(&in_ds., %str( )));

                %let in_item = %scan(&in_ds., &i);
            
                %if &i = %sysfunc(countw(&in_ds., %str( ))) %then %do ;
                    %let in_ds_list = &in_ds_list. "%upcase(&in_item.)";
                %end ;
                %else %do ;
                    %let in_ds_list = &in_ds_list. "%upcase(&in_item.)",;
                %end ;

            %end;

            if upcase(memname) in (&in_ds_list.);
            put "NOTE: in_ds datasets extracted";

		%end;
		%else %if &ex_ds. ne %then %do;
            %let ex_ds_list =; 

            %do i = 1 %to %sysfunc(countw(&ex_ds., %str( )));

                %let ex_item = %scan(&ex_ds., &i);
            
                %if &i = %sysfunc(countw(&ex_ds., %str( ))) %then %do ;
                    %let ex_ds_list = &ex_ds_list. "%upcase(&ex_item.)";
                %end ;
                %else %do ;
                    %let ex_ds_list = &ex_ds_list. "%upcase(&ex_item.)",;
                %end ;

            %end;
                    
            if upcase(memname) not in (&ex_ds_list.);
            put "NOTE: ex_ds datasets excluded";

		%end;		
		%else %do; 
			%put Target all datasets with variable %UNQUOTE(&indexkey.);
		%end;
		
		%if %length(&ds_select_cond.) > 0 %then %do;
			where &ds_select_cond.;
			put "NOTE: where condition applied";
		%end;
		
	run;
	

	proc sql noprint;
		select compress(put(count(*),best.)) into :NOC from x__dslist;
	quit;
	
	%if &NOC eq 0 %then %do;
        %put %str(ER)%str(ROR: SASPAC There was no dataset extracted by conditions with parameters in_ds/ex_ds/ds_select_cond, please confirm.); 
        %goto exit;
  	%end;   	
	
	data _null_;
		set x__dslist end=eof;			
		call execute("proc sort data=&inlib.."||compress(memname)||" out=x__"||compress(memname)||"; by &indexkey.; run;");
		call execute("data &outlib.."||compress(memname)||"(index=(&indexkey.));");
		call execute("set x__"||compress(memname)||";");	
		call execute("run;");
	run;
	
	%EXIT:
	proc datasets nolist;
	    delete  x__:;
	quit;
	
%mend index_single_key ;

