cp -r source/. builds/chrome/scripts
cp -r source/. builds/firefox/scripts
cp -r source/. builds/vkopt.safariextension/scripts
cp -r source/. builds/opera.extension/scripts

cp background.js builds/chrome
cp background.js builds/firefox/chrome/content
cp background.js builds/maxthon
cp background.js builds/opera.extension
cp background.js builds/vkopt.safariextension

cp content_script.js builds/chrome
cp content_script.js builds/firefox/chrome/content
cp content_script.js builds/maxthon
mkdir -p builds/opera.extension/includes
cp content_script.js builds/opera.extension/includes
cp content_script.js builds/vkopt.safariextension
