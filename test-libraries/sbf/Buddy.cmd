@echo off
rem Batch file for kicking off buddy build
rem This should be run as a scheduled task every minute

rem Set variables

set BuildType=Buddy
if '%Email%'=='' set Email=true
if '%Clean%'=='' set Clean=false
if '%LogOutput%'=='' set LogOutput=true
if '%Verbosity%'=='' set Verbosity=n
if '%ForceBuild%'=='' set ForceBuild=false
if '%CreateBranch%'=='' set CreateBranch=false

rem Call the common build script
call %~dp0RunBuildCommon