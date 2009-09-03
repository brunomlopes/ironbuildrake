@echo off
rem Batch file for kicking off specified build
rem Common file that cannot be used on its own. Must be called from from another file.

rem Note that %~dp0 is a macro that gets replaced with the directory from which the cmd file was launched

rem Check that required env variables have been set

if '%BuildType%'=='' goto NoParams
if '%Email%'=='' goto NoParams
if '%Clean%'=='' goto NoParams
if '%LogOutput%'=='' goto NoParams
if '%Verbosity%'=='' goto NoParams
if '%ForceBuild%'=='' goto NoParams
if '%CreateBranch%'=='' goto NoParams

rem Set variables

if BuildType=='B' set BuildType=Buddy
if BuildType=='C' set BuildType=Continuous
if BuildType=='D' set BuildType=Daily
set FilePrefix=%RANDOM%
set LogRoot=c:\BuildLogs
set LogFile=%FilePrefix%%BuildType%Log.txt
set LogFilePath=%LogRoot%\%BuildType%
set LogFileFull=%LogFilePath%\%LogFile%

if NOT EXIST %LogFilePath% md %LogFilePath%
net share BuildLogs=%LogRoot%

rem Confim actions to output stream

echo BuildType =    '%BuildType%'
echo ...
echo ForceBuild =   '%ForceBuild%'        
echo                (Set to true to build even though depot shows no changes)
echo Email =        '%Email%'             
echo                (Set to false when testing build and email notification is not required)
echo LogOutput =    '%LogOutput%'         
echo                (Set to false if you want logging to go to std out)
echo ...

rem Invoke Build

if "%LogOutput%"=="false" goto DontLogOutput

:LogOutput
echo Running %BuildType% Build with logging to %LogFile% ...
echo Attempting to synchronize with source control before launching build ... >> %LogFileFull%
sd sync >> %LogFileFull% 
tf get >> %LogFileFull%
echo on 
%WINDIR%\Microsoft.NET\Framework\v2.0.50727\msbuild.exe %~dp0..\Build.proj /v:%Verbosity% /p:BuildType=%BuildType%;LogFile=%LogFileFull%;ForceBuild=%ForceBuild%;Email=%Email%;Clean=%Clean%;CreateBranch=%CreateBranch% >> %LogFileFull% 
@echo off

goto End

:DontLogOutput
echo Running %BuildType% Build with logging to std out ...
sd sync 
echo on 
%WINDIR%\Microsoft.NET\Framework\v2.0.50727\msbuild.exe %~dp0..\Build.proj /v:%Verbosity% /p:BuildType=%BuildType%;ForceBuild=%ForceBuild%;Email=%Email%;Clean=%Clean%;CreateBranch=%CreateBranch%
@echo off

goto End

:NoParams
rem Some of the required environment variables have not been set so we cannot continue
echo Not all required variables have been set. This is best achieved by calling another script first. e.g. Buddy.cmd which will set the correct variables and then call RunBuildCommon.cmd
echo .
echo Ensure the following variables are all set:
echo .
echo BuildType = B[uddy], C[ontinuous], D[aily]
echo Email = True or False
echo Clean = True or False
echo LogOutput = True or False
echo Verbosity = q[uiet], m[inimal], n[ormal], d[etailed], diag[nostic]
echo ForceBuild = True or False
echo CreateBranch = True or False

:End

rem Clear environment variables (in case we are running from a command prompt rather than a scheduled task and want to re-run the scripts with different values

set FilePrefix=
set LogRoot=
set BuildType=
set Email=
set Clean=
set LogOutput=
set Verbosity=
set ForceBuild=
set CreateBranch=
set LogFile=
set LogFilePath=
set LogFileFull=
