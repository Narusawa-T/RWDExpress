# RWD Express (latest version 0.1.0 on 05Sep2025)
A SAS package to help you handle a big data like RWD

![logo](https://github.com/Narusawa-T/RWDExpress/blob/main/RWDExpress_small.png)

## %index_single_key() 
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

## %small_world() 
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
~~~

## %split_world()
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
### Note:

---

## Version history
0.1.0(05Sep2025)	: Two new macros(%small_world, %split_world) released.  
0.0.1(16Jun2025)	: Initial version

## What is SAS Packages?

The package is built on top of **SAS Packages Framework(SPF)** developed by Bartosz Jablonski.

For more information about the framework, see [SAS Packages Framework](https://github.com/yabwon/SAS_PACKAGES).

You can also find more SAS Packages (SASPacs) in the [SAS Packages Archive(SASPAC)](https://github.com/SASPAC).

## How to use SAS Packages? (quick start)

### 1. Set-up SAS Packages Framework

First, create a directory for your packages and assign a `packages` fileref to it.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages "\path\to\your\packages";
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Secondly, enable the SAS Packages Framework.
(If you don't have SAS Packages Framework installed, follow the instruction in 
[SPF documentation](https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation) 
to install SAS Packages Framework.)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
%include packages(SPFinit.sas)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### 2. Install SAS package

Install SAS package you want to use with the SPF's `%installPackage()` macro.

- For packages located in **SAS Packages Archive(SASPAC)** run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- For packages located in **PharmaForest** run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName, mirror=PharmaForest)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- For packages located at some network location run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName, sourcePath=https://some/internet/location/for/packages)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  (e.g. `%installPackage(ABC, sourcePath=https://github.com/SomeRepo/ABC/raw/main/)`)


### 3. Load SAS package

Load SAS package you want to use with the SPF's `%loadPackage()` macro.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
%loadPackage(packageName)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Enjoy!

---


