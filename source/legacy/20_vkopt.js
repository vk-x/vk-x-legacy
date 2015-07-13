if (!window.vk_DEBUG) var vk_DEBUG=false;
/* EXT CONFIG */
if (!window.DefSetBits)

// This is how settings are stored now. Because f*** you.
// Chars 32, 69 are known to be unused.
var DefSetBits='yyyynnyyynyyy0n0yy0nnnynyyynyy0nynynnnnyy0yyy1yynnnnny0nynynynnnnyynnynnnynyyyynnyn3nnnnynynnnnnyy-3-0-#c5d9e7-#34a235-1';

var DefExUserMenuCfg='11111110111111111111'; // default user-menu items config
var vk_upd_menu_timeout=20000;      //(ms) Update left menu timeout
var vkMenuHideTimeout=400;          //(ms) Hide Menu Popups timeout
var CHECK_FAV_ONLINE_DELAY = 20000; //(ms)  delay for check online statuses of faved users
var FAVE_ONLINE_BLOCK_SHOW_COUNT=6;
var SHOW_POPUP_PROFILE_DELAY=800;//ms

/* Save messages history config */
var SAVE_MSG_HISTORY_PATTERN="%username% (%date%):\r\n%message%\r\n%attachments%\r\n\r\n"; //Save Messages history file format (one record)
var SAVE_MSG_HISTORY_DATE_FORMAT="HH:MM:ss  dd/mm/yyyy";

/* Delete messages config */
var MSG_DEL_REQ_DELAY=300; 	//ms
var MSG_IDS_PER_DEL_REQUEST=25;

var SEARCH_AUDIO_LYRIC_LINK='http://yandex.ru/yandsearch?text=%AUDIO_NAME%+%28%2Bsite%3Alyrics.mp3s.ru+%7C+%2Bsite%3Alyrics-keeper.com+%7C+%2Bsite%3Aalloflyrics.com++%7C+%2Bsite%3A2song.net++%7C+%2Bsite%3Amegalyrics.ru+%7C+%2Bsite%3Aakkords.ru%29';
var INJ_AUDIOPLAYER_DUR_MOD=true; //enable JS-injections to player functions, for duration label modification
/* API SETTINGS PAGE: http://vkontakte.ru/login.php?app=2168679&layout=popup&type=browser&settings=15615 */

var FAVE_ALLOW_EXTERNAL_LINKS=true;


/* Others */
var USERMENU_SYMBOL='&#9660;&nbsp;';
var MOD_PROFILE_BLOCKS=true;
var CUT_VKOPT_BRACKET=false;     // true - убирает из надписей вкопта скобки "[" и "]"
var MAIL_BLOCK_UNREAD_REQ=false; // true - отключает отсылку отчёта о прочтении сообщения, при его открытии из /mail
var MAIL_BLOCK_TYPING_REQ=false; // true - отключает отсылку уведомления собеседнику о наборе текста
var MAIL_SHOWMSG_FIX=true;
var SUPPORT_STEALTH_MOD=true;    // прикидываемся перед ТП, что у нас не стоит расширение для скачивания.
var VIDEO_AUTOPLAY_DISABLE=false;
var VIDEO_LINKS_WITH_EXTRA=true;
var FULL_ENCODE_FILENAME=false;
var PHOTO_DOWNLOAD_NAMES=false;
var ZODIAK_SIGN_OPHIUCHUS=false;
var AUDIO_DOWNLOAD_POSTFIX=false;
var FEEDFILTER_DEBUG=false;
var POST_SUBSCRIBE_BTN=false;

var VKOPT_CFG_LIST=[
         'vk_DEBUG',
         'vk_upd_menu_timeout',
         'vkMenuHideTimeout',
         'CHECK_FAV_ONLINE_DELAY',
         'FAVE_ONLINE_BLOCK_SHOW_COUNT',
         'SHOW_POPUP_PROFILE_DELAY',
         'USERMENU_SYMBOL',
         'MOD_PROFILE_BLOCKS',
         'CUT_VKOPT_BRACKET',
         'MAIL_BLOCK_UNREAD_REQ',
         'MAIL_BLOCK_TYPING_REQ',
         'SUPPORT_STEALTH_MOD',
         'VIDEO_AUTOPLAY_DISABLE',
         'VIDEO_LINKS_WITH_EXTRA',
         'FULL_ENCODE_FILENAME',
         'PHOTO_DOWNLOAD_NAMES',
         'ZODIAK_SIGN_OPHIUCHUS',
         'AUDIO_DOWNLOAD_POSTFIX',
         'FEEDFILTER_DEBUG',
         'POST_SUBSCRIBE_BTN'
];

var vkNewSettings=[94,95,96,97]; //"new" label on settings item
var SetsOnLocalStore={
  'vkOVer':'c',
  'remixbit':'c',
  'remixumbit':'c',
  'IDNew':'c',
  'AdmGr':'c',//last of cookie
  'FavList':'s',
  'GrList':'s',//myGrList
  'menu_custom_links':'s',
  'WallsID':'s'
};
var vk_showinstall=true;
var vkLdrImg='<img src="/images/upload.gif">';
var vkLdrMonoImg='<img src="/images/upload_inv_mono.gif">';
var vkLdrMiniImg='<img src="/images/upload_inv_mini.gif">';
var vkBigLdrImg='<center><img src="/images/progress7.gif"></center>';
var SettBit=false;

var FriendsNid=[];

//YouTube formats list
var YT_video_itag_formats={
     '0': '240p.flv',
     '5': '240p.flv',
     '6': '360p.flv',
     '34': '360p.flv',
     '35': '480p.flv',

     '13': '144p.3gp (small)',
     '17': '144p.3gp (medium)',
     '36': '240p.3gp',

     '160': '240p.mp4 (no audio)',
     '18': '360p.mp4',
     '135': '480p.mp4 (no audio)',
     '22': '720p.mp4',
     '37': '1080p.mp4',
     '137': '1080p.mp4 (no audio)',
     '38': '4k.mp4',
     '82': '360p.mp4',//3d?
     //'83': '480p.mp4',//3d?
     '84': '720p.mp4',//3d?
     //'85': '1080p.mp4',//3d?

     '242': '240p.WebM (no audio)',
     '43': '360p.WebM',
     '44': '480p.WebM',
     '244': '480p.WebM (low, no audio)',
     '45': '720p.WebM',
     '247': '720p.WebM (no audio)',
     '46': '1080p.WebM',
     '248': '1080p.WebM (no audio)',
     '100':'360p.WebM',//3d?
     //'101':'480p.WebM',//3d?
     '102':'720p.WebM',//3d?
     //'103':'1080p.WebM',//3d?

     '139': '48kbs.aac',
     '140': '128kbs.aac',
     '141': '256kbs.aac',

     '171': '128kbs.ogg',
     '172': '172kbs.ogg'
};
 // kolobok.us
var SmilesMap = {
'girl_angel': /O:-\)|O:\)|O\+\)|O=\)|0:-\)|0:\)|0\+\)|0=\)/gi,
'smile': /:\)+|:-\)+|=\)+|=\]|\(=|\(:|\)\)\)+|\+\)/gi,// |:-\]|:\]

'hang1':[/-:\(/ig,'big_madhouse'],
'sad': /[\+:]\(+|:-\(+|=\(+|\(\(\(+/gi,

'wink': /;\)+|;-\)+|\^_~/gi,
'blum1': /:-[p\u0440]|[\+=:][p\u0440]|:-[P\u0420]|[\+=:][P\u0420]|[:\+=]b|:-b/gi,
'cool': /B-?[D\)]|8-[D\)]/gi,
'biggrin': /[:\=]-?D+/gi,

'mamba': [/[=:]\[\]|\*WASSUP\*|\*SUP\*/ig,'big_madhouse'],
'blush':  /:-?\[|;-\.|;'>/gi, //\^_\^|

'shok': /=-?[0OОoо]|o_0|o_O|0_o|O_o|[OО]_[OО]/gi,
'diablo':  /[\]}]:-?>|>:-?\]|\*DIABLO\*/gi,
'cray': /[:;]-?\'\(|[:;]\'-\(/gi,
'mocking': /\*JOKINGLY\*|8[Pp]/gi,
'give_rose': /@-->--|@}->--|@}-:--|@>}--`---/gi,
'music': /\[:-?\}/gi,
'air_kiss':/\*KISSED\*/gi,
'kiss': /[:;=]-\*+|[:;=]\*+|:-?\{\}|[\+=]\{\}|\^\.\^/gi,//[:;=]-\[\}|[:;=]\[\}
'bad':  /[:;]-?[\!~]/gi,
'wacko1': /[^\d]%-?\)|:\$/gi,
'good':/\*THUMBS.UP\*|\*GOOD\*/gi,
'drinks': /\*DRINK\*/gi,
'pardon':/\*PARDON\*|=\]/gi,
'nea':/\*NO\*|:\&|:-\&/gi,
'yes':/\*YES\*/gi,
'sorry':/\*SORRY\*/gi,
'bye2':/\*BYE\*/gi,
//'hi':/\*HI\*/gi,
'unknown':/\*DONT_KNOW\*|\*UNKNOWN\*/gi,
'dance':/\*DANCE\*/gi,
'crazy':/\*CRAZY\*|%-\)/gi,
'lol':/\*LOL\*|xD+|XD+/gi,
'i_am_so_happy': /:\!\)/gi,
'mad': /:\\|:-[\\\/]/gi,
'sorry':/\*SORRY\*/ig,

'greeting':[/\*HI\*/gi,'big_standart'],
'ok':[/\*OK\*/ig,'big_standart'],
'rofl':[/\*ROFL\*/ig,'big_standart'],
'scratch_one-s_head':[/\*SCRATCH\*|:-I/ig,'big_standart'],
'fool': [/:-\||:\||=\|/ig,'big_standart'],
'bomb': /@=/ig,
'new_russian':[/\\m\//ig,'big_standart'],
'scare3':[/:-@/ig,'big_standart'],
'acute':[/;D|\*ACUTE\*/ig,'big_standart'],
'heart':[/<3/ig,'light_skin'],
'secret':[/:-x/ig,'big_standart'],
'girl_devil':[/\}:o/ig,'big_he_and_she'],
'dash1':[/\*WALL\*|X-\|/ig,'big_madhouse'],
'facepalm':/\*FACEPALM\*/ig,
'help':[/[\*\!]HELP[\*\!]/ig,'big_standart'],
'spam':[/!SPAM!|SPAM,.IP.LOGGED/ig,'other'],
'flood':[/!FLOOD!/ig,'other'],
'opera':/\*OPERA\*/ig,
'firefox':/\*FIREFOX\*/ig,
'chrome':/\*CHROME\*/ig,
'windows':/\*WINDOWS\*/ig,
'linux':/\*LINUX\*/ig

//'mellow': /:-\||:\||=\|/gi,
//'kiss3': /[:;=]-\*+|[:;=]\*+/gi,
//'yahoo': /\^_\^|\^\^|\*\(\)\*/gi
//'bad': /:X|:x|:х|:Х|:-X|:-x/gi,

}
//smile array for TxtFormat
var TextPasteSmiles={
'girl_angel':'O:-)',
'smile':'=)',
'sad':'=(',
'wink':';-)',
'blum1':'=P',
'cool':' 8-)',
'biggrin':'=D',
'blush':";\\\'>",
'shok':'O_o',
'diablo':']:->',
'cray':":-\\\'(",
'mocking':'*JOKINGLY*',
'give_rose':'@}->--',
'music':'[:-}',
'kiss':':-*',
'bad':':-!',
'wacko1':'%-)',
'crazy':'*CRAZY*',
'mad':':-/',
'lol':'*LOL*',
'dance':'*DANCE* ',
'nea':'*NO*',
'yes':'*YES*',
'sorry':'*SORRY*',
'bye2':'*BYE*',
'mad': ':-/',
'pardon':'=]',
'mamba': ['=[]','big_madhouse'],
'hang1':['-:(','big_madhouse'],
'greeting':['*HI*','big_standart'],
'ok':['*OK*','big_standart'],
'rofl':['*ROFL*','big_standart'],
'scratch_one-s_head':[':-I','big_standart'],
'fool': [':-|','big_standart'],
'bomb': '@=',
'new_russian':['\\\\m\/','big_standart'],
'scare3':[':-@','big_standart'],
'acute':[';D','big_standart'],
'heart':['<3','light_skin'],
'secret':[':-x','big_standart'],
'girl_devil':['}:o','big_he_and_she'],
'dash1':['X-|','big_madhouse'],
'facepalm':'*FACEPALM*',
'help':['!HELP!','big_standart'],
//'flood':['!FLOOD!','other'],
'opera':"*Opera*",
'firefox':"*Firefox*",
'chrome':"*Chrome*",
'windows':"*Windows*",
'linux':"*Linux*"
}



	function vkInitDebugBox(){
	  var sHEIGHT=21;
	  var sWIDTH=21;
	  var HEIGHT=300;
	  var WIDTH=400;
	  LAST_LOG_MSG='';
	  LAST_EQ_LOG_MSG_COUNT=0;
	  vkaddcss('\
			#vkDebug{opacity:0}\
         #vkDebug:hover{opacity:1}\
         #vkDebug{ border: 1px solid #AAA; border-radius:5px; background:#FFF; color: #555;\
					  padding:1px;\
					  width:'+sWIDTH+'px; height:'+sHEIGHT+'px; overflow:hidden;\
					  position:fixed; z-index:1000; right:0px; top:0px;}\
			#vkDebug .debugPanel{height:'+sHEIGHT+'px; background:#F0F0F0}\
			#vkDebug .debugPanel span{line-height:18px; font-weight:bold; color:#999; padding-left:5px;}\
			#vkDebug .mbtn{background:#FFF url("/images/icons/x_icon5.gif") 0px -63px no-repeat;\
					  cursor: pointer; height: 21px; width: 21px;\
					  float:right;}\
			#vkDebug .hbtn{background:#FFF url("/images/icons/x_icon5.gif") 0px -105px no-repeat;\
					  cursor: pointer; height: 21px; width: 21px;\
					  float:right;}\
			#vkDebug .log{border: 1px solid #DDD; margin: 5px; min-width:'+(WIDTH-10)+'px; max-height:'+HEIGHT+'px; overflow:auto;}\
			#vkDebug .log DIV{border-bottom: 1px solid #EEE;}\
			#vkDebug .log DIV:hover{background:#FFB}\
			#vkDebug .log DIV .time{float:right; color: #BBB;}\
			#vkDebug .log DIV .count{background:#44F; padding:0 2px; margin-right:4px; font-size:6pt; border-radius:5px; color:#FFF; border:1px solid #00A;}\
	  ');



	  var div=document.createElement('div');
	  var panel=document.createElement('div');
	  var btn=document.createElement('div');
	  var wlog=document.createElement('div');
	  div.id='vkDebug';
	  panel.className='debugPanel';
	  btn.className='mbtn';
	  wlog.className='log';
	  wlog.id='vkDebugLogW';
	  //wlog.innerHTML='<div>log started</div>';

	  var tomax=function(){
		  var callback=function(){
			  btn.onclick=tomin;
			  btn.className='hbtn';
			  div.style.height='auto';
		  }
		  var h=getSize(wlog)[1];
		  animate(div, {height: h+sHEIGHT,width: WIDTH}, 400, callback);
	  }
	  var tomin=function(){
		  var callback=function(){
			btn.onclick=tomax;
			btn.className='mbtn';
		  }
		  animate(div, {height: sHEIGHT,width: sWIDTH}, 400, callback);
	  }
	  btn.onclick=tomax;
	  panel.appendChild(btn);
	  div.appendChild(panel);
	  div.appendChild(wlog);
	  document.getElementsByTagName('body')[0].appendChild(div);
	  vklog('Log started ('+location.pathname+location.search+')',3);
	}
	function vklog(s,type){
	  if (vk_DEBUG){


		var node=ge('vkDebugLogW');
		if (!node) return;
		var div=document.createElement('div');
		type=(type)?type:0;
		var style="";
		switch(type){
		  case 0: style=""; break;
		  case 1: style="color:#D00; font-weight:bold;"; break;
		  case 2: style="color:#080;"; break;
		  case 3: style="color:#00D;"; break;
		}

		div.setAttribute('style',style);
		div.appendChild($c("#", s));
		div.innerHTML=s+'<span class="time">'+(new Date((new Date().getTime()) - vkstarted)).format("MM:ss:L",true)+'</span>';

		if (LAST_LOG_MSG==s){
			LAST_EQ_LOG_MSG_COUNT++;
			node.lastChild.innerHTML='<span class="count">'+LAST_EQ_LOG_MSG_COUNT+'</span>'+div.innerHTML;
		} else {
			LAST_EQ_LOG_MSG_COUNT=0;
			node.appendChild(div);
		}
		node.scrollTop = node.scrollHeight;
		LAST_LOG_MSG=s;
	  }
	}

////////// INIT ////////
function vkonDOMReady(fn, ctx){
    var ready, timer;
    var __=true;
    var onChange = function(e){
		if (document.getElementById('footer') || document.getElementById('footer_wrap')) {
         fireDOMReady();
      } else if(e && e.type == "DOMContentLoaded"){
            fireDOMReady();
        }else if(e && e.type == "load"){
            fireDOMReady();
        }else if(document.readyState){
            if((/loaded|complete/).test(document.readyState)){
                fireDOMReady();
            }else if(!!document.documentElement.doScroll){
                try{
                    ready || document.documentElement.doScroll('left');
                }catch(e){
                    return;
                }
                fireDOMReady();
            }
        }
    };
    var fireDOMReady = function(){
        if(!ready){
            ready = true;
            fn.call(ctx || window);
            if(document.removeEventListener)
                document.removeEventListener("DOMContentLoaded", onChange, false);
            document.onreadystatechange = null;
            window.onload = null;
            clearInterval(timer);
            timer = null;
        }
    };
    if (__){
      if(document.addEventListener)
        document.addEventListener("DOMContentLoaded", onChange, false);
      document.onreadystatechange = onChange;
      timer = setInterval(onChange, 5);
      window.onload = onChange;
    }
};
/////////////////////////////////

function vkResetVkOptSetting(){
  vksetCookie('remixbit',DefSetBits);
  vkSetVal('remixbit',DefSetBits);
  location.reload();
}

function VkOptInit(ignore_login){
  var allow_init=true;
  if (window.StaticFiles)
   for (var key in StaticFiles){
      if (StaticFiles[key].t=='js' && StaticFiles[key].l!=1){
         allow_init=false;
         break;
      }
   }

  if (!allow_init) {setTimeout(VkOptInit,10); return;}

	if (window._vkopt_started) return;

	if (ge("quick_login") && !ignore_login) {
      ql.insertBefore(ce('div', {innerHTML: '<iframe class="upload_frame" id="quick_login_frame" name="quick_login_frame"></iframe>'}), qf);
      qf.target = 'quick_login_frame';

      //     Inj.Wait('window.vk && vk.id',function(){      VkOptMainInit();      });
      window.onLoginDone = function(loc){document.location.href=loc};//nav.reload;
		return;
	}
	VkOptMainInit();
   window._vkopt_started=true;
}

var dloc=document.location.href;
var vk_domain=document.location.host;
if (/vk\.com/.test(vk_domain) || /vkontakte\.ru/.test(vk_domain)){
   if (!/\/m\.vk\.com|login\.vk\.com|oauth\.vk\.com|al_index\.php|frame\.php|widget_.+php|notifier\.php|audio\?act=done_add/i.test(dloc)){
       vkonDOMReady(VkOptInit);
   }
}
