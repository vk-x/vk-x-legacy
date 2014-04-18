function InstallRelease(){
  if (!window.vk || !vk.id) return;
  if (isNewLib() && !window.lastWindowWidth){
      setTimeout(InstallRelease,50);
      return;
  }

  var lastUsedVersion = vkgetCookie( app.name );

  if ( lastUsedVersion !== app.version.full ) {
    if ( lastUsedVersion != null ) {
      vkCheckSettLength();
    }
    // TODO: Check app permissions and force reauth if needed.
    // app.vkApi.request({ method: "getUserSettings" });
  }

  if ( !vkGetVal( "VK_SAVE_MSG_HISTORY_PATTERN" ) ) {
      vkSetVal( "VK_SAVE_MSG_HISTORY_PATTERN", SAVE_MSG_HISTORY_PATTERN );
  }

  if ( !window.IDBit && lastUsedVersion !== app.version.full ) {
    if ( lastUsedVersion && parseInt( lastUsedVersion[ 0 ] ) !== app.version.major ) {
      vksetCookie( "remixbit", DefSetBits );
    }

	  vksetCookie( app.name, app.version.full );

	  vksetCookie('vkplayer','00-0_0');
	  if (!vkgetCookie('remixbit')) vksetCookie('remixbit',DefSetBits);
	  vkCheckSettLength();

	  if (!window.vkMsg_Box) vkMsg_Box = new MessageBox({title: app.i18n.IDL('THFI'),width:"495px"});
	  vkMsg_Box.removeButtons();
	  vkMsg_Box.addButton(!isNewLib()?{
		onClick: function(){vkMsg_Box.hide( 200 );},
		style:'button_no',label:'OK'}:'OK',function(){vkMsg_Box.hide( 200 );},'no');
    var cont = app.i18n.IDL( "YIV" ) + "<b>" + app.version.full + "</b><br><br>" + app.i18n.IDL( "INCD" ) + "<b>" + app.i18n.IDL( "FIS" ) + "</b>";

     cont+='<br><br><div id="cfg_on_serv_info" style="text-align:center;"></div>';
     vkLoadSettingsFromServer(true,function(setts){
      if (setts){
         ge('cfg_on_serv_info').innerHTML+='<br>'+vkRoundButton([app.i18n.IDL('LoadFromServer'),'javascript: vkLoadSettingsFromServer();']);
      }
     });//check cfg backup


	  vkMsg_Box.content(cont).show();

  }
  return false;
}

function vkLocalStorageMan(ret){
  if(!ret){
	  if (!window.localStorage) return false;
	  //if (!window.vkLocalStorageBox)
		vkLocalStorageBox = new MessageBox({title: app.i18n.IDL('LocalStorage')+' (vkontakte)', width:"570px"});
	  var Box = vkLocalStorageBox;
	  Box.removeButtons();
	  Box.addButton(app.i18n.IDL('Cancel'),Box.hide,'no');
	  /*{
		onClick: function(){ Box.hide(200); Box.content(""); },
		style:'button_no',label:app.i18n.IDL('Cancel')});*/
  }
  vkGetLsList=function(){
    var res='';
    for (var key in localStorage){
      if (key=='length') continue;
      res+='<div class="lsrow" id="lsrow_'+key+'" onclick="vkLsEdit(\''+key+'\')">'+
      '<div class="lskey">'+replaceChars(key)+'</div>'+
      '<div class="lsval">'+replaceChars(localStorage[key])+'</div>'+
      '</div>';
    }
    return res;
  }
  vkLsDelVal=function(key_){
    localStorage.removeItem(key_);
    ge('LsList').innerHTML=vkGetLsList();
    ge("LsEditNode").innerHTML='';
  }
  vkLsSaveVal=function(key_){
    localStorage[key_]=ge('LsValEdit').value;
    ge('LsList').innerHTML=vkGetLsList();
    //ge("LsEditNode").innerHTML='';
  }
  vkLsNewKey=function(key_){
    localStorage.removeItem(key_);
    ge('LsList').innerHTML=vkGetLsList();
    el=ge("LsEditNode");
    el.innerHTML='<u>Key:</u> <input type="text" id="LsValNameEdit"/><br>'+
                 '<u>Value:</u><br><textarea id="LsValEdit" rows=5 cols=86  style_="height:100px; width:100%;"></textarea><br>'+
                 '<div style="padding-top:5px;">'+vkRoundButton(['Save key',"javascript:vkLsSaveNewVal()"])+'</div>';

  }
  vkLsSaveNewVal=function(){
    var key_=ge('LsValNameEdit').value;
    localStorage[key_]=ge('LsValEdit').value;
    ge('LsList').innerHTML=vkGetLsList();
    vkLsEdit(key_);
    //ge("LsEditNode").innerHTML='';
  }
  vkLsEdit=function(_key){
    el=ge("LsEditNode");
    el.innerHTML='<u>Key:</u> <b>'+_key+'</b><br>'+
                 '<u>Value:</u><br><textarea id="LsValEdit" rows=5 cols=86  style_="height:100px; width:100%;">'+localStorage[_key]+'</textarea><br>'+
                 '<div style="padding-top:5px;">'+vkRoundButton(['Save key',"javascript:vkLsSaveVal('"+_key+"')"],['Delete key',"javascript:vkLsDelVal('"+_key+"')"])+'</div>';
    el=geByClass('lsrow_sel')[0];
    if (el) el.className='lsrow';
    ge('lsrow_'+_key).className='lsrow_sel';
  }
  var html='<div class="lstable" id="LsList">';
  html+=vkGetLsList();
  html+='<div style="clear:both"></div></div>';
  html+='<div style="padding-top:5px;">'+vkRoundButton(['New key',"javascript:vkLsNewKey()"])+'</div>';
  html+='<div id="LsEditNode" style="padding-top:10px;"></div>';
	if (ret)
		return html;
	else
		Box.content(html).show();
}


function vkSettingsPage(){
	vkOpt_toogle();
	if (!ge('vkopt_settings_tab') && ge('settings_filters')){
		var li=vkCe('li',{id:'vkopt_settings_tab'});
		li.innerHTML='\
			<a href="/settings?act=' + app.name + '" onclick="return checkEvent(event)" onmousedown="return vkShowSettings();">\
			<b class="tl1"><b></b></b><b class="tl2"></b>\
			<b class="tab_word">' + app.name + '</b>\
			</a>';
		ge('settings_filters').appendChild(li);
	}
}
function vkLoadVkoptConfigFromFile(){
  vkLoadTxt(function(txt){
	try {
     var cfg=eval('('+txt+')');
	  /*alert(print_r(cfg));*/
	  for (var key in cfg) if (cfg[key])
		vksetCookie(key,cfg[key]);
	  alert(app.i18n.IDL('ConfigLoaded'));
	} catch(e) {
	  alert(app.i18n.IDL('ConfigError'));
	}
  },['JSON File (vkopt config *.json)','*.json']);
}

function vkGetVkoptFullConfig(){
   var sets={
      remixbit:vkgetCookie('remixbit'),
      remixumbit:vkgetCookie('remixumbit'),
      //AdmGr:vkgetCookie('AdmGr'),
      FavList:vkGetVal('FavList'),
      menu_custom_links:vkGetVal('menu_custom_links'),
      vk_sounds_vol:vkGetVal("vk_sounds_vol") || "",
      VK_CURRENT_CSS_URL:vkGetVal('VK_CURRENT_CSS_URL'),
      VK_CURRENT_CSSJS_URL:vkGetVal('VK_CURRENT_CSSJS_URL'),
      VK_CURRENT_CSS_CODE:vkGetVal('VK_CURRENT_CSS_CODE'),
      WallsID:vkGetVal('WallsID')
   }
  /*
  var temp=[];
  for (var key in sets) if (sets[key]) temp.push(key+':'+'"'+sets[key]+'"');
  var config='{\r\n'+temp.join(',\r\n')+'\r\n}';
  */
  var config=JSON.stringify(sets);
  vkSaveText(config,'vksetts_id'+remixmid()+'.json');
  //alert(config);
}

function vkCheckSettLength(){
  s2=vkgetCookie('remixbit') || "";
  s2=s2.split('-');
  s1=DefSetBits.split('-');
  s2[0]+=s1[0].substr(s2[0].length);
  for (var i=0; i<s1.length; i++)  if (s2[i]==null && s1[i]!=null) s2[i]=s1[i];
  s2=s2.join('-');
  vksetCookie('remixbit',s2);
}

//////////////////////
/* EXTENSION SETTINGS */

// for color select //
var pickers = [];
function init_colorpicker(target, onselect, inhcolor){
// http://plugins.jquery.com/files/jquery.jqcolor.js.txt /
    function RGBToHSB(rgb) {
        var hsb = {h:0, s:0, b:0};
        hsb.b = Math.max(Math.max(rgb.r,rgb.g),rgb.b);
        hsb.s = (hsb.b <= 0) ? 0 : Math.round(100*(hsb.b - Math.min(Math.min(rgb.r,rgb.g),rgb.b))/hsb.b);
        hsb.b = Math.round((hsb.b /255)*100);
        if((rgb.r==rgb.g) && (rgb.g==rgb.b)) hsb.h = 0;
        else if(rgb.r>=rgb.g && rgb.g>=rgb.b) hsb.h = 60*(rgb.g-rgb.b)/(rgb.r-rgb.b);
        else if(rgb.g>=rgb.r && rgb.r>=rgb.b) hsb.h = 60  + 60*(rgb.g-rgb.r)/(rgb.g-rgb.b);
        else if(rgb.g>=rgb.b && rgb.b>=rgb.r) hsb.h = 120 + 60*(rgb.b-rgb.r)/(rgb.g-rgb.r);
        else if(rgb.b>=rgb.g && rgb.g>=rgb.r) hsb.h = 180 + 60*(rgb.b-rgb.g)/(rgb.b-rgb.r);
        else if(rgb.b>=rgb.r && rgb.r>=rgb.g) hsb.h = 240 + 60*(rgb.r-rgb.g)/(rgb.b-rgb.g);
        else if(rgb.r>=rgb.b && rgb.b>=rgb.g) hsb.h = 300 + 60*(rgb.r-rgb.b)/(rgb.r-rgb.g);
        else hsb.h = 0;
        hsb.h = Math.round(hsb.h);
        return hsb;
    }
    function HSBToRGB(hsb) {
        var rgb = {};
        var h = Math.round(hsb.h);
        var s = Math.round(hsb.s*255/100);
        var v = Math.round(hsb.b*255/100);
        if(s == 0) {
            rgb.r = rgb.g = rgb.b = v;
        } else {
            var t1 = v;
            var t2 = (255-s)*v/255;
            var t3 = (t1-t2)*(h%60)/60;
            if(h==360) h = 0;
            if(h<60) {rgb.r=t1; rgb.b=t2; rgb.g=t2+t3;}
            else if(h<120) {rgb.g=t1; rgb.b=t2; rgb.r=t1-t3;}
            else if(h<180) {rgb.g=t1; rgb.r=t2; rgb.b=t2+t3;}
            else if(h<240) {rgb.b=t1; rgb.r=t2; rgb.g=t1-t3;}
            else if(h<300) {rgb.b=t1; rgb.g=t2; rgb.r=t2+t3;}
            else if(h<360) {rgb.r=t1; rgb.g=t2; rgb.b=t1-t3;}
            else {rgb.r=0; rgb.g=0; rgb.b=0;}
        }
        return {r:Math.round(rgb.r), g:Math.round(rgb.g), b:Math.round(rgb.b)};
    }
    function RGBToHex(rgb) {
        var hex = [
            rgb.r.toString(16),
            rgb.g.toString(16),
            rgb.b.toString(16)
        ];
        hex = hex.map(function (val) {
            if (val.length == 1) {
                val = '0' + val;
            }
            return val;
        });
        return hex.join('');
    };

    function HexToRGB(hex) {
        var hex = parseInt(((hex.indexOf('#') > -1) ? hex.substring(1) : hex), 16);
        return {r: hex >> 16, g: (hex & 0x00FF00) >> 8, b: (hex & 0x0000FF)};
    };
//end /
    if (typeof(inhcolor) != "string") {
        inhcolor = "ff0000";
    }
    if (inhcolor.substr(0, 1) == "#") {
        inhcolor = inhcolor.substr(1, 6);
    }
    var
        incolor = HexToRGB(inhcolor);
        hsb = RGBToHSB(incolor),
        bhsb = {h: hsb.h, s: 100, b: 100};

	for(var i = pickers.length; p = pickers[--i];){
        if(p == target){
            return;
        }
    }
    pickers.push(target);
    var p_imgs = {
        boverlay: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAYAAABccqhmAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAKxSURBVHja7NoxCoRAFAXBcfD+ZzYxEkxEDXqqYC9g0Dy/OwawrO38AQuaHgGsa7cAwAIALADAAgAsAMACACwAQAAArwCABQBYAIAFAAgA4BUAsAAAAQC8AgAWACAAgAAAbgCABQAIACAAgBsAYAEAAgAIACAAwDOOgGABAAIACAAgAIAAAAIA5PgMCBYAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAcBeA6TGABQAIACAAgAAAAgAIACAAQCYA/gcAFgAgAIAAAAIACAAgAEAuAD4DggUACAAgAIAAAPEAOAKCBQAIACAAgAAA8QA4AoIFAAgAIACAAADxADgCggUACAAgAIAAAPEAOAKCBQAIACAAgBsAYAEAAgAIAOAGAFgAgAAAAgC4AQAWACAAgAAAbgCABQAIACAAgBsAYAEAAgAIACAAwAcBcAQECwAQAEAAADcAwAIABAAQAMANALAAAAEABABwAwAsAEAAAAEA3AAACwAQAEAAAAEAfg6AIyBYAIAAAAIACAAQD4AjIFgAgAAAAgAIABAPgCMgWACAAAACAAgAEA+AIyBYAIAAAAIACAAgAIAAALkA+AwIFgAgAIAAAAIACAAgAIAAAJ0A+B8AWACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIADA1fQIwAIABAAQAEAAAAEABACo8RkQLABAAAABAAQAiHMEBAsAEABAAAA3AMACAAQAEADADQCwAAABALwCABYAIACAVwDAAgAsAMACAAQA8AoAWACABQBYAIAFAFgAgAUAvOkQYABehQTISkChWgAAAABJRU5ErkJggg==",
        woverlay: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAYAAABccqhmAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAKSSURBVHja7NQ7DoAgEEDB1fufef20GgWC0DiTEAUTC5S3bIeIOEcUrqW1633N/Gmt5tnMkR3Pc/Ba73zEO3PCPnzxbWaO1v+85SzVntHbdQ3gtwQABAAQAEAAAAEABAAQAEAAAAEABAAQAEAAAAEABAAQAEAAAAEABAAQAEAAAAEABAAQAEAAAAEABAAQAEAAAAEABAAQAEAAAAEABAAQAEAAAAEAAbAFIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgC82QUYAJKU6/4c8sBCAAAAAElFTkSuQmCC",
        slider: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAEACAIAAADeB9oaAAAAAXNSR0IArs4c6QAAAAZiS0dEAP8A/wD/oL2nkwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9sGBwgFNhpkuzEAAACCSURBVGje7dtBCsQwEANBDZj9/3cTvDh/0NU197o3Mp6T8lZ+JEmSJEmSZHVzdit3m2/rDUmSJEmSJNk1WOoGS5uMJEmSJEmSt8tJO6FN2gltpU1GkiRJkiTJ2+WkndBW++RKkiRJkiR5vZzdNtic/NtizFPLlyRJkiRJ8mY59S/OD9P5jsGMLFCrAAAAAElFTkSuQmCC",
        arrows: "data:image/gif;base64,R0lGODlhKQAJAJECAP///25tbwAAAAAAACH5BAEAAAIALAAAAAApAAkAAAIvVC6py+18ggFUvotVoODwnoXNxnmfJYZkuZZp1lYx+l5zS9f2ueb6XjEgfqmIoAAAOw==",
        cursor: "data:image/gif;base64,R0lGODlhDAAMAJECAOzp2AAAAP///wAAACH5BAEAAAIALAAAAAAMAAwAAAIhlINpG+AfGFgLxEapxdns2QlfKCJgN4aWwGnR8UBZohgFADs="
    };


	var picker = $c("div", {"class":'picker_box'});
    var slider, palette, cursor, arrows, col, offsetcol, apply, cancel, val;
    picker.appendChild($c("div", {"class":'picker_panel', kids: [
        col = $c("div", {"class":'picker_color', style: "background-color: #" + inhcolor}),
        val = $c("input", {type: "input", value: "#" + inhcolor, "class":'picker_value'}),
        apply = $c("input", {type: "button", value: "OK"}),
        cancel = $c("input", {type: "button", value: app.i18n.IDL("Cancel")})
    ]}));
    offsetcol = 30;//col.offsetHeight;
    picker.appendChild(palette = $c("div", {style: "width: 256px; height: 256px; float: left; background: #" + RGBToHex(HSBToRGB(bhsb)) + ";", draggable: "false", kids: [
        $c("img",{src: p_imgs.woverlay, style: "position: absolute", draggable: "false"}),
        $c("img",{src: p_imgs.boverlay, style: "position: absolute", draggable: "false"}),
        cursor = $c("img",{src: p_imgs.cursor, id: "p_cursor", style: "position: absolute; z-index:1000; margin: -6px -2px; left: 255px;", draggable: "false"})
    ]}));
    picker.appendChild(slider = $c("div", {style: "float: left;", draggable: "false", kids: [
        arrows = $c("img",{src: p_imgs.arrows, style: "position: absolute; margin: -4px -11px; z-index: 1000", draggable: "false"}),
        $c("img",{src: p_imgs.slider, draggable: "false"})
    ]}));
    cursor.style.top = ((255 - hsb.b / 100 * 255 + 30) | 0) + "px";
    cursor.style.left = ((hsb.s / 100 * 255) | 0) + "px";
    arrows.style.top = ((hsb.h / 360 * 255) | 0 + 30) + "px";
	var mousegpos = [0, 0],
    mousenpos = [0, 0],
    mousepos = [0, 0],
    paldown = 0,
    slddown = 0,
    lock = 0,
    hue = hsb.h / 360, sat = hsb.s / 100, bri = hsb.b / 100,
    color = [1, 0, 0],
    hcolor = inhcolor,
    bhcolor = RGBToHex(HSBToRGB(bhsb)),
    heig = 255;
    function upcolor(){
        var hsb = {h: hue * 360, s: sat * 100, b: bri * 100},
            bhsb = {h: hsb.h, s: 100, b: 100};
        hcolor = "#" + RGBToHex(HSBToRGB(hsb));
        bhcolor = "#" + RGBToHex(HSBToRGB(bhsb));
        val.value = hcolor;
        col.style.backgroundColor = hcolor;
        palette.style.backgroundColor = bhcolor;
    }
    function pelettemdown(e){
        var target = e.target;
        e.preventDefault();
        if(lock){
        //    return;
        }
        lock = 1;
        if(paldown) {
            mousepos = [mousepos[0] - mousegpos[0] + (e.pageX || e.x), mousepos[1] - mousegpos[1] + (e.pageY || e.y)];
        } else {
            paldown = 1;
            window.addEventListener("mousemove", pelettemdown, true);
            window.addEventListener("mouseup", bodyup, true);
            mousepos = [(e.offsetX || e.layerX), (e.offsetY || e.layerY)];
            while(target.tagName != "DIV"){
                mousepos[0] += target.offsetLeft;
                mousepos[1] += target.offsetTop;
                target = target.parentNode;
                break;
            }
            mousepos[1] -= offsetcol;
        }
        mousegpos = [(e.pageX || e.x), (e.pageY || e.y)];
        mousenpos = [mousepos[0] < 0 ? 0 : mousepos[0] > 255 ? 255 : mousepos[0], mousepos[1] < 0 ? 0 : mousepos[1] > 255 ? 255 : mousepos[1]];
        sat = mousenpos[0] / heig;
        bri = (255 - mousenpos[1]) / heig;
        cursor.style.left = mousenpos[0] + "px";
        cursor.style.top = (mousenpos[1] + offsetcol) + "px";
        upcolor();
        lock = 0;
    }
    function slidermdown(e){
        var target = e.target;
        e.preventDefault();
        if(lock){
            return;
        }
        lock = 1;
        if(slddown){
            mousepos = [mousepos[0] - mousegpos[0] + (e.pageX || e.x), mousepos[1] - mousegpos[1] + (e.pageY || e.y)];
        }else{
            slddown = 1;
            window.addEventListener("mousemove", slidermdown, true);
            window.addEventListener("mouseup", bodyup, true);
            mousepos = [(e.offsetX || e.layerX), (e.offsetY || e.layerY - offsetcol)];
            while(target.tagName != "DIV"){
                mousepos[0] += target.offsetLeft;
                mousepos[1] += target.offsetTop;
                target = target.parentNode;
                break;
            }
            mousepos[1] -= offsetcol + 4;
        }
        mousegpos = [(e.pageX || e.x), (e.pageY || e.y)];
        mousenpos = [mousepos[0] < 0 ? 0 : mousepos[0] > 255 ? 255 : mousepos[0], mousepos[1] < 0 ? 0 : mousepos[1] > 255 ? 255 : mousepos[1]];
        hue = mousenpos[1] / heig;
        arrows.style.top = (mousenpos[1] + offsetcol) + "px";
        upcolor();
        lock = 0;
    }
    function bodyup(e){
        paldown = 0;
        slddown = 0;
        window.removeEventListener("mousemove", pelettemdown, true);
        window.removeEventListener("mousemove", slidermdown, true);
        window.removeEventListener("mouseup", bodyup, true);
    }
    function onapply(e){
        //console.log(e);
        oncancel();
        onselect(hcolor);
    }
    function oncancel(e){
        target.removeChild(picker);
        for(var i = pickers.length; p = pickers[--i];){
            if(p == target){
                pickers.splice(i, 1);
            }
        }
    }
    function valkeyup(e){
        if(!/^#[\da-f]{6}$/i.test(e.target.value)){ return; }
        hcolor = e.target.value;
        col.style.backgroundColor = hcolor;
    }
    palette.addEventListener("mousedown", pelettemdown, true);
    slider.addEventListener("mousedown", slidermdown, true);
    apply.addEventListener("click", onapply, false);
    cancel.addEventListener("click", oncancel, false);
    val.addEventListener("keyup", valkeyup, true);
    target.appendChild(picker);
}
FrCol_click=function(color){
    setFrColor(color);
    ge('spct11').style.backgroundColor = color;
}

MsgCol_click=function(color, id){
    setMsgColor(color);
    ge('spct10').style.backgroundColor = color;
}

function getMsgColor(){
  var cl=getSet('-',3);//vkgetCookie('remixbit').split('-')[9];
  return cl?cl:"#E2E9FF";
}
function setMsgColor(color) {    setSet('-',color,3); }

function getFrColor(){
  var cl=getSet('-',4);//sett.split('-')[10];
  return cl?cl:"#34A235";
}
function setFrColor(color) {
  setSet('-',color,4);
}


// end of color select func //
//////////////////////////////

////Walls
function ReadWallsCfg(){
  //alert(vkGetVal('WallsID').split(",")[0]);
  if (window.WallIDs && WallIDs.length>0 && WallIDs[0]!="") return WallIDs;
  return (vkGetVal('WallsID'))?String(vkGetVal('WallsID')).split(","):[""];//["1244","g1","g12345","1"];
}
function SetWallsCfg(cfg){
  vkSetVal('WallsID',cfg.join(","));
}
function vkAddWall(wid) {
    var wall_list=ReadWallsCfg();
    var wid = (!wid) ? ge('vkaddwallid').value: wid;
    wid = String(wid);

    if (wid.length > 0 && (wid.match(/^\d+$/i) || wid.match(/^g\d+$/i))) {
        var dub = false;
        for (var i = 0; i < wall_list.length; i++) if (String(wall_list[i]) == wid) {
            dub = true;
            break;
        }
        if (!dub) {
            wall_list[wall_list.length] = wid;
            SetWallsCfg(wall_list);
        } else {
            alert("Item Existing");
        }
        GenWallList("vkwalllist");//WallManForm();
    } else { alert('Not valid wall id'); }
}
function vkRemWall(idx){
  var res=[];
  var wall_list=ReadWallsCfg();
  for (var i=0;i<wall_list.length;i++)
    if (idx!=i){
      res[res.length]=wall_list[i];
    }
  wall_list=res;
  SetWallsCfg(wall_list);
  GenWallList("vkwalllist");
  //WallManForm();
}

function GenWallList(el){
  var wall_list=ReadWallsCfg();
  var whtml="";
  var lnk;
  for (var i=0; i<wall_list.length;i++){
      lnk=(wall_list[i][0] == 'g')?"wall.php?gid="+wall_list[i].split('g')[1]:"wall.php?id="+wall_list[i];
      if (wall_list[i]=="") {lnk="wall.php?id="+remixmid(); wall_list[i]=String(remixmid());}//
      whtml+='<div id="wit'+wall_list[i]+'" style="width:130px"><a style="position:relative; left:120px" onclick="vkRemWall('+i+')">x</a>'+i+') <a style="width:110px;" href="'+lnk+'">'+wall_list[i]+'</a></div>';
  }
  if (!el) {return whtml;} else {ge(el).innerHTML=whtml;}
}
function WallManager(){
  var wall_list=ReadWallsCfg();
  //wall_list=wall_list.sort();
  /*var whtml="";
  for (var i=0; i<wall_list.length;i++){
      whtml+='<div id="wit'+wall_list[i]+'" style="width:130px"><a>'+wall_list[i]+'</a><a style="float:right" onclick="vkRemWall('+i+')">x</a></div>';
  }*/
  var res='<a href="#" onclick="toggle(\'vkExWallMgr\'); ge(\'vkwalllist\').innerHTML=GenWallList(); return false;"><b>'+app.i18n.IDL("Settings")+'</b></a>'+
          '<div id="vkExWallMgr" style="display:none;"><div style="text-align:left;">'+//GetUserMenuSett()+'</span></span>'+
          '<input type="text" style="width:90px;" id="vkaddwallid" onkeydown="if(13==event.keyCode){vkAddWall(); this.value=\'\'; return false;}" size="20"> <a href=# onclick="vkAddWall(); return false;">'+app.i18n.IDL('add')+'</a><br>'+
          '<div id="vkwalllist">'+
          //GenWallList()+
          '</div></div><small class="divider">'+app.i18n.IDL('wallsHelp')+'</div></small>';
  return res;
}

function WallManForm(){
  ge('wallmgr').innerHTML=WallManager();
}
//end wallmgr


function vkInitSettings(){
  vkoptHiddenSets=[]
  if (!window.vk_vid_down){
    vkoptHiddenSets.push(2,66)
  }
  if (!window.vk_au_down){
    vkoptHiddenSets.push(0,1);
  }
  vkoptSets={
    Media:[
      {id:0,  text:app.i18n.IDL("seLinkAu")},
      {id:1,  text:app.i18n.IDL("seAudioDownloadName")},

      {id:2,  text:app.i18n.IDL("seLinkVi")},
      {id:66, text:app.i18n.IDL("seVidDownloadLinks")},
      {id:92,  text:app.i18n.IDL("seVideoHideConfirm")},
      {id:76, text:app.i18n.IDL("seVideoFullTitles")},

      {id:3,  text:app.i18n.IDL("seCompactAudio")},
      {id:90, text:app.i18n.IDL("seAudioFullTitles")},
      {id:73, text:app.i18n.IDL("seLoadAudioAlbumInfo")},
      {id:75, text:app.i18n.IDL("seAPlayerCtrls")},
      {id:85, text:app.i18n.IDL("seAutoScrollToTrack")},
      {id:43, text:app.i18n.IDL("seAudioSize")},
      {id:94, text:app.i18n.IDL("seAudioUntrashTitle")},

      {id:4,  text:app.i18n.IDL("seMoreDarkViewer")},
      {id:7,  text:app.i18n.IDL("seScroolPhoto")},
      {id:93, text:app.i18n.IDL("seAlbumPhotosExInfo"),info:'infoUseNetTrafic'}
    ],
    Users:[
      {id:10, text:app.i18n.IDL("seExUserMenu")+'<br><a href="#" onclick="toggle(\'vkExUMenuCFG\'); return false;">[<b> '+app.i18n.IDL("Settings")+' </b>]</a><span id="vkExUMenuCFG" style="display:none">'+GetUserMenuSett()+'</span>'},
      {id:11, text:app.i18n.IDL("seExUMClik")},
      {id:38, text:'<table><tr><td> <table><tr><td width=20 height=20 id="spct11" bgcolor='+getFrColor()+'></td></tr></table> <td>'+
         '<span class="cltool"><a onclick="init_colorpicker(this.parentNode,FrCol_click,\'' + getFrColor() + '\')">'+app.i18n.IDL("seLightFriends")+'</a></span>'+
         '</td></tr></table>'},
      {id:8, text:app.i18n.IDL("seZoomPhoto")},// {id:8, header:app.i18n.IDL("seZoomPhoto") , text:app.i18n.IDL("seZoomPhHelp"),ops:[0,1,2]},
      //{id 23 - store "is expland" profile}
      //{id:24, text:app.i18n.IDL("seAvaArrows")},
      {id:25, text:app.i18n.IDL("seICQico")},
      {id:26, text:app.i18n.IDL("seCalcAge")},
      {id:39, text:app.i18n.IDL("seGrCom")},
      {id:41, header:app.i18n.IDL("seExpland_ProfileInfo"), text:app.i18n.IDL("seExplandProfileInfoText"),ops:[0,1,2,3]},
      {id:45, text:app.i18n.IDL("seSortNam"), ops:['name','last','none']},
      {id:46,  text:app.i18n.IDL("seLoadOnl"), sub:{id:5, text:'<br>'+app.i18n.IDL("now")+': <b>%cur</b> '+app.i18n.IDL("min")+'<br>'+app.i18n.IDL("set")+': %sets',ops:[1,2,3,4,5,10,15]},ops:['au','ru']},
      {id:47, text:app.i18n.IDL("seLoadCom"), ops:["au","ru"]},
      {id:49, text:app.i18n.IDL("seFavOn")},
      {id:50, text:app.i18n.IDL("seFavOnline")+'<span style="padding-left:10px;">'+vkCheckboxSetting(57,app.i18n.IDL("seOnRightPart"))+'</span>',info:'infoUseNetTrafic'},
      {id:51, text:app.i18n.IDL("seFavToTopIm")},
      {id:52, text:app.i18n.IDL("seFaveOnline"),info:'infoUseNetTrafic'},
      {id:72, text:app.i18n.IDL("seFriendCatsOnProfile")},
      {id:87, text:app.i18n.IDL("seSearchExInfo"),info:'infoUseNetTrafic'},
      {id:91, text:app.i18n.IDL("seFaveFr"),info:'infoUseNetTrafic'},
      {id:96, text:app.i18n.IDL("seExInfoGrReq"),info:'infoUseNetTrafic'}
      //{id:65, text:app.i18n.IDL("seShowLastActivity"),info:'infoUseNetTrafic'}
    ],

    Messages:[
     {id:19, text:app.i18n.IDL("seQAns")},
	  {id:28, text:'<table><tr><td> <table><tr><td width=20 height=20 id="spct10" bgcolor=' + getMsgColor() + '></td></tr></table> <td>'+
      '<span class="cltool"><a onclick="init_colorpicker(this.parentNode,MsgCol_click,\'' + getMsgColor() + '\')">'+app.i18n.IDL("seHLMail")+'</a></span>'+
      '</td></tr></table>'},
	  {id:40, text:app.i18n.IDL("seMasDelPMsg")},
     {id:55, text:app.i18n.IDL("seIMFullTime")},
     {id:56, text:app.i18n.IDL("seIMAlwaysShowTime")},
     {id:62, text:app.i18n.IDL("seWriteBoxWithoutFastChat")},
     {id:68, text:app.i18n.IDL("seTypingNotify")},
     {id:81, text:app.i18n.IDL("seDialogsReplyBtn")},
     {id:89, text:app.i18n.IDL("seDisableIMFavicon")}
    ],
    vkInterface:[
      {id:21, text:app.i18n.IDL("seADRem")+vkCheckboxSetting(44,app.i18n.IDL("seAdNotHideSugFr"),true)},
      {id:12, text:app.i18n.IDL("seMenu")+'<br><a href="#" onclick="toggle(\'vkMenuCFG\'); return false;">[<b> '+app.i18n.IDL("Settings")+' </b>]</a><span id="vkMenuCFG" style="display:none">'+vkCheckboxSetting(80,app.i18n.IDL("seMenuToRight"),true)+'<div id="vkMenuCustom">'+vk_menu.custom_settings()+'</div></span>'},//
      {id:20, text:app.i18n.IDL("seAutoUpdMenu"),info:'infoUseNetTrafic'},
      {id:14, text:app.i18n.IDL("seLoadFrCats")},
      {id:15, header:app.i18n.IDL("seLMenuH") , text:app.i18n.IDL("seLMenuO"),ops:[0,1,2]},
      {id:29, text:app.i18n.IDL("seLMenuWallLink")},
      {id:22, text:app.i18n.IDL("seGInCol")},
      {id:13, header:app.i18n.IDL("seMyFrLink") , text:app.i18n.IDL("seMyFrLnkOps"),ops:[0,1,2]},
      {id:5, text:app.i18n.IDL("seDisableAjaxNav"),warn:true},
      {id:17, text:app.i18n.IDL("seCompactFave")},
      {id:16, text:app.i18n.IDL("seOnlineStatus"),info:'infoUseNetTrafic'},
      {id:18, header:app.i18n.IDL("seFixLeftMenu"), text:app.i18n.IDL("seFixLeftMenuText"),ops:[0,1,2]},
      {id:27, text:app.i18n.IDL("seCalend")},
      {id:30, header:app.i18n.IDL("seClockH") , text:app.i18n.IDL("seClockO"),ops:[0,1,2,3]},
      {id:31, text:app.i18n.IDL("seRightBar")+vkCheckboxSetting(37,app.i18n.IDL("seRightBarFixAsSideBar"),true)},
      {id:35, text:app.i18n.IDL("seBlocksToRightBar")},
      {id:32, text:app.i18n.IDL("seSkinManBtn") /*, hide: (vkbrowser.mozilla)*/},
      {id:33, text:app.i18n.IDL("seSmiles")+vkCheckboxSetting(63,app.i18n.IDL("seSmilesAlwaysShow"),true),warn:'seSmilesAlwaysShowWarning'},
      {id:95, text:app.i18n.IDL("seEmojiSmiles")},
      {id:36, text:app.i18n.IDL("sePreventHideNotifications")},
      //{id:42, text:app.i18n.IDL("seSortFeedPhotos")},
      {id:53, text:app.i18n.IDL("seShutProfilesBlock")},
      {id:54, header:app.i18n.IDL("seMoveNotifier") , text:app.i18n.IDL("seMoveNotifierText"),ops:[0,1,2,3]},
      {id:58, text:app.i18n.IDL("sePopupBoardInfo")},
      {id:59, text:app.i18n.IDL("seExplandGroupNews")},
      {id:60, text:app.i18n.IDL("seProfileMoveAudioBlock")},
      {id:61, text:app.i18n.IDL("seProfileGroups"),info:'infoUseNetTrafic'},
      {id:67, text:app.i18n.IDL("seHideLeftFrendsBlock")},
      {id:70, text:app.i18n.IDL("seHideBigLike")},
      {id:71, text:app.i18n.IDL("seWallReplyMod")},
      {id:74, text:app.i18n.IDL("seLeaveGroupLinks")},
      {id:79, text:vk_settings.dislikes_icons()+app.i18n.IDL("seDislikes"),info:'infoUseNetTrafic'},
      {id:86, text:app.i18n.IDL("seDisableWallWikiBox")},
      {id:88, text:app.i18n.IDL("seGroupRequestsBlock"),info:'infoUseNetTrafic'}
      //{id:64, text:app.i18n.IDL("seToTopOld")}
    ],
	Sounds:[
	  {id:48, text:app.i18n.IDL("ReplaceVkSounds")}
	],
   Help:[
     {id:69, text:app.i18n.IDL("HelpAds")}
   ],
   Others:[
		{id:9,  header:app.i18n.IDL("seTestFr"), text:app.i18n.IDL("seRefList"), sub:{id:1, text:'<br>'+app.i18n.IDL("now")+': <b>%cur</b> '+app.i18n.IDL("day")+'<br>'+app.i18n.IDL("set")+': %sets'+
            '<br><a onClick="javascript:vkFriendsCheck();" style="cursor: hand;">'+app.i18n.IDL('seCreList')+'</a>',
            ops:[1,2,3,4,5,6,7]}},
		{id:6, text:app.i18n.IDL("seOnAway")},
		{id:34, text:app.i18n.IDL("seSwichTextChr")},
      {id:77, text:app.i18n.IDL("seBatchCleaners")},
      {id:78, text:app.i18n.IDL("seCutBracket")}
   ],
   Hidden:[
      {id:82, text:app.i18n.IDL("FullThumb")},
      {id:83, text: "dislike icon", ops:[0,1,2,3]},
      {id:84, text: "feed filter" }
   ]
  };

	//LAST 96
	/*
      vkoptSets['advanced']=[
         'vk_upd_menu_timeout',
         'vkMenuHideTimeout',
         'CHECK_FAV_ONLINE_DELAY',
         'FAVE_ONLINE_BLOCK_SHOW_COUNT',
         'SHOW_POPUP_PROFILE_DELAY',
         'USERMENU_SYMBOL',
         'MOD_PROFILE_BLOCKS',
         'CUT_VKOPT_BRACKET',
         'MAIL_BLOCK_UNREAD_REQ',
         'SUPPORT_STEALTH_MOD',
         'FULL_ENCODE_FILENAME'
      ];
   */
	vkSetsType={
      "on"  :[app.i18n.IDL('on'),'y'],
      "off" :[app.i18n.IDL('of'),'n'],
      "ru"  :[app.i18n.IDL('ru'),'y'],
      "au"  :[app.i18n.IDL('au'),'n'],
      "id"  :[app.i18n.IDL('byID')  ,0],
      "name":[app.i18n.IDL('byName'),1],
      "last":[app.i18n.IDL('byFam' ),2],
      "none":[app.i18n.IDL('byNone'),3]
    };
  vksettobj();
}

vk_settings = {
   dislikes_icons:function(){
      html='\
      <div class="dislikes_icons fl_r dislike_icon_%cur">\
         <a class="post_dislike_icon dislike_icon_striked" onclick="return vk_settings.dislikes_icons_set(0,this);"></a>\
         <a class="post_dislike_icon dislike_icon_broken"  onclick="return vk_settings.dislikes_icons_set(1,this);"></a>\
         <a class="post_dislike_icon dislike_icon_crossed" onclick="return vk_settings.dislikes_icons_set(2,this);"></a>\
         <a class="post_dislike_icon dislike_icon_skull"   onclick="return vk_settings.dislikes_icons_set(3,this);"></a>\
      </div>';
      var icon_index = parseInt(getSet(83));
      if (!icon_index && icon_index!=0)
            icon_index=3;
      html = html.replace(/%cur/g,icon_index);
      return html;
   },
   dislikes_icons_set:function(idx,el){
      setCfg(83,idx);
      if (el){
        removeClass(el.parentNode,'dislike_icon_0');
        removeClass(el.parentNode,'dislike_icon_1');
        removeClass(el.parentNode,'dislike_icon_2');
        removeClass(el.parentNode,'dislike_icon_3');
        addClass(el.parentNode,'dislike_icon_'+idx);
      }
      return false;
   },
   filter:function(s){
      if (!s || trim(s)==''){
         ge('vksets_search_result').innerHTML='';
         hide('vksets_clear_inp');
         show('vksets_stoggle_btn');
         vkMakeSettings('vksetts_tabs');
         return;
      }
      hide('vksets_stoggle_btn');
      show('vksets_clear_inp');
      var cat=replaceEntities(s);
      vkCheckSettLength();

      var remixbit=vkgetCookie('remixbit');
      allsett = remixbit.split('-');
      sett = allsett[0].split('');

      for (var j = 0; j <= VK_SETTS_COUNT; j++){
         if (sett[j] == null) { if (!vkoptSetsObj[j] || !vkoptSetsObj[j][0]) sett[j] = 'n'; else sett[j] = '0'; }
      }
      allsett[0] = sett.join('');
      vksetCookie('remixbit', allsett.join('-'));

      var sets=[];
      var excluded={
         //'Sounds':1,
         'Help':1,
         'Hidden':1
      };
      for (var key in vkoptSets){
       var setts=vkoptSets[key];
       if (excluded[key]) continue;
       for (var i=0;i<setts.length;i++){
         var txt=(setts[i].text|| '').toUpperCase()+' '+(setts[i].header|| '').toUpperCase();
         s=s.toUpperCase();
         if ( txt.indexOf(s)>-1 || txt.match(s) ){// TopSearch.parseLatKeys(s)
            sets.push(setts[i]);
         }
       }
     }
     //console.log(sets);
     ge('vksetts_tabs').innerHTML='';
     ge('vksets_search_result').innerHTML='<div class="sett_cat_header">'+cat+' ('+sets.length+')</div>'+vkGetSettings(sets,allsett)+
                              (s=='EXTRA'?'<div class="sett_cat_header">Advanced/unstable settings. WARNING! DANGER!</div>'+vk_settings.cfg_override_edit():'');
     //
   },
   cfg_override: function(){
      var cfg = vkGetVal('vk_cfg_override') || '{}';
      try{
         cfg = JSON.parse(cfg);
      } catch(e){
         cfg = {}
      }
      var orig={};
      for(var i=0; i<VKOPT_CFG_LIST.length; i++){
         orig[VKOPT_CFG_LIST[i]] = window[VKOPT_CFG_LIST[i]];
         if (cfg[VKOPT_CFG_LIST[i]]==='' || cfg[VKOPT_CFG_LIST[i]]==null) continue;
         window[VKOPT_CFG_LIST[i]] = cfg[VKOPT_CFG_LIST[i]];
      }
      if (!window.VKOPT_CFG_LIST_ORIG) window.VKOPT_CFG_LIST_ORIG=orig;
   },
   cfg_override_change_val:function(el){
      var cfg = vkGetVal('vk_cfg_override') || '{}';
      try{
         cfg = JSON.parse(cfg);
      } catch(e){
         cfg = {}
      }

      var value=hasClass(el,'checkbox')?isChecked(el):val(el);
      var cfg_name=el.getAttribute('cfg');

      var type=typeof(VKOPT_CFG_LIST_ORIG[cfg_name]);
      //console.log(cfg_name,value,type);
      switch(type){
         case 'boolean':
            cfg[cfg_name]=value?true:false;
            window[cfg_name]=cfg[cfg_name];
            break;
         case 'string':
            if (cfg[cfg_name]!=null && trim(value)===''){
               //console.log('Remove: ',cfg_name,value,type);
               delete cfg[cfg_name];
            } else
               cfg[cfg_name]=value;
            break;
         case 'number':
            if (cfg[cfg_name] && parseInt(value)==NaN){
               delete cfg[cfg_name];
            } else
               cfg[cfg_name]=parseInt(value);
            break;
      }
      //if (cfg[cfg_name]!=null) window[cfg_name]=cfg[cfg_name];
      cfg = JSON.stringify(cfg);
      vkSetVal('vk_cfg_override',cfg);
   },
   cfg_override_edit: function(){
      var html='';
      // typeof(value) == 'number'
      // typeof(PHOTO_DOWNLOAD_NAMES)=='boolean'
      // typeof('qwwee')=='string'
      for(var i=0; i<VKOPT_CFG_LIST.length; i++){
         var type=typeof(VKOPT_CFG_LIST_ORIG[VKOPT_CFG_LIST[i]]);
         //console.log(type,VKOPT_CFG_LIST[i],window[VKOPT_CFG_LIST[i]]);
         html+='<tr><td>'+VKOPT_CFG_LIST[i]+'</td><td>\n';
         switch(type){
            case 'boolean':
               //html+='\t<input type="checkbox" id="cfg_'+VKOPT_CFG_LIST[i]+'"'+(window[VKOPT_CFG_LIST[i]]?' checked="on"':'')+'>\n';
               html+='\t<div class="checkbox '+(window[VKOPT_CFG_LIST[i]]?'on ':'')+'fl_l" id="cfg_'+VKOPT_CFG_LIST[i]+'" cfg="'+VKOPT_CFG_LIST[i]+'" onclick="checkbox(this); vk_settings.cfg_override_change_val(this);"><div></div></div>\n'
               break;
            case 'string':
            case 'number':
               var ev='onkeyup="vk_settings.cfg_override_change_val(this)" onpaste="vk_settings.cfg_override_change_val(this)" oncut="vk_settings.cfg_override_change_val(this)"';
               html+='\t<input type="text" id="cfg_'+VKOPT_CFG_LIST[i]+'" cfg="'+VKOPT_CFG_LIST[i]+'" '+ev+' value="'+clean((window[VKOPT_CFG_LIST[i]] || '')+'')+'">';
               break;
         }
         html+='</td></tr>\n';
      }
      html='<table id="vk_adv_settings_content">'+html+'</table>';
      html+='<div class="button_blue"><button onclick="vk_settings.cfg_override_reset();">Reset all to defaults</button></div>';
      return html;
   },
   cfg_override_reset:function(){
      if (confirm('Reset all changes in advanced setting to default values?')){
         for(var i=0; i<VKOPT_CFG_LIST.length; i++){
            window[VKOPT_CFG_LIST[i]] = window.VKOPT_CFG_LIST_ORIG[VKOPT_CFG_LIST[i]];
         }
         vkSetVal('vk_cfg_override','{}');
         ge('vk_adv_settings_content').parentNode.innerHTML=vk_settings.cfg_override_edit();
      }
   }
}
function vksettobj(s){
  vkoptSetsObj={};
  var x=0;
  for (var key in vkoptSets){
    var setts=vkoptSets[key];
    for (var i=0;i<setts.length;i++){
      x=Math.max(x,setts[i].id);
      vkoptSetsObj[setts[i].id]=[setts[i].ops,setts[i].text];
    }
  }
  VK_SETTS_COUNT=x;
}

function vkSwitchSet(id,set,ex){
  allsett=vkgetCookie('remixbit').split('-');
  sett=allsett[0].split('');
  if (ex) allsett[id]=set; else sett[id]=set;
  if (!ex){
    var el=ge('sbtns'+id);
    var html='';
    var ops=(vkoptSetsObj[id][0])?vkoptSetsObj[id][0]:["on","off"];
        for (var i=0;i<ops.length;i++){
          if (typeof ops[i]=='number'){
            var onclick="onClick=\"vkSwitchSet('"+id+"','"+ops[i]+"'); return false;\" ";
            html+='<a href="#'+id+'" '+onclick+(ops[i]==parseInt(sett[id])?'set_on':'')+'>'+ops[i]+'</a>';
          } else {
            var type=(ops[i]=='on' || ops[i]=='au')?'on':'off';//(type=='on'?'y':'n')
            if (typeof vkSetsType[ops[i]][1]=='number') type='';
            var onclick="onClick=\"vkSwitchSet('"+id+"','"+vkSetsType[ops[i]][1]+"'); return false;\" ";
            html+='<a href="#'+id+'" '+onclick+type+' '+(vkSetsType[ops[i]][1]==sett[id]?'set_on':'')+'>'+vkSetsType[ops[i]][0]+'</a>';
            //(type=='on' && sett[id]=='y') || (type=='off' && sett[id]=='n')
          }
        }
    el.innerHTML=html;
  } else {
    ge('vkcurset'+id).innerHTML=set;
  }
  allsett[0]=sett.join('');
  vksetCookie('remixbit',allsett.join('-'));
}

function vkIsNewSett(id){
  if (!window.vkNewSettsObj){
    vkNewSettsObj={};
    for(var i=0;i<vkNewSettings.length;i++) { vkNewSettsObj[vkNewSettings[i]]=true;}
  }
  if (vkNewSettsObj[id]) return true;
  else return false;
}
function vkGetSettings(setts,allsett){
  var sett = allsett[0];

  var html='';
  for (var k=0;k<setts.length;k++){
      var set=setts[k];
      if (set.hide) continue;
      var id=set.id;

      if (vkoptHiddenSets.indexOf(id)!=-1) continue;


      var ops=(set.ops)?set.ops:["on","off"];

      html+='<div id="settBlock'+id+'" class="sett_block'+(vkIsNewSett(id)?' sett_new':'')+'" '+(ops.length>2?'style="float:right; margin-right:4px;"':'')+'>'+(set.header?'<div class="scaption">'+set.header+'</div>':'')+'<div class="btns" id="sbtns'+id+'">';
      //html+='<b>'+id+': '+sett[id]+'</b><br>';
      for (var i=0;i<ops.length;i++){
        if (typeof ops[i]=='number'){
          var onclick="onClick=\"vkSwitchSet('"+id+"','"+ops[i]+"'); return false;\" ";
          html+='<a href="#'+id+'" '+onclick+(ops[i]==parseInt(sett[id])?'set_on':'')+'>'+ops[i]+'</a>';
        } else {
          var type=(ops[i]=='on' || ops[i]=='au')?'on':'off';
          if (typeof vkSetsType[ops[i]][1]=='number') type='';
          var onclick="onClick=\"vkSwitchSet('"+id+"','"+vkSetsType[ops[i]][1]+"'); return false;\" ";
          html+='<a href="#'+id+'" '+onclick+type+' '+(vkSetsType[ops[i]][1]==sett[id]?'set_on':'')+'>'+vkSetsType[ops[i]][0]+'</a>';
        }
      }
      var sub="";
	  var warn=(set.warn?'<div class="vk_warning_ico fl_r" onmouseover="vkSettInfo(this,'+(typeof set.warn=='string'?'app.i18n.IDL(\''+set.warn+'\')':'app.i18n.IDL(\'WarnSetting\')')+');"></div>':'');
     var info=(set.info?'<div class="vk_info_ico fl_r" onmouseover="vkSettInfo(this,'+(typeof set.info=='string'?'app.i18n.IDL(\''+set.info+'\')':'app.i18n.IDL(\'InfoSetting\')')+');"></div>':'');
      if (set.sub) {
        var subsets=[];
        var sops=set.sub.ops;
        for (var i=0;i<sops.length;i++) subsets.push('<a href="javascript:vkSwitchSet('+set.sub.id+','+sops[i]+',true);">'+sops[i]+'</a>');
        sub = set.sub.text.replace("%cur",'<span id="vkcurset'+set.sub.id+'">'+allsett[set.sub.id]+'</span>').replace("%sets",subsets.join(" - "));
      }
      html+='</div><div class="stext">'+warn+info +set.text+sub+'</div></div>\r\n';
  }
  return '<div style="display: inline-block; width:100%;">'+html+"</div>";

}

function vkSettInfo(el,text,hasover){
	showTooltip(el, {
		  hasover:hasover,
		  text:text,
		  slide: 15,
		  //shift: [0, -3, 0],
		  showdt: 100,
		  hidedt: 200,
	});
}
function vkCheckboxSetting(id,text,in_div){
	var cfg=getSet(id)=='y';
	return (in_div?'<div class="vk_checkbox_cont">':'')+'<input class="vk_checkbox" type="checkbox" '+(cfg?'checked="on"':'')+' style="margin-left:0px;" onchange="vkSetNY('+id+',this.checked)">'+text+(in_div?'</div>':'');
}
function vkSetNY(id,is_on){	setCfg(id,is_on?'y':'n');};


var _vk_inp_to={'__cnt_id':0};
function vkInpChange(e,obj,callback){
   //var val=trim(obj.value);
   if (!obj.id){
      obj.id='vkobjid_'+_vk_inp_to['__cnt_id'];
      _vk_inp_to['__cnt_id']= _vk_inp_to['__cnt_id']+1;
   }
   if (_vk_inp_to[obj.id]) clearTimeout(_vk_inp_to[obj.id]);
   _vk_inp_to[obj.id]=setTimeout(function(){
      callback(trim(obj.value));
   },50);
}


function vkMakeSettings(el){
  vklog('Last settings index: '+VK_SETTS_COUNT,2);
  vkCheckSettLength();

  var remixbit=vkgetCookie('remixbit');
  allsett = remixbit.split('-');
  sett = allsett[0].split('');

  for (var j = 0; j <= VK_SETTS_COUNT; j++){
	if (sett[j] == null) { if (!vkoptSetsObj[j] || !vkoptSetsObj[j][0]) sett[j] = 'n'; else sett[j] = '0'; }
  }
  allsett[0] = sett.join('');
  vksetCookie('remixbit', allsett.join('-'));

  var html="";
  var tabs=[];
  var excluded={
   'Sounds':1,
   'Help':1,
   'Hidden':1
  };
  for (var cat in vkoptSets){
    //alert(vkGetSettings(vkoptSets[cat],allsett));
	if (!excluded[cat]) tabs.push({name:app.i18n.IDL(cat),content:'<div class="sett_cat_header">'+app.i18n.IDL(cat)+'</div>'+vkGetSettings(vkoptSets[cat],allsett)});
    //html+='<div class="sett_container"><div class="sett_header" onclick="toggle(this.nextSibling);">'+app.i18n.IDL(cat)+'</div><div id="sett'+cat+'">'+vkGetSettings(vkoptSets[cat],allsett)+'</div></div>';
  }
  //*
  if (vkLocalStoreReady()){
   var currsnd=vkGetVal('sounds_name');
   currsnd=(currsnd && currsnd!=''?currsnd:app.i18n.IDL('Default'));
   var changevolume=function(v,p,u){
      var f=function(){
         if (!ge('vk_sound_vol_label')){
            setTimeout(f,100);
            return;
         }
         ge('vk_sound_vol_label').innerHTML=app.i18n.IDL('Volume')+": "+p+"%";
      }
      f();
      if (!u){
         localStorage['vk_sounds_vol']=p;
      }
   };
	var s_preview='<div class="vk_sounds_preview">'+
		'<div>'+app.i18n.IDL('SoundsThemeName')+': <b><span id="vkSndThemeName">'+currsnd+'</span></b></div>'+
		'<br><div id="vkTestSounds">'+
         '<a href="javascript: vkSound(\'Msg\')">'+app.i18n.IDL('SoundMsg')+'</a><br>'+
         '<a href="javascript: vkSound(\'New\')">'+app.i18n.IDL('SoundNewEvents')+'</a><br>'+
         '<a href="javascript: vkSound(\'On\')">'+app.i18n.IDL('SoundFavOnl')+'</a><br>'+
         (window.localStorage?'<div id="vk_sound_vol"><div id="vk_sound_vol_label"></div>'+
            vk_hor_slider.init('vk_sound_vol',100,parseInt(localStorage['vk_sounds_vol'] || 100),
               changevolume,
               function(v,p){
                  changevolume(v,p,true);
               },200)+
         '</div>':'')+
		'</div>'+
	'</div>';
    var sounds=
	'<div class="vk_sounds_settrings">'+'<div class="sett_cat_header">'+app.i18n.IDL('Sounds')+'</div>'+
	'<table><tr><td>'+vkGetSettings(vkoptSets['Sounds'],allsett)+'</td><td>'+s_preview+'</td></tr></table>'+
	'</div>'+
    '<div style_="padding: 0px 20px 0px 20px">'+
	//s_preview+
	'<div style="clear:both" align="center"><br><h4>'+app.i18n.IDL('SoundsThemeLoadClear')+'</h4><br>'+
    vkRoundButton([app.i18n.IDL('LoadSoundsTheme'),'javascript: vkLoadSoundsFromFile();'],[app.i18n.IDL('ResetSoundsDef'),'javascript: vkResetSounds();'])+'</div>'+
    '<h4><br></h4><small>'+app.i18n.IDL('SoundsThemeOnForum')+'</small>'+
    '</div>';
    tabs.push({name:app.i18n.IDL('Sounds'),content:sounds});
  }//*/
  window.vkopt_add_cfg=vkGetSettings(vkoptSets['Help'],allsett);
  var CfgArea='<input type="hidden" id="TxtEditDiv_remixbitset" /><textarea id="remixbitset" rows=1 style="border: 1px double #999999; overflow: hidden; width: 100%;" type="text" readonly onmouseover="this.value=vkRemixBitS()" onClick="this.focus();this.select();">DefSetBits=\''+vkgetCookie('remixbit')+'\';</textarea>';
  tabs.push({name:app.i18n.IDL('all'),content:'all'});
  tabs.push({name:app.i18n.IDL('Help'),content:'<table style="width:100%; border-bottom:1px solid #DDD; padding:10px;"><tr><td colspan="2" style="text-align:center; font-weight:bold; text-decoration:underline;">'+app.i18n.IDL('Donations')+'</td></tr><tr><td width="50%"><div>'+app.i18n.IDL("DevRekv")+'</div><div>'+WMPursesList('wmdonate')+'</div></td><td><div id="wmdonate" class="clear_fix">'+WMDonateForm(30,'R255120081922')+'</div></td></tr></table>'+
    '<div id="vkcurcfg">'+
    (vkbrowser.opera?'<br>'+app.i18n.IDL('SettsNotSaved')+'<b align="center">'+app.i18n.IDL('addVkopsSets')+'<br>'+CfgArea+'</b>'+
    '<br><b align="center">'+app.i18n.IDL('seAttent')+'</b>':'<b align="center">Config:<br>'+CfgArea+'</b>')+
	'</div>'+
	'<div id="vklsman"><h4 onclick="ge(\'vkcurcfg\').innerHTML=vkLocalStorageMan(true);">  </h4></div>'+
    '<div style="clear:both" align="center"><br><h4>'+app.i18n.IDL('ConfigBackupRestore')+'</h4><br>'+vkRoundButton([app.i18n.IDL('ExportSettings'),'javascript: vkGetVkoptFullConfig();'],[app.i18n.IDL('ImportSettings'),'javascript: vkLoadVkoptConfigFromFile();'])+'</div>'+
    '<div style="clear:both" align="center"><br><h4>'+app.i18n.IDL('ConfigOnServer')+'</h4>'+
	'<div id="cfg_on_serv_info" style="text-align:center;"></div>'+
	'<br>'+vkRoundButton([app.i18n.IDL('SaveOnServer'),'javascript: vkSaveSettingsOnServer();'],[app.i18n.IDL('LoadFromServer'),'javascript: vkLoadSettingsFromServer();'])+'</div>'
  });

  vkRemixBitS=function(){return "DefSetBits='"+vkgetCookie('remixbit')+"';";}
  tabs[0].active=true;
  html=vkMakeContTabs(tabs);
  if (el) ge(el).innerHTML=html;//'<div id="vksetts_search"></div><div id="vksetts_tabs">'+html+'</div>';//vkGetSettings(vkoptSets['Media'],allsett);
  else return html;
}

function vkShowSettings(box){
  var tpl='<div id="vksetts_search">\
     <div id="vksetts_sbox" style="display:none;">\
        <div class="vk_clear_input" id="vksets_clear_inp" onclick="val(\'vksetts_sinp\',\'\'); vk_settings.filter();"></div>\
        <input class="search vksetts_sinp" id="vksetts_sinp" onkeyup="vkInpChange(event, this, vk_settings.filter);" onpaste="vkInpChange(event, this, vk_settings.filter);" oncut="vkInpChange(event, this, vk_settings.filter);" onfocus="addClass(\'vksetts_sbox\', \'vksets_search_focus\');" onblur="removeClass(\'vksetts_sbox\', \'vksets_search_focus\');">\
      </div>\
      <div id="vksets_search_result"></div>\
      <div id="vksets_stoggle_btn" style="position:relative"><div style="position:absolute; right:0px; top:15px"><a class="vk_magglass_icon" href="#" onclick="toggle(\'vksetts_sbox\'); if (isVisible(\'vksetts_sbox\')) elfocus(\'vksetts_sinp\'); return false;"></a></div></div>\
  </div><div id="vksetts_tabs">%html</div>';

  vkDisableAjax();

  var header = app.name + " " + app.version.full;

  if (!box){
    show('header');
    document.title = app.name + " " + app.version.full + " settings";
    ge('header').innerHTML='<h1>'+header+'</h1>';
    ge('content').innerHTML=tpl.replace(/%html/g,'');
    vkMakeSettings('vksetts_tabs');
  } else {
    var html=tpl.replace(/%html/g,vkMakeSettings());
    if (!window.vkSettingsBox || isNewLib()) vkSettingsBox = new MessageBox({title: header,closeButton:true,width:"650px"});
    var box=vkSettingsBox;
    box.removeButtons();
    box.addButton(isNewLib()?app.i18n.IDL('Hide'):{
      onClick: function(){ box.hide(200); },
      style:'button_no',label:app.i18n.IDL('Hide')},function(){ box.hide(200); },'no');
    //box.setOptions({onHide: function(){box.content('');}});
    box.content(html).show();
  }

  vkLoadSettingsFromServer(true);//check cfg backup
  return false;
}

function vkSaveSettingsOnServer(check){
	var sett=vkgetCookie("remixbit");
	var cur_date=Math.round((new Date().getTime())/1000);
	sett+='|'+cur_date;

   var csscode=encodeURIComponent(vk_LSGetVal('VK_CURRENT_CSS_CODE') || "");
   csscode=csscode.length<4096?csscode:'';

   var cfg={
      'remixbits':sett,
      'menu_custom_links':vk_string_escape(vkGetVal('menu_custom_links') || ""),
      'vk_sounds_vol':vkGetVal("vk_sounds_vol") || "",
      //'FavList':vkGetVal('FavList'),
      'VK_CURRENT_CSS_URL':vkGetVal("VK_CURRENT_CSS_URL") || "",
      'VK_CURRENT_CSSJS_URL':vkGetVal('VK_CURRENT_CSSJS_URL') || "",
      'VK_CURRENT_CSS_CODE':csscode
   };
   var FavList=vkGetVal('FavList');
   if(FavList && FavList!='') cfg['FavList']=FavList;

   console.log('vkopt config to server:',cfg);

   var code=[];
   for (var key in cfg)
      code.push(key+':API.storage.set({key:"'+key+'",value:"'+cfg[key]+'"})');
   code="return {"+code.join(',')+"};";

   app.vkApi.request({
     method: "execute",
     data: { code: code, v: "3.0" },
     callback: function( r ) {
       ge('cfg_on_serv_info').innerHTML='<div class="vk_cfg_info">'+app.i18n.IDL('seCfgBackupSaved')+'</div>';
       console.log('Store vkopt settings result:',r);
     }
   });
}
function vkLoadSettingsFromServer(check,callback){
	var params={keys:'remixbits,FavList,menu_custom_links,vk_sounds_vol,VK_CURRENT_CSS_URL,VK_CURRENT_CSSJS_URL,VK_CURRENT_CSS_CODE'};
  if (check) params={key:'remixbits'};
  params.v = "3.0";
  app.vkApi.request({
   method: "storage.get",
   data: params,
   callback: function( r ) {
     if (check){
       if (r.response && r.response!=''){
         var cfg=r.response.split('|');
         if (cfg[1] && parseInt(cfg[1])){
           var date=(new Date(parseInt(cfg[1])*1000)).format("dd.mm.yyyy (HH:MM:ss)");
           ge('cfg_on_serv_info').innerHTML='<div class="vk_cfg_info">'+app.i18n.IDL('seCfgBackupDate')+' <b>'+date+'</b> </div>';
                if (callback) callback(true);
         } else {
           ge('cfg_on_serv_info').innerHTML='<div class="vk_cfg_warn">'+app.i18n.IDL('seCfgNoBackup')+' #1</div>';
                if (callback) callback(false);
         }
       } else {
         ge('cfg_on_serv_info').innerHTML='<div class="vk_cfg_warn">'+app.i18n.IDL('seCfgNoBackup')+' #2</div>';
             if (callback) callback(false);
       }
       } else {
       if (r.response && r.response!=''){
         var scfg={};
             for (var i=0; i<r.response.length; i++)
                scfg[r.response[i].key]=r.response[i].value;
             console.log('vkopt config from API server',scfg);
             // vkopt settings
             var cfg=scfg['remixbits'].split('|');
         vksetCookie('remixbit', cfg[0]);

             // FavList
             var val=scfg['FavList'];
             var FavList=vkGetVal('FavList');
             if (val && val!='' && FavList!=val){
                if(!FavList || FavList=='') vkSetVal('FavList',val);
                else if(confirm(app.i18n.IDL('FavListRelace'))) vkSetVal('FavList',val);
             }
             if (scfg['menu_custom_links']) vkSetVal('menu_custom_links',scfg['menu_custom_links']);
             // SkinManager settings
             if (scfg['VK_CURRENT_CSS_URL']) vkSetVal('VK_CURRENT_CSS_URL',scfg['VK_CURRENT_CSS_URL']);
             if (scfg['VK_CURRENT_CSSJS_URL']) vkSetVal('VK_CURRENT_CSSJS_URL',scfg['VK_CURRENT_CSSJS_URL']);
             if (scfg['VK_CURRENT_CSS_CODE']) vk_LSSetVal('VK_CURRENT_CSS_CODE',decodeURIComponent(scfg['VK_CURRENT_CSS_CODE']));
             if (scfg['vk_sounds_vol']) vkSetVal("vk_sounds_vol",scfg['vk_sounds_vol']);

         ge('cfg_on_serv_info').innerHTML='<div class="vk_cfg_info">'+app.i18n.IDL('seCfgRestored')+'</div>';
       } else {
         ge('cfg_on_serv_info').innerHTML='<div class="vk_cfg_error">'+app.i18n.IDL('seCfgLoadError')+' #0</div>';
       }
     }
   }
  });
}

function vkUpdateSounds(on_command){
	if (getSet(48)=='y'){
		if (!on_command) vkCmd('upd_sounds',{});
		if (window.curNotifier){
			curNotifier.sound=new Sound2('New');
			curNotifier.sound_im=new Sound2('Msg');
		}
	}
}
function vkResetSounds(){
  for (var key in vkSoundsRes) vkSetVal('sound_'+key,'');
  vkSetVal('sounds_name','');
  if(ge('vkSndThemeName')) ge('vkSndThemeName').innerHTML=app.i18n.IDL('Default');
  vkUpdateSounds();
}

function vkLoadSoundsFromFile(){
    vkLoadTxt(function(txt){
    try {
      var cfg=eval('('+txt+')');
	  //alert('qwe');
      for (var key in cfg) if (cfg[key] && vkSoundsRes[key] && key!='Name')
        vkSetVal('sound_'+key,cfg[key]);

      var tname=cfg['Name']?cfg['Name']:'N/A';
      tname=replaceChars(tname);
      vkSetVal('sounds_name',tname);
      if(ge('vkSndThemeName')) ge('vkSndThemeName').innerHTML=tname;

      alert(app.i18n.IDL('SoundsThemeLoaded'));
	  vkUpdateSounds();
    } catch(e) {
      alert(app.i18n.IDL('SoundsThemeError'));
    }
  },["VkOpt Sounds Theme (*.vksnd)","*.vksnd"]);
}
