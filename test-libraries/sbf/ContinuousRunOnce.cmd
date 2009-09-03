@echo off
rem This script is used to fix issues in integration build 
rem It stops the automatic integration build
rem Then runs integration with no emails, forced build and output to standard out
rem on completeion it restarts automatic integration build

%~dp0..\Tools\ToolBox\rtask -end -tn ContinuousIntegrationBuild
%~dp0..\Tools\ToolBox\rtask -dt  -tn ContinuousIntegrationBuild

set ForceBuild=true
set Email=false         
set LogOutput=false
call %~dp0continuous.cmd

echo .
echo Hit enter to restore automatic integration build 
echo .
pause

%~dp0..\Tools\ToolBox\rtask -et -tn ContinuousIntegrationBuild

echo .
echo Hit enter to exit
echo .
pause