@echo off 
SetLocal EnableDelayedExpansion
REM SetLocal will keep all your 'SETs" to be only valid during the current session, and will not leave vars left around named like "FileName1" or any other variables you set during the run, that could interfere with the next run of the batch file.

REM usage split.bat <filename>
REM =========================
rem Made by Kim Dongryeong 2021/01/04
REM TO ADD MORE: 
REM =========================
rem History
rem 20210114 Now it deletes all .thm and .lrv files when the source is a path
rem 20221207 It used to take only +00:00 or -00:00. But now it can take +000:00 or +000000:00 forms.
rem   Also changed all exiftool commands to %~dp0exiftool so that exiftool.exe now doesn't have to 
rem   be installed in C:\Windows. exiftool.exe should be in the same directory as the .BAT file.
rem 20221219 Now the BAT file is in ANSI. Fixed a few things.

rem KNOWLEDGE (as I will forget again)
rem -api largefilesupport=1 is needed to support large files.
rem SET a=The fat cat
rem %a:fat=thin%
REM now a is 'The thin cat'

rem %y vs %%y

rem A good example:
rem on CMD, the following
rem c:\>exiftool -offsettimeoriginal="+09:00" -offsettimedigitized="+09:00" "-FileName<D:\path\GoPro ${model;s/HERO//}\$CreateDate GoPro ${model;s/HERO//} %f.%e" -d "%Y-%m-%d %H-%M-%S" -api largefilesupport=1 1.jpg
rem will copy 1.jpg to D:\path\GoPro 9 Black and create 2022-11-30 17-11-48 GoPro 9 Black 1.jpg

rem A bad example:
rem on CMD, the following
rem c:\>exiftool -offsettimeoriginal="+09:00" -offsettimedigitized="+09:00" "-FileName<D:\path\GoPro ${model;s/HERO//}\$CreateDate GoPro ${model;s/HERO//} %%f.%%e" -d "%%Y-%%m-%%d %%H-%%M-%%S" -api largefilesupport=1 1.jpg
rem will copy 1.jpg to D:\path\GoPro 9 Black and create %Y-%m- %H-%M-%S GoPro 9 Black %1.%jpg.

rem So as a command line, it should be %y, %f. 

rem But in a .BAT file, it should be like
rem c:\>exiftool -offsettimeoriginal="+09:00" -offsettimedigitized="+09:00" "-FileName<D:\path\GoPro ${model;s/HERO//}\$CreateDate GoPro ${model;s/HERO//} %%f.%%e" -d "%%Y-%%m-%%d %%H-%%M-%%S" -api largefilesupport=1 1.jpg
rem to create 2022-11-30 17-11-48 GoPro 9 Black 1.jpg. With one % each, it will create m-H-S GoPro 9 Black e.


rem non Alphabet

rem C:\>exiftool -offsettimeoriginal="+09:00" -offsettimedigitized="+09:00" "-FileName<D:\重食失\GoPro ${model;s/HERO//}\$CreateDate GoPro ${model;s/HERO//} %f.%e" -d "%Y-%m-%d %H-%M-%S" -api largefilesupport=1 1.jpg
rem even if there are Korean characters, 重食失, it works (at least on my computer).



set timezone=+09:00
rem by defualt
set newdestinationinputflag=0
set filenamechangeflag=ON
set "newfileprefix_defaultstyle=$CreateDate GoPro ${model;s/HERO//} "
REM JPGs have Make tag as GoPro but MP4s don't have it. So if $Make is used for MP4, it won't change the file name or the directory, which is moving the file.
set newfileprefix=%newfileprefix_defaultstyle%
rem there should be one space at the end
set destinationpath=
echo This program is made for image (JPG) and video (MP4) files recorded by GoPro.
ECHO GoPro cameras don't have time zone information, and so it causes various 
echo problems. This program will modify EXIF tag values of JPG files 
echo (ex. -offsettimeoriginal="+09:00" -offsettimedigitized="+09:00") and MP4 
echo files (ex. -CreateDate-=09:00 -TrackCreateDate-=09:00 -MediaCreateDate-=09:00). 
echo The original files will be replaced with new modified files.
echo.
echo USAGE
echo.
ECHO 	exiftool.exe should exist in the same folder as this BAT file.
echo.
echo 	GoProExifFixjpgmp4.bat "image.jpg"
echo 	GoProExifFixjpgmp4.bat "video.mp4"
echo 	GoProExifFixjpgmp4.bat DIR
echo.
echo 	+hh:mm  (ex. +01:00)
ECHO 	-hh:mm  (ex. -01:00 or -52000:00)
ECHO 	DIR     (ex. "D:\destination dir" or D:\destination dir. DIR shouldn't 
echo 	         contain any ")" - I don't know why.)
echo. 	ON
echo. 	OFF
REM 	without the dot, ON and OFF will be treated as a key of echo
ECHO 	EXIT
echo.
echo Input a time zone to modify the files to in +hh:mm or -hh:mm format 
echo (ex. +01:00 or -01:00). For example, if you are in Korea (GMT+09:00), and 
echo your GoPro is set to the Korean local time, you need to Input +09:00.
echo If you don't change the time zone, the default one (%timezone%) will be
echo used. Input a path to set a destination path. Input ON if you want to 
echo change the file name or OFF. Input EXIT if you want to quit it.
echo.
echo LIMITATION
ECHO The destination dir shouldn't contain any ")". When it handles a folder 
echo (GoProExifFixjpgmp4.bat DIR), if the destination dir contains non standard
echo alphabets like Korean characters, then it causes errors (it can't create
echo new files). (But if both of the source dir and the destination dir contain)
echo Korean characters, it doesn't create any errors. (I don't know why.)
ECHO.
ECHO.

:_view
if "%~x1"=="" (
	REM The input parameter is a directory.
	set "destinationpath=%~dpn1"
	REM ex. D:\original dic
	rem double quotation marks should be included. Otherwise it causes error if a path (or a folder name) contains &
	echo The original EXIF tag values of JPGs and MP4s in the directory:
	"%~dp0exiftool" -FileCreateDate -CreateDate -DateTimeOriginal -offsettimeoriginal -offsettimedigitized -timezone -api largefilesupport=1 -ext jpg %1
	rem %1 is the first variable after test.bat "image.jpg"; in this case "image.jpg".
	rem -ext jpg DIR: process only JPG files.
	REM Like "%~dp0exiftool", there should be double qutation marks. Otherwise an error may happen due to a space like "'K:\My' is not recognized as an internal or external command, operable program or batch file.".
	"%~dp0exiftool" -FileCreateDate -CreateDate -TrackCreateDate -MediaCreateDate -timezone -api largefilesupport=1 -ext mp4 %1
	"%~dp0exiftool" -FileCreateDate -CreateDate -TrackCreateDate -MediaCreateDate -timezone -api largefilesupport=1 -ext mov %1
	REM GoPro doesn't record .mov but it's only to show EXIF tag values
	echo.
) else if /i "%~x1"==".jpg" (
	REM The input parameter is a single .jpg file.
	set "destinationpath=%~dp1"
	rem ex. D:\original dic\
	set "destinationpath=!destinationpath:~0,-1!"
	rem ex. D:\original dic
	echo The original EXIF tag values of the JPG file:
	"%~dp0exiftool" -FileCreateDate -CreateDate -DateTimeOriginal -offsettimeoriginal -offsettimedigitized -timezone -api largefilesupport=1 %1
) else if /i "%~x1"==".mp4" (
	REM The input parameter is a single .mp4 file.
	set "destinationpath=%~dp1"
	rem ex. D:\original dic\
	set "destinationpath=!destinationpath:~0,-1!"
	rem ex. D:\original dic
	echo The original EXIF tag values of the MP4 file:
	"%~dp0exiftool" -FileCreateDate -CreateDate -TrackCreateDate -MediaCreateDate -timezone -api largefilesupport=1 %1
) else if /i "%~x1"==".mov" (
	REM GoPro doesn't record .mov but it's only to show EXIF tag values
	echo The original EXIF tag values of the MP4 file:
	"%~dp0exiftool" -FileCreateDate -CreateDate -TrackCreateDate -MediaCreateDate -timezone -api largefilesupport=1 %1
	goto _exit
) else (
	echo The parameter is wrong.
	goto _exit
)

:_menuinput
echo.
echo CURRENT SETTING
ECHO      SOURCE:           "%~1"
echo      TIME ZONE:        %timezone%
echo      DESTINATION PATH: "%destinationpath%"
echo      FILE NAME CHANGE: %filenamechangeflag%
echo. 
echo If the source and the destination path are the same, it will overwrite them. 
echo If different, after creating new modified files, it will delete the original 
echo files. If the source is a path, it will delete all .thm and .lrv files in 
echo the folder. Press Enter to execute.
echo.

set menuinput=""
REM if it doesn't exist, 
REM set menuinput=%menuinput:"=% --> will set menuinput="=. So menuinput will be "="
REM echo %menuinput%|findstr /r "^[a-z]:\\.*[^\\]$" >nul --> and will output "=|findstr /r "[a-z]:\\.*[\\]$" >nul

set /p menuinput=^> 
rem ^ will escape > and print the character.
REM ===== to check if an input is a new path and to get it =====
set menuinput=%menuinput:"=%
echo %menuinput%|findstr /r "^[a-z]:\\.*[^\\]$" >"%~dp0nul.txt"
REM In general, \" is correct instead of " like echo %menuinput%|findstr /r "^\"[a-z]:\\.*\"$"
REM	However, we removed " already
REM the regular expression should be surrounded by "".
REM It accepts "D:\path" and D:\path and not "D:\path\" or D:\path\.
if %errorlevel% == 0 (
	set newdestinationinputflag=1
	echo A new destination path is set.
	set destinationpath=%menuinput%\GoPro ${model;s/HERO//}
	goto _menuinput
) else (
	REM Not a path.
)

echo %menuinput%|findstr /r "^[-+][0-9][0-9]*:[0-9][0-9]$" >nul
REM In the v.20210114, it was "^[-+][0-9][0-9]:[0-9][0-9]$" and so it was only for +-00:00~99:59. But now it can be 9999:00 for example.
if %errorlevel% == 0 (
	echo A new time zone is set.
	set timezone=%menuinput%
	goto _menuinput
) else (
	REM Not in a timezone format
)

rem ===== check the menu input =====
if /i "%menuinput%"=="EXIT" (
	echo EXIT input
	pause
	goto _exit
) else if "%menuinput%"=="" (
	rem  just enter input
) else if /i "%menuinput%"=="ON" (
	set filenamechangeflag=ON
	set "newfileprefix="%newfileprefix_defaultstyle%"
	rem there should be one space at the end
	goto _menuinput
) else if /i "%menuinput%"=="OFF" (
	set filenamechangeflag=OFF
	set newfileprefix=
	goto _menuinput
) else (
	goto _menuinput
)

rem ===== excuting the main task =====

set timezonesign=%timezone:~0,1%
set timezonewosign=%timezone:~1%
REM In the v.20210114, it was set timezonewosign=%timezone:~1,5% as it was always in +-00:00 form. But now only with %timezone:~1%, it can cover long numbers. https://www.dostips.com/DtTipsStringManipulation.php
if "%timezonesign%"=="+" (
	set commandjpg=-offsettimeoriginal="%timezone%" -offsettimedigitized="%timezone%"
	set commandmp4=-CreateDate-=%timezonewosign% -TrackCreateDate-=%timezonewosign% -MediaCreateDate-=%timezonewosign%
) else if "%timezonesign%"=="-" (
	set commandjpg=-offsettimeoriginal="%timezone%" -offsettimedigitized="%timezone%"
	set commandmp4=-CreateDate+=%timezonewosign% -TrackCreateDate+=%timezonewosign% -MediaCreateDate+=%timezonewosign%
)

if "%~x1"=="" (
	rem ex. %~x1 = C:\Users\Kim Dongryeong\Desktop\GoProExifFixjpgmp4\test
	goto _dir
) else if /i "%~x1"==".jpg" (
	goto _jpg
) else if /i "%~x1"==".mp4" (
	goto _mp4
) else (
	echo The parameter is wrong.
	goto _exit
)

rem 3 cases: the input was DIR, a jpg file or a mp4 file.

:_dir
echo.
echo The following commands will be applied (intended for GoPro's JPG and MP4 files). 
echo exiftool %commandjpg% -ext jpg
echo exiftool %commandmp4% -ext mp4
echo.
del "%~1\*.thm" /q 2>nul
del "%~1\*.lrv" /q 2>nul
rem if we have /q, then 2>nul is not needed?
"%~dp0exiftool" %commandjpg% "-FileName<%destinationpath%\%newfileprefix%%%f.%%e" -d "%%Y-%%m-%%d %%H-%%M-%%S" -api largefilesupport=1 -ext jpg %1 -overwrite_original -s3 -v>"%~dp0exiftooltemp.txt"
rem exiftool -offsettimeoriginal="+09:00" -offsettimedigitized="+09:00" "-FileName<D:\path\GoPro ${model;s/HERO//}\$CreateDate GoPro ${model;s/HERO//} %%f.%%e" -d "%%Y-%%m-%%d %%H-%%M-%%S" -api largefilesupport=1 -ext jpg "C:\Users\Kim Dongryeong\Documents\goprofix test" -overwrite_original -s3 -v>"%~dp0exiftooltemp.txt"
rem 1) create a new file with a new name, 2) apply new tag values 3) delete the original file
rem -overwrite_original: delete the original file
rem -s3: print values only (no tag names)
rem -v: Print verbose messages
rem -s3 and -v are needed for manipulating exiftooltemp.txt later.
rem %f (%%f in a .BAT file) is the original file name.
rem %e is the original file's extension.
rem %1 is the first input variable
rem -ext jpg DIR: processing all JPGs in DIR

"%~dp0exiftool" %commandmp4% "-FileName<%destinationpath%\%newfileprefix%%%f.%%e" -d "%%Y-%%m-%%d %%H-%%M-%%S" -api largefilesupport=1 -ext mp4 %1 -overwrite_original -s3 -v>>"%~dp0exiftooltemp.txt"
echo.
if "%newdestinationinputflag%"=="0" (
	rem The destination path is not given. So they won't move.
	if "%filenamechangeflag%"=="OFF" (
		rem it doesn't change the file names.
		echo.
		echo The new EXIF tag values of JPGs and MP4s in the directory:
		"%~dp0exiftool" -FileCreateDate -CreateDate -DateTimeOriginal -offsettimeoriginal -offsettimedigitized -timezone -api largefilesupport=1 -ext jpg %1
		"%~dp0exiftool" -FileCreateDate -CreateDate -TrackCreateDate -MediaCreateDate -timezone -api largefilesupport=1 -ext mp4 %1
	) else (
		call :extractnewnamelist
	)
) else (
	call :extractnewnamelist
)
goto _exit

:_jpg
echo.
echo The following commands will be applied (intended for GoPro's JPG and MP4 files). 
echo exiftool %commandjpg%
echo.
"%~dp0exiftool" %commandjpg% "-FileName<%destinationpath%\%newfileprefix%%%f.%%e" -d "%%Y-%%m-%%d %%H-%%M-%%S" -api largefilesupport=1 %1 -overwrite_original -s3 -v>"%~dp0exiftooltemp.txt"
rem destinationpath is either the original dic ex. D:\original dic or %menuinput%\GoPro ${model;s/HERO//} ex. E:\destination dic\GoPro 8
rem newfileprefix is either empty or $CreateDate GoPro ${model;s/HERO//} 
rem in one EXIFTOOL comman, it will modify CreateDate but the old CreateDate will be used for the new file name
echo.
echo The new EXIF tag values of the JPG file:
echo.
if "%newdestinationinputflag%"=="0" (
	if "%filenamechangeflag%"=="OFF" (
		"%~dp0exiftool" -FileCreateDate -CreateDate -DateTimeOriginal -offsettimeoriginal -offsettimedigitized -timezone -api largefilesupport=1 -ext jpg %1
	) else (
		call :extractnewnamelist
	)
) else (
	call :extractnewnamelist
)
goto _exit

:_mp4
echo.
echo The following commands will be applied (intended for GoPro's JPG and MP4 files). 
echo exiftool %commandmp4%
echo.
"%~dp0exiftool" %commandmp4% "-FileName<%destinationpath%\%newfileprefix%%%f.%%e" -d "%%Y-%%m-%%d %%H-%%M-%%S" -api largefilesupport=1 %1 -overwrite_original -s3 -v>"%~dp0exiftooltemp.txt"
echo newfileprefix=%newfileprefix%
echo.
echo The new EXIF tag values of the MP4 file:
echo.
if "%newdestinationinputflag%"=="0" (
	if "%filenamechangeflag%"=="OFF" (
			"%~dp0exiftool" -FileCreateDate -CreateDate -TrackCreateDate -MediaCreateDate -timezone -ext mp4 -api largefilesupport=1 %1
	) else (
		call :extractnewnamelist
	)
) else (
	call :extractnewnamelist
)
goto _exit


rem ==== EXTRACT A LIST OF NEW FILE NAMES WITH FULL PATHES AND SHOW NEW TAGS===
:extractnewnamelist
set /a n=0
findstr /l /c:"-->" "%~dp0exiftooltemp.txt">"%~dp0exiftooltemp_lineextract.txt"
rem ex. each line is 'E:/photos and videos/test/exiftool/old.jpg' --> 'C:/Users/Kim Dongryeong/Desktop/GoProExifFixjpgmp4/temp/GoPro 7 Black/1234-12-31 23-21-59 GoPro 7 Black old.jpg'
for /f "usebackq delims=" %%a in ("%~dp0exiftooltemp_lineextract.txt") do (
	call set varfilename[%%n%%]="%%a"
	rem ex. varfilename[0]="'E:/photos and videos/test/exiftool/old.jpg' --> 'C:/Users/Kim Dongryeong/Desktop/GoProExifFixjpgmp4/temp/GoPro 7 Black/1234-12-31 23-21-59 GoPro 7 Black old.jpg'"
	call set /a n=%%n%%+1
)

SET /A n=%n%-1
del "%~dp0exiftooltemp_onlynewfilenames.txt" 2>nul
rem This sends only error messages to nul ex. when it doesn't exist
for /l %%i in (0,1,%n%) do (
	set vartemp=!varfilename[%%i]!
	rem ex. "'E:/photos and videos/test/exiftool/old.jpg' --> 'E:/photos and videos/test/exiftool/1234-12-31 23-21-59 GoPro 7 Black old.jpg'"
	call :splitline
	set varfilename_old[%%i]=!vartemp_old!
	set varfilename_new[%%i]=!vartemp_new!
	echo !varfilename_new[%%i]!>>"%~dp0exiftooltemp_onlynewfilenames.txt"
	echo New file name: 
	echo !vartemp_new!
	"%~dp0exiftool" -FileCreateDate -CreateDate -DateTimeOriginal -offsettimeoriginal -offsettimedigitized -TrackCreateDate -MediaCreateDate -timezone -api largefilesupport=1 "!vartemp_new!"

)
exit /b 0

:splitline
set vartemp=%vartemp:>=%
REM removing >. otherwise it creates error
REM also in the FOR loop, vartemp=!vartemp:>=! creates error.
REM ex. "'E:/photos and videos/test/exiftool/old.jpg' -- 'E:/photos and videos/test/exiftool/1234-12-31 23-21-59 GoPro 7 Black old.jpg'"
set vartemp=%vartemp:"=%
REM removing ". otherwise it creates error
REM ex. 'E:/photos and videos/test/exiftool/old.jpg' -- 'E:/photos and videos/test/exiftool/1234-12-31 23-21-59 GoPro 7 Black old.jpg'
set vartemp=%vartemp:~1,-1%
REM removing '. Not substituting because filename can contain '
REM ex. E:/photos and videos/test/exiftool/old.jpg' -- 'E:/photos and videos/test/exiftool/1234-12-31 23-21-59 GoPro 7 Black old.jpg
set "vartemp_old=%vartemp:' -- '=" & set "vartemp_new=%"
rem ex. vartemp_old: E:/photos and videos/test/exiftool/old.jpg
rem ex. vartemp_new: E:/photos and videos/test/exiftool/1234-12-31 23-21-59 GoPro 7 Black old.jpg
exit /b 0

:_exit
EndLocal
pause
exit