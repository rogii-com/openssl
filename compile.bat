call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64 10.0.18362.0 -vcvars_ver=14.27.29110

:build

set ENV_INSTALL=%CD%\package

cmake -P rogii\build_amd64.cmake

pause
goto:build