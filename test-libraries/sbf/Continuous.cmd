@echo off
rem Batch file for kicking off continuous build
rem This should be run as a scheduled task every 2 hours
rem   Note that %~dp0 is a macro that gets replaced with the directory from which the cmd file was launched

rem Set variables

set BuildType=Continuous
if '%Email%'=='' set Email=true
if '%Clean%'=='' set Clean=false
if '%LogOutput%'=='' set LogOutput=true
if '%Verbosity%'=='' set Verbosity=n
if '%ForceBuild%'=='' set ForceBuild=false
if '%CreateBranch%'=='' set CreateBranch=false


rem Call the common build script
call %~dp0RunBuildCommon