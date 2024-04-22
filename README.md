# GoPro-EXIF-Fix-for-JPG-and-MP4
GoPro EXIF Fix for JPG and MP4

This program is made for image (JPG) and video (MP4) files recorded by GoPro.
GoPro cameras don't have time zone information, and so it causes various 
problems. This program will modify EXIF tag values of JPG files 
(ex. -offsettimeoriginal="+09:00" -offsettimedigitized="+09:00") and MP4 
files (ex. -CreateDate-=09:00 -TrackCreateDate-=09:00 -MediaCreateDate-=09:00). 
The original files will be replaced with new modified files.

USAGE
	exiftool.exe should exist in the same folder as this BAT file.

  GoProExifFixjpgmp4.bat "image.jpg"
	GoProExifFixjpgmp4.bat "video.mp4"
	GoProExifFixjpgmp4.bat DIR

  +hh:mm  (ex. +01:00)
	-hh:mm  (ex. -01:00 or -52000:00)
	DIR     (ex. "D:\destination dir" or D:\destination dir. DIR shouldn't 
	         contain any ")" - I don't know why.)
 	ON
 	OFF
	
	EXIT

Input a time zone to modify the files to in +hh:mm or -hh:mm format 
(ex. +01:00 or -01:00). For example, if you are in Korea (GMT+09:00), and 
your GoPro is set to the Korean local time, you need to Input +09:00.
If you don't change the time zone, the default one (%timezone%) will be
used. Input a path to set a destination path. Input ON if you want to 
change the file name or OFF. Input EXIT if you want to quit it.

LIMITATION
The destination dir shouldn't contain any ")". When it handles a folder 
(GoProExifFixjpgmp4.bat DIR), if the destination dir contains non standard
alphabets like Korean characters, then it causes errors (it can't create
new files). (But if both of the source dir and the destination dir contain)
Korean characters, it doesn't create any errors. (I don't know why.)
