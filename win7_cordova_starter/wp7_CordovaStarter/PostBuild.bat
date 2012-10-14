REM This script packages the app with all needed resources,
REM also that resources that are copyied at build time by pre build scripts

REM "$(ProjectDir)/PostBuild.bat" "$(TargetName)" "$(ProjectDir)" "$(OutDir)" 
ECHO "7zip is required for post build process"
ECHO "This script assumes that 7zip is located at %HOMEDRIVE%%HOMEPATH%/7z.exe"
ECHO "Usage:"
ECHO "PostBuild.bat wp7_CordovaStarter E:\win7_cordova_starter\wp7_CordovaStarter\ Bin\Debug"
REM
REM %1 target name
REM %2 project directory
REM %3 output directory

SET CURRDIR=%CD%
SET OUTDIR=%2%3
SET FNAME=%OUTDIR%\%1
CD /D %OUTDIR%
DIR
%HOMEDRIVE%%HOMEPATH%/7z.exe a -rtzip "%FNAME%.xap" "www"
%HOMEDRIVE%%HOMEPATH%/7z.exe l -tzip "%FNAME%.xap"
CD /D %CURRDIR%
