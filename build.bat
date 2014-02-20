@echo off
copy source builds\chromium\scripts
copy source builds\firefox\scripts
copy source builds\safari\scripts
copy source builds\opera\scripts

copy background.js builds\chromium
copy background.js builds\firefox\chrome\content
copy background.js builds\maxthon
copy background.js builds\opera
copy background.js builds\safari

copy content_script.js builds\chromium
copy content_script.js builds\firefox\chrome\content
copy content_script.js builds\maxthon
mkdir builds\opera\includes 2> NUL
copy content_script.js builds\opera\includes
copy content_script.js builds\safari
