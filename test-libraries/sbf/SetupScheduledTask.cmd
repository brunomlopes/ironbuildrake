@echo off
rem This command file creates a scheduled task to run the specified build
if '%1'=='' goto usage
if '%2'=='' goto usage
if '%3'=='' goto usage

set BuildStartTime=03:00:00

if '%1'=='B' set BuildType=Buddy
if '%1'=='C' set BuildType=Continuous
if '%1'=='D' set BuildType=Daily
if '%1'=='Buddy' set BuildType=Buddy
if '%1'=='Continuous' set BuildType=Continuous
if '%1'=='Daily' set BuildType=Daily

if '%BuildType%'=='Buddy' set BuildInterval=1
if '%BuildType%'=='Continuous' set BuildInterval=120
if '%BuildType%'=='Daily' set BuildInterval=daily

%~dp0..\Tools\rtask\1.2\rtask -del -tn %BuildType%Build
%~dp0..\Tools\rtask\1.2\rtask -new -tn %BuildType%Build -ru %2 -rp %3 -st %BuildStartTime% -int %BuildInterval% -tr %~dp0%BuildType%.cmd -wd %~dp0
goto end

:usage
echo .
echo Usage: SetupScheduledTask BuildType UserName Password
echo .
echo    Where BuildType = Buddy or B or Continuous or C or Daily or D
echo .
echo    Sets up the build specified with the correct schedule
echo .

:end