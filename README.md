# RWD Express (latest version 0.0.1 on 16Jun2025)
A SAS package to help you handle big data like RWD

![logo](https://github.com/Narusawa-T/RWDExpress/blob/main/RWDExpress_small.png)

## %index_single_key() : index key
You can set one index key for all datasets in the library at once.

Sample code:
~~~sas
%index_single_key(
  inlib = data,           /*inlib  :  library reference where original datasets are located*/
  outlib= datax,          /*outlib:   library reference where output datasets with index data to be stored*/
  indexkey= subjectid,    /*indexkey: index key variable for all datasets.e.g: %str(patientid)	*/
  in_ds= ,                /*in_ds(optional): datasets to be extracted. e.g: %str("AE" "CM" "DM")  */		
  ex_ds=,                 /*ex_ds(optional): datasets to be excluded. e.g: %str("XX" "XY" "XS")  */
  ds_select_cond =);      /*ds_select_cond(optional): Condition to extract datasets.
		            Note: where condition to extract the datasets from output of proc contents. e.g: index(memname,"D_") */
~~~

## What is SAS Packages?

The package is built on top of **SAS Packages framework(SPF)** developed by Bartosz Jablonski.  

For more information about SAS Packages framework, see [SAS_PACKAGES](https://github.com/yabwon/SAS_PACKAGES).  

You can also find more SAS Packages(SASPACs) in [SASPAC](https://github.com/SASPAC).
 
## How to use SAS Packages? (quick start)

### 1. Set-up SPF(SAS Packages Framework)

Firstly, create directory for your packages and assign a fileref to it.

~~~sas      

filename packages "\path\to\your\packages";

~~~

Secondly, enable the SAS Packages Framework.  

(If you don't have SAS Packages Framework installed, follow the instruction in [SPF documentation](https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation) to install SAS Packages Framework.)  

~~~sas      

%include packages(SPFinit.sas)

~~~  

### 2. Install SAS package  

Install SAS package you want to use using %installPackage() in SPFinit.sas.

~~~sas      

%installPackage(packagename, sourcePath=\github\path\for\packagename)

~~~

(e.g. %installPackage(ABC, sourcePath=https://github.com/XXXXX/ABC/raw/main/))  

### 3. Load SAS package  

Load SAS package you want to use using %loadPackage() in SPFinit.sas.

~~~sas      

%loadPackage(packagename)

~~~

### Enjoy😁

---
 
## Version history
0.0.1(16June2025)	: Initial version
