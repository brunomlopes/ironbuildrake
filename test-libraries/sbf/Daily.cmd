@echo off
rem Batch file for kicking off daily build
rem This should be run as a scheduled task once a day
rem   Note that %~dp0 is a macro that gets replaced with the directory from which the cmd file was launched

rem Set variables

set BuildType=Daily
if '%Email%'=='' set Email=true
if '%Clean%'=='' set Clean=true
if '%LogOutput%'=='' set LogOutput=true
if '%Verbosity%'=='' set Verbosity=n
if '%ForceBuild%'=='' set ForceBuild=false
if '%CreateBranch%'=='' set CreateBranch=true

rem Call the common build script
call %~dp0RunBuildCommon