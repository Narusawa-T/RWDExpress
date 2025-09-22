Type : Package
Package : RWDExpress
Title : RWD Express Package
Version : 0.1.1
Author : T.Narusawa(t.narusawa.i@gmail.com)
Maintainer : T.Narusawa(t.narusawa.i@gmail.com)
License : MIT
Encoding : UTF8
Required : "Base SAS Software"
ReqPackages :  

DESCRIPTION START:
### RWDExpress ###
 
This is a package to support data handling on big data like Real World Data.
When working with Real World data, long execution times are a real headache. The package allows us to use SAS Indexes, which can significantly speed up data extraction. SAS indexes have been implemented within a macro here and easily used by programmers who are not familier with it. The package comes with other handy macros which programmers may want to use when handling RWD.
 
list of macros:  
- `%index_single_key()`  
- `%small_world()`  
- `%split_world()`
DESCRIPTION END:
