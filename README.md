# RWD Express (latest version 0.0.1 on 16Jun2025)
A SAS package to help creating SAS packages

![logo](https://github.com/Narusawa-T/RWDExpress/blob/main/RWDExpress_small.png)

**"RWD Express"**. The package is to help creating SAS packages. <br>Shaping onigiri(rice ball) by hands can be a bit challenging for beginners, but using onigiri mold makes it easy to form and provides a great introduction. Hope the mold(RWDExpress) will help you to create your SAS package.

## %index_single_key() : excel to package
1. **Put information** of SAS package you want to create **into an excel file** <br>(you can find template file in ./RWDExpress/addcnt)
2. %ex2pac(excel_file, package_location, complete_generation) will convert the excel into SAS package structure(folders and files) and execute %generatePackage() (optional) to package zip file

Sample code:
~~~sas
%ex2pac(
	excel_file=C:\Temp\template_package.xlsx,   /* Path of input excel file */
	package_location=C:\Temp\SAS_PACKAGES\packages,   /* Output path */
	complete_generation=Y)   /* Set Y(default) to execute %generagePackage() for completion */
~~~
**This allows you to create SAS packages via simple format of excel!**

## %pac2ex() : package to excel
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
  inlib= ,
  outlib=,
  indexkey=,
  in_ds=,
  ex_ds=,
  ds_select_cond =);
~~~

## Version history
0.0.1(16June2025)	: Initial version

## What is SAS Packages?
RWDExpress is built on top of **SAS Packages framework(SPF)** developed by Bartosz Jablonski.  
For more information about SAS Packages framework, see [SAS_PACKAGES](https://github.com/yabwon/SAS_PACKAGES).  
You can also find more SAS Packages(SASPACs) in [SASPAC](https://github.com/SASPAC).


