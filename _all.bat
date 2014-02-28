@set /p answer=Version:

@echo need update on server "config.json" and "scripts" > "happy-%answer%-REMINDER.txt"

@del "happy-%answer%-firefox.xpi"
_zip_packer.py firefox "happy-%answer%-firefox.xpi"

@del "happy-%answer%-opera.oex"
_zip_packer.py opera "happy-%answer%-opera.oex"

@del "happy-%answer%-chromium.zip"
_zip_packer.py chromium "happy-%answer%-chromium.zip"

del "happy-%answer%-maxthon.mxaddon"
makpak.exe  .\maxthon\  "happy-%answer%-maxthon.mxaddon"

@del "happy-%answer%-opera.zip"
cd ..
builds\_zip_packer.py source "builds\happy-%answer%-opera.zip" "^vk(_|opt|lang)" "vkopt_debug.js"

pause
