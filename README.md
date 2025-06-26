# RWD Express (latest version 0.0.1 on 16Jun2025)
A SAS package to help you handle big data like RWD

![logo](https://github.com/Narusawa-T/RWDExpress/blob/main/RWDExpress_small.png)

**"RWD Express"**. The package is to help handle a big data.
Under construction, stay tuned!

## %index_single_key() : index key
1. Pick single key for index such as patient ID 
2. 

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

Under construction, stay tuned!

## How to use RWDExpress? (quick start)
Create directory for your packages and assign a fileref to it.
~~~sas
filename packages "\path\to\your\packages";
~~~
 
Enable the SAS Packages Framework (if you have not done it yet):
~~~sas
%include packages(SPFinit.sas)
~~~
 
(If you don't have SAS Packages Framework installed follow the [instruction](https://github.com/yabwon/HoW-SASPackages/blob/main/Share%20your%20code%20with%20SAS%20Packages%20-%20a%20Hands-on-Workshop.md#how-to-install-the-sas-packages-framework).)
 
 
When you have SAS Packages Framework enabled, run the following to install and load the package:
 
~~~sas
 
/* Install and load RWDExpress */
%installPackage(RWDExpress, sourcePath=https://github.com/Narusawa-T/RWDExpress/raw/main/)   /* Install RWDExpress to your place */
%loadPackage(RWDExpress)
 
/* Enjoy RWDExpress😄 */
%index_single_key(
  inlib= sdtm,
  outlib= sdtmx,
  indexkey= usubjid,
  ds_select_cond = index(memname,"SUPP")=0 );
~~~

## Version history
0.0.1(16June2025)	: Initial version

## What is SAS Packages?
RWDExpress is built on top of **SAS Packages framework(SPF)** developed by Bartosz Jablonski.  
For more information about SAS Packages framework, see [SAS_PACKAGES](https://github.com/yabwon/SAS_PACKAGES).  
You can also find more SAS Packages(SASPACs) in [SASPAC](https://github.com/SASPAC).


