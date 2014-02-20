cp -r source/. builds/chromium/scripts
cp -r source/. builds/firefox/scripts
cp -r source/. builds/safari/scripts
cp -r source/. builds/opera/scripts

cp background.js builds/chromium
cp background.js builds/firefox/chrome/content
cp background.js builds/maxthon
cp background.js builds/opera
cp background.js builds/safari

cp content_script.js builds/chromium
cp content_script.js builds/firefox/chrome/content
cp content_script.js builds/maxthon
mkdir -p builds/opera/includes
cp content_script.js builds/opera/includes
cp content_script.js builds/safari
