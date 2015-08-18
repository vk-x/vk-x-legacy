/* FUNCTIONS LEVEL 0*/
///////////
function isNewLib(){return window.showWriteMessageBox}
/* CROSS */
var _ua_ = window.navigator.userAgent.toLowerCase();
var vkbrowser = {
  version: (_ua_.match( /.+(?:me|ox|on|rv|it|era|ie)[\/: ]([\d.]+)/ ) || [0,'0'])[1],
  opera: /opera/i.test(_ua_),
  msie: (/msie/i.test(_ua_) && !/opera/i.test(_ua_)),
  msie6: (/msie 6/i.test(_ua_) && !/opera/i.test(_ua_)),
  msie7: (/msie 7/i.test(_ua_) && !/opera/i.test(_ua_)),
  msie8: (/msie 8/i.test(_ua_) && !/opera/i.test(_ua_)),
  msie9: (/msie 9/i.test(_ua_) && !/opera/i.test(_ua_)),
  mozilla: /firefox/i.test(_ua_),
  chrome: /chrome/i.test(_ua_),
  safari: (!(/chrome/i.test(_ua_)) && /webkit|safari|khtml/i.test(_ua_)),
  iphone: /iphone/i.test(_ua_),
  ipod: /ipod/i.test(_ua_),
  iphone4: /iphone.*OS 4/i.test(_ua_),
  ipod4: /ipod.*OS 4/i.test(_ua_),
  ipad: /ipad/i.test(_ua_),
  android: /android/i.test(_ua_),
  bada: /bada/i.test(_ua_),
  mobile: /iphone|ipod|ipad|opera mini|opera mobi|iemobile/i.test(_ua_),
  msie_mobile: /iemobile/i.test(_ua_),
  safari_mobile: /iphone|ipod|ipad/i.test(_ua_),
  opera_mobile: /opera mini|opera mobi/i.test(_ua_),
  opera_mini: /opera mini/i.test(_ua_),
  mac: /mac/i.test(_ua_),
  linux: /linux/.test(_ua_)
}
if (window.opera) {vkbrowser.mozilla=false; vkbrowser.opera=true;}



if (vkbrowser.mozilla){
	if (window.Node)
	{
	  Node.prototype.__defineGetter__('innerText', function() {
		if (this.nodeType == 3)
		  return this.nodeValue;
		else
		{
		  var result = '';
		  for (var child = this.firstChild; child; child = child.nextSibling)
			result += child.innerText;
		  return result;
		}
	  });
	}
	if (typeof(HTMLElement) != "undefined") {
		var _emptyTags = {
		   "IMG": true,
		   "BR": true,
		   "INPUT": true,
		   "META": true,
		   "LINK": true,
		   "PARAM": true,
		   "HR": true
		};

		HTMLElement.prototype.__defineGetter__("outerHTML", function () {
		   var attrs = this.attributes;
		   var str = "<" + this.tagName;
		   for (var i = 0; i < attrs.length; i++)
			  str += " " + attrs[ i ].name + "=\"" + attrs[ i ].value + "\"";

		   if (_emptyTags[this.tagName])
			  return str + ">";

		   return str + ">" + this.innerHTML + "</" + this.tagName + ">";
		});

		HTMLElement.prototype.__defineSetter__("outerHTML", function (sHTML) {
		   var r = this.ownerDocument.createRange();
		   r.setStartBefore(this);
		   var df = r.createContextualFragment(sHTML);
		   this.parentNode.replaceChild(df, this);
		});
	}
}

if (!window.Audio){
  Audio= function(){
    this.notification    = function(){this.play  = function(){};};
    this.play  = function(){};
  }
}

/* FUNCTIONS. LEVEL 1 */
	//LANG
   function print_r( array) {
      var pad_char = " ", pad_val = 4;

      var formatArray = function (obj, cur_depth, pad_val, pad_char) {
         if(cur_depth > 0)
            cur_depth++;

         var base_pad = repeat_char(pad_val*cur_depth, pad_char);
         var thick_pad = repeat_char(pad_val*(cur_depth+1), pad_char);
         var str = "";

         if(typeof obj=='object' || typeof obj=='array' || (obj.length>0 && typeof obj!='string' && typeof obj!='number')) {
            if(!(typeof obj=='object' || typeof obj=='array'))str = '\n'+obj.toString()+'\n';
         str += '[\n';//"Array\n" + base_pad + "(\n";
            for(var key in obj) {
               if(typeof obj[key]=='object' || typeof obj[key]=='array' || (obj.length>0 && typeof obj!='string' && typeof obj!='number')) {
             str += thick_pad + ""+key+": "+((!(typeof obj=='object' || typeof obj=='array'))?'\n'+obj[key]+'\n':'')+formatArray(obj[key], cur_depth+1, pad_val, pad_char)+'\n';
               } else {
                  str += thick_pad + ""+key+": " + obj[key] + "\n";
               }
            }
            str += base_pad + "]\n";
         } else {
            str = obj.toString();
         }

         return str;
      };

      var repeat_char = function (len, _char) {
         var str = "";
         for(var i=0; i < len; i++) { str += _char; }
         return str;
      };

      var output = formatArray(array, 0, pad_val, pad_char);
         return output;
   }

   function isArray(obj) { return Object.prototype.toString.call(obj) === '[object Array]'; }
   function isFunction(obj) {return Object.prototype.toString.call(obj) === '[object Function]'; }
	function vkCutBracket(s,bracket){
      if (isArray(s)) return s;
      if (CUT_VKOPT_BRACKET || bracket==2) s=(s.substr(0,1)=='[')?s.substr(1,s.length-2):s;
      else if (bracket &&  bracket!=2) s='[ '+s+' ]';
		return s;
	}

   function vkopt_brackets(s){
      var s1=vkCutBracket(s,2);
      if (!CUT_VKOPT_BRACKET) s1='[ '+s1+' ]';
      return s1;
   }

	function replaceChars(text, nobr) {
		var res = "";
		for (var i = 0; i<text.length; i++) {
		  var c = text.charCodeAt(i);
		  switch(c) {
			case 0x26: res += "&amp;"; break;
			case 0x3C: res += "&lt;"; break;
			case 0x3E: res += "&gt;"; break;
			case 0x22: res += "&quot;"; break;
			case 0x0D: res += ""; break;
			case 0x0A: res += nobr?"\t":"<br>"; break;
			case 0x21: res += "&#33;"; break;
			case 0x27: res += "&#39;"; break;
			default:   res += ((c > 0x80 && c < 0xC0) || c > 0x500) ? "&#"+c+";" : text.charAt(i); break;
		  }
		}
		return res;
	}

   function vk_string_escape(str){
      function encodeCharx(original){
        var thecharchar=original.charAt(0);
         switch(thecharchar){
               case '\n': return "\\n"; break; //newline
               case '\r': return "\\r"; break; //Carriage return
               case '\'': return "\\'"; break;
               case '"': return "\\\""; break;
               //case '\&': return "\\&"; break;
               case '\\': return "\\\\"; break;
               case '\t': return "\\t"; break;
               //case '\b': return "\\b"; break;
               //case '\f': return "\\f"; break;

               default:
                  return original;
                  break;
         }
      }
      var preescape="" + str;
      var escaped="";
      for(var i=0;i<preescape.length;i++){
         escaped=escaped+encodeCharx(preescape.charAt(i));
      }
      return escaped;
   }
   function vkRemoveTrash(s,additional_excludes){
      additional_excludes = additional_excludes || '';
      //maybe need optimize  (collect all ranges to single string...)
      var normal_ranges={
         Ll:'\u0061-\u007a\u00aa\u00b5\u00ba\u00df-\u00f6\u00f8-\u00ff\u0101\u0103\u0105\u0107\u0109\u010b\u010d\u010f\u0111\u0113\u0115\u0117\u0119\u011b\u011d\u011f\u0121\u0123\u0125\u0127\u0129\u012b\u012d\u012f\u0131\u0133\u0135\u0137\u0138\u013a\u013c\u013e\u0140\u0142\u0144\u0146\u0148\u0149\u014b\u014d\u014f\u0151\u0153\u0155\u0157\u0159\u015b\u015d\u015f\u0161\u0163\u0165\u0167\u0169\u016b\u016d\u016f\u0171\u0173\u0175\u0177\u017a\u017c\u017e-\u0180\u0183\u0185\u0188\u018c\u018d\u0192\u0195\u0199-\u019b\u019e\u01a1\u01a3\u01a5\u01a8\u01aa\u01ab\u01ad\u01b0\u01b4\u01b6\u01b9\u01ba\u01bd-\u01bf\u01c6\u01c9\u01cc\u01ce\u01d0\u01d2\u01d4\u01d6\u01d8\u01da\u01dc\u01dd\u01df\u01e1\u01e3\u01e5\u01e7\u01e9\u01eb\u01ed\u01ef\u01f0\u01f3\u01f5\u01f9\u01fb\u01fd\u01ff\u0201\u0203\u0205\u0207\u0209\u020b\u020d\u020f\u0211\u0213\u0215\u0217\u0219\u021b\u021d\u021f\u0221\u0223\u0225\u0227\u0229\u022b\u022d\u022f\u0231\u0233-\u0239\u023c\u023f\u0240\u0242\u0247\u0249\u024b\u024d\u024f-\u0293\u0295-\u02af\u037b-\u037d\u0390\u03ac-\u03ce\u03d0\u03d1\u03d5-\u03d7\u03d9\u03db\u03dd\u03df\u03e1\u03e3\u03e5\u03e7\u03e9\u03eb\u03ed\u03ef-\u03f3\u03f5\u03f8\u03fb\u03fc\u0430-\u045f\u0461\u0463\u0465\u0467\u0469\u046b\u046d\u046f\u0471\u0473\u0475\u0477\u0479\u047b\u047d\u047f\u0481\u048b\u048d\u048f\u0491\u0493\u0495\u0497\u0499\u049b\u049d\u049f\u04a1\u04a3\u04a5\u04a7\u04a9\u04ab\u04ad\u04af\u04b1\u04b3\u04b5\u04b7\u04b9\u04bb\u04bd\u04bf\u04c2\u04c4\u04c6\u04c8\u04ca\u04cc\u04ce\u04cf\u04d1\u04d3\u04d5\u04d7\u04d9\u04db\u04dd\u04df\u04e1\u04e3\u04e5\u04e7\u04e9\u04eb\u04ed\u04ef\u04f1\u04f3\u04f5\u04f7\u04f9\u04fb\u04fd\u04ff\u0501\u0503\u0505\u0507\u0509\u050b\u050d\u050f\u0511\u0513\u0561-\u0587\u1d00-\u1d2b\u1d62-\u1d77\u1d79-\u1d9a\u1e01\u1e03\u1e05\u1e07\u1e09\u1e0b\u1e0d\u1e0f\u1e11\u1e13\u1e15\u1e17\u1e19\u1e1b\u1e1d\u1e1f\u1e21\u1e23\u1e25\u1e27\u1e29\u1e2b\u1e2d\u1e2f\u1e31\u1e33\u1e35\u1e37\u1e39\u1e3b\u1e3d\u1e3f\u1e41\u1e43\u1e45\u1e47\u1e49\u1e4b\u1e4d\u1e4f\u1e51\u1e53\u1e55\u1e57\u1e59\u1e5b\u1e5d\u1e5f\u1e61\u1e63\u1e65\u1e67\u1e69\u1e6b\u1e6d\u1e6f\u1e71\u1e73\u1e75\u1e77\u1e79\u1e7b\u1e7d\u1e7f\u1e81\u1e83\u1e85\u1e87\u1e89\u1e8b\u1e8d\u1e8f\u1e91\u1e93\u1e95-\u1e9b\u1ea1\u1ea3\u1ea5\u1ea7\u1ea9\u1eab\u1ead\u1eaf\u1eb1\u1eb3\u1eb5\u1eb7\u1eb9\u1ebb\u1ebd\u1ebf\u1ec1\u1ec3\u1ec5\u1ec7\u1ec9\u1ecb\u1ecd\u1ecf\u1ed1\u1ed3\u1ed5\u1ed7\u1ed9\u1edb\u1edd\u1edf\u1ee1\u1ee3\u1ee5\u1ee7\u1ee9\u1eeb\u1eed\u1eef\u1ef1\u1ef3\u1ef5\u1ef7\u1ef9\u1f00-\u1f07\u1f10-\u1f15\u1f20-\u1f27\u1f30-\u1f37\u1f40-\u1f45\u1f50-\u1f57\u1f60-\u1f67\u1f70-\u1f7d\u1f80-\u1f87\u1f90-\u1f97\u1fa0-\u1fa7\u1fb0-\u1fb4\u1fb6\u1fb7\u1fbe\u1fc2-\u1fc4\u1fc6\u1fc7\u1fd0-\u1fd3\u1fd6\u1fd7\u1fe0-\u1fe7\u1ff2-\u1ff4\u1ff6\u1ff7\u2071\u207f\u210a\u210e\u210f\u2113\u212f\u2134\u2139\u213c\u213d\u2146-\u2149\u214e\u2184\u2c30-\u2c5e\u2c61\u2c65\u2c66\u2c68\u2c6a\u2c6c\u2c74\u2c76\u2c77\u2c81\u2c83\u2c85\u2c87\u2c89\u2c8b\u2c8d\u2c8f\u2c91\u2c93\u2c95\u2c97\u2c99\u2c9b\u2c9d\u2c9f\u2ca1\u2ca3\u2ca5\u2ca7\u2ca9\u2cab\u2cad\u2caf\u2cb1\u2cb3\u2cb5\u2cb7\u2cb9\u2cbb\u2cbd\u2cbf\u2cc1\u2cc3\u2cc5\u2cc7\u2cc9\u2ccb\u2ccd\u2ccf\u2cd1\u2cd3\u2cd5\u2cd7\u2cd9\u2cdb\u2cdd\u2cdf\u2ce1\u2ce3\u2ce4\u2d00-\u2d25\ufb00-\ufb06\ufb13-\ufb17\uff41-\uff5a',
         Lm:'\u02b0-\u02c1\u02c6-\u02d1\u02e0-\u02e4\u02ee\u037a\u0559\u0640\u06e5\u06e6\u07f4\u07f5\u07fa\u0e46\u0ec6\u10fc\u17d7\u1843\u1d2c-\u1d61\u1d78\u1d9b-\u1dbf\u2090-\u2094\u2d6f\u3005\u3031-\u3035\u303b\u309d\u309e\u30fc-\u30fe\ua015\ua717-\ua71a\uff70\uff9e\uff9f',
         Lo:'\u01bb\u01c0-\u01c3\u0294\u05d0-\u05ea\u05f0-\u05f2\u0621-\u063a\u0641-\u064a\u066e\u066f\u0671-\u06d3\u06d5\u06ee\u06ef\u06fa-\u06fc\u06ff\u0710\u0712-\u072f\u074d-\u076d\u0780-\u07a5\u07b1\u07ca-\u07ea\u0904-\u0939\u093d\u0950\u0958-\u0961\u097b-\u097f\u0985-\u098c\u098f\u0990\u0993-\u09a8\u09aa-\u09b0\u09b2\u09b6-\u09b9\u09bd\u09ce\u09dc\u09dd\u09df-\u09e1\u09f0\u09f1\u0a05-\u0a0a\u0a0f\u0a10\u0a13-\u0a28\u0a2a-\u0a30\u0a32\u0a33\u0a35\u0a36\u0a38\u0a39\u0a59-\u0a5c\u0a5e\u0a72-\u0a74\u0a85-\u0a8d\u0a8f-\u0a91\u0a93-\u0aa8\u0aaa-\u0ab0\u0ab2\u0ab3\u0ab5-\u0ab9\u0abd\u0ad0\u0ae0\u0ae1\u0b05-\u0b0c\u0b0f\u0b10\u0b13-\u0b28\u0b2a-\u0b30\u0b32\u0b33\u0b35-\u0b39\u0b3d\u0b5c\u0b5d\u0b5f-\u0b61\u0b71\u0b83\u0b85-\u0b8a\u0b8e-\u0b90\u0b92-\u0b95\u0b99\u0b9a\u0b9c\u0b9e\u0b9f\u0ba3\u0ba4\u0ba8-\u0baa\u0bae-\u0bb9\u0c05-\u0c0c\u0c0e-\u0c10\u0c12-\u0c28\u0c2a-\u0c33\u0c35-\u0c39\u0c60\u0c61\u0c85-\u0c8c\u0c8e-\u0c90\u0c92-\u0ca8\u0caa-\u0cb3\u0cb5-\u0cb9\u0cbd\u0cde\u0ce0\u0ce1\u0d05-\u0d0c\u0d0e-\u0d10\u0d12-\u0d28\u0d2a-\u0d39\u0d60\u0d61\u0d85-\u0d96\u0d9a-\u0db1\u0db3-\u0dbb\u0dbd\u0dc0-\u0dc6\u0e01-\u0e30\u0e32\u0e33\u0e40-\u0e45\u0e81\u0e82\u0e84\u0e87\u0e88\u0e8a\u0e8d\u0e94-\u0e97\u0e99-\u0e9f\u0ea1-\u0ea3\u0ea5\u0ea7\u0eaa\u0eab\u0ead-\u0eb0\u0eb2\u0eb3\u0ebd\u0ec0-\u0ec4\u0edc\u0edd\u0f00\u0f40-\u0f47\u0f49-\u0f6a\u0f88-\u0f8b\u1000-\u1021\u1023-\u1027\u1029\u102a\u1050-\u1055\u10d0-\u10fa\u1100-\u1159\u115f-\u11a2\u11a8-\u11f9\u1200-\u1248\u124a-\u124d\u1250-\u1256\u1258\u125a-\u125d\u1260-\u1288\u128a-\u128d\u1290-\u12b0\u12b2-\u12b5\u12b8-\u12be\u12c0\u12c2-\u12c5\u12c8-\u12d6\u12d8-\u1310\u1312-\u1315\u1318-\u135a\u1380-\u138f\u13a0-\u13f4\u1401-\u166c\u166f-\u1676\u1681-\u169a\u16a0-\u16ea\u1700-\u170c\u170e-\u1711\u1720-\u1731\u1740-\u1751\u1760-\u176c\u176e-\u1770\u1780-\u17b3\u17dc\u1820-\u1842\u1844-\u1877\u1880-\u18a8\u1900-\u191c\u1950-\u196d\u1970-\u1974\u1980-\u19a9\u19c1-\u19c7\u1a00-\u1a16\u1b05-\u1b33\u1b45-\u1b4b\u2135-\u2138\u2d30-\u2d65\u2d80-\u2d96\u2da0-\u2da6\u2da8-\u2dae\u2db0-\u2db6\u2db8-\u2dbe\u2dc0-\u2dc6\u2dc8-\u2dce\u2dd0-\u2dd6\u2dd8-\u2dde\u3006\u303c\u3041-\u3096\u309f\u30a1-\u30fa\u30ff\u3105-\u312c\u3131-\u318e\u31a0-\u31b7\u31f0-\u31ff\u3400\u4db5\u4e00\u9fbb\ua000-\ua014\ua016-\ua48c\ua800\ua801\ua803-\ua805\ua807-\ua80a\ua80c-\ua822\ua840-\ua873\uac00\ud7a3\uf900-\ufa2d\ufa30-\ufa6a\ufa70-\ufad9\ufb1d\ufb1f-\ufb28\ufb2a-\ufb36\ufb38-\ufb3c\ufb3e\ufb40\ufb41\ufb43\ufb44\ufb46-\ufbb1\ufbd3-\ufd3d\ufd50-\ufd8f\ufd92-\ufdc7\ufdf0-\ufdfb\ufe70-\ufe74\ufe76-\ufefc\uff66-\uff6f\uff71-\uff9d\uffa0-\uffbe\uffc2-\uffc7\uffca-\uffcf\uffd2-\uffd7\uffda-\uffdc',
         Lt:'\u01c5\u01c8\u01cb\u01f2\u1f88-\u1f8f\u1f98-\u1f9f\u1fa8-\u1faf\u1fbc\u1fcc\u1ffc',
         Lu:'\u0041-\u005a\u00c0-\u00d6\u00d8-\u00de\u0100\u0102\u0104\u0106\u0108\u010a\u010c\u010e\u0110\u0112\u0114\u0116\u0118\u011a\u011c\u011e\u0120\u0122\u0124\u0126\u0128\u012a\u012c\u012e\u0130\u0132\u0134\u0136\u0139\u013b\u013d\u013f\u0141\u0143\u0145\u0147\u014a\u014c\u014e\u0150\u0152\u0154\u0156\u0158\u015a\u015c\u015e\u0160\u0162\u0164\u0166\u0168\u016a\u016c\u016e\u0170\u0172\u0174\u0176\u0178\u0179\u017b\u017d\u0181\u0182\u0184\u0186\u0187\u0189-\u018b\u018e-\u0191\u0193\u0194\u0196-\u0198\u019c\u019d\u019f\u01a0\u01a2\u01a4\u01a6\u01a7\u01a9\u01ac\u01ae\u01af\u01b1-\u01b3\u01b5\u01b7\u01b8\u01bc\u01c4\u01c7\u01ca\u01cd\u01cf\u01d1\u01d3\u01d5\u01d7\u01d9\u01db\u01de\u01e0\u01e2\u01e4\u01e6\u01e8\u01ea\u01ec\u01ee\u01f1\u01f4\u01f6-\u01f8\u01fa\u01fc\u01fe\u0200\u0202\u0204\u0206\u0208\u020a\u020c\u020e\u0210\u0212\u0214\u0216\u0218\u021a\u021c\u021e\u0220\u0222\u0224\u0226\u0228\u022a\u022c\u022e\u0230\u0232\u023a\u023b\u023d\u023e\u0241\u0243-\u0246\u0248\u024a\u024c\u024e\u0386\u0388-\u038a\u038c\u038e\u038f\u0391-\u03a1\u03a3-\u03ab\u03d2-\u03d4\u03d8\u03da\u03dc\u03de\u03e0\u03e2\u03e4\u03e6\u03e8\u03ea\u03ec\u03ee\u03f4\u03f7\u03f9\u03fa\u03fd-\u042f\u0460\u0462\u0464\u0466\u0468\u046a\u046c\u046e\u0470\u0472\u0474\u0476\u0478\u047a\u047c\u047e\u0480\u048a\u048c\u048e\u0490\u0492\u0494\u0496\u0498\u049a\u049c\u049e\u04a0\u04a2\u04a4\u04a6\u04a8\u04aa\u04ac\u04ae\u04b0\u04b2\u04b4\u04b6\u04b8\u04ba\u04bc\u04be\u04c0\u04c1\u04c3\u04c5\u04c7\u04c9\u04cb\u04cd\u04d0\u04d2\u04d4\u04d6\u04d8\u04da\u04dc\u04de\u04e0\u04e2\u04e4\u04e6\u04e8\u04ea\u04ec\u04ee\u04f0\u04f2\u04f4\u04f6\u04f8\u04fa\u04fc\u04fe\u0500\u0502\u0504\u0506\u0508\u050a\u050c\u050e\u0510\u0512\u0531-\u0556\u10a0-\u10c5\u1e00\u1e02\u1e04\u1e06\u1e08\u1e0a\u1e0c\u1e0e\u1e10\u1e12\u1e14\u1e16\u1e18\u1e1a\u1e1c\u1e1e\u1e20\u1e22\u1e24\u1e26\u1e28\u1e2a\u1e2c\u1e2e\u1e30\u1e32\u1e34\u1e36\u1e38\u1e3a\u1e3c\u1e3e\u1e40\u1e42\u1e44\u1e46\u1e48\u1e4a\u1e4c\u1e4e\u1e50\u1e52\u1e54\u1e56\u1e58\u1e5a\u1e5c\u1e5e\u1e60\u1e62\u1e64\u1e66\u1e68\u1e6a\u1e6c\u1e6e\u1e70\u1e72\u1e74\u1e76\u1e78\u1e7a\u1e7c\u1e7e\u1e80\u1e82\u1e84\u1e86\u1e88\u1e8a\u1e8c\u1e8e\u1e90\u1e92\u1e94\u1ea0\u1ea2\u1ea4\u1ea6\u1ea8\u1eaa\u1eac\u1eae\u1eb0\u1eb2\u1eb4\u1eb6\u1eb8\u1eba\u1ebc\u1ebe\u1ec0\u1ec2\u1ec4\u1ec6\u1ec8\u1eca\u1ecc\u1ece\u1ed0\u1ed2\u1ed4\u1ed6\u1ed8\u1eda\u1edc\u1ede\u1ee0\u1ee2\u1ee4\u1ee6\u1ee8\u1eea\u1eec\u1eee\u1ef0\u1ef2\u1ef4\u1ef6\u1ef8\u1f08-\u1f0f\u1f18-\u1f1d\u1f28-\u1f2f\u1f38-\u1f3f\u1f48-\u1f4d\u1f59\u1f5b\u1f5d\u1f5f\u1f68-\u1f6f\u1fb8-\u1fbb\u1fc8-\u1fcb\u1fd8-\u1fdb\u1fe8-\u1fec\u1ff8-\u1ffb\u2102\u2107\u210b-\u210d\u2110-\u2112\u2115\u2119-\u211d\u2124\u2126\u2128\u212a-\u212d\u2130-\u2133\u213e\u213f\u2145\u2183\u2c00-\u2c2e\u2c60\u2c62-\u2c64\u2c67\u2c69\u2c6b\u2c75\u2c80\u2c82\u2c84\u2c86\u2c88\u2c8a\u2c8c\u2c8e\u2c90\u2c92\u2c94\u2c96\u2c98\u2c9a\u2c9c\u2c9e\u2ca0\u2ca2\u2ca4\u2ca6\u2ca8\u2caa\u2cac\u2cae\u2cb0\u2cb2\u2cb4\u2cb6\u2cb8\u2cba\u2cbc\u2cbe\u2cc0\u2cc2\u2cc4\u2cc6\u2cc8\u2cca\u2ccc\u2cce\u2cd0\u2cd2\u2cd4\u2cd6\u2cd8\u2cda\u2cdc\u2cde\u2ce0\u2ce2\uff21-\uff3a',
         dash:'\u1806\u2010\u2011\u2012\u2013\u2014\u2015\u2212\u2043\u02D7\u2796\\-',
         others:'\\d\\s\.,&\?!$#%:\\(\\)\\[\\]\\{\\}+<>«»\\\\\/_\'`'
      };
      // &., -(разные дефисы)
      var rx='';
      for (var key in normal_ranges) rx+=normal_ranges[key];

      var trash_rx=new RegExp('[^'+rx+additional_excludes+']','g');
      s=s.replace(trash_rx,' ');
      s=s.replace(/\s\s+/g,' ');
      return s;
   }

   function vkCleanFileName(s){   return trim(s.replace(/[\\\/:\*\?"<>\|]/g,'_').replace(/\u2013/g,'-').replace(/&#\d+;/g,'_').replace(/\s\s/g,'').substr(0,200));   }
   function vkEncodeFileName(s){
      try {
         if (FULL_ENCODE_FILENAME)
            return encodeURIComponent(s);
         else
            return s.replace(/([^A-Za-z\u0410-\u042f\u0430-\u044f])/g,function (str, p1) {return encodeURIComponent(p1)});
      }catch(e){
         return s;
      }
   }

	function vkLinksUnescapeCyr(str){
	  var escaped=["%B8", "%E9", "%F6", "%F3", "%EA", "%E5", "%ED", "%E3", "%F8", "%F9", "%E7", "%F5", "%FA", "%F4", "%FB", "%E2", "%E0", "%EF", "%F0", "%EE", "%EB", "%E4", "%E6", "%FD", "%FF", "%F7", "%F1", "%EC", "%E8", "%F2", "%FC", "%E1", "%FE","%A8", "%C9", "%D6", "%D3", "%CA", "%C5", "%CD", "%C3", "%D8", "%D9", "%C7", "%D5", "%DA", "%D4", "%DB", "%C2", "%C0", "%CF", "%D0", "%CE", "%CB", "%C4", "%C6", "%DD", "%DF", "%D7", "%D1", "%CC", "%C8", "%D2", "%DC", "%C1", "%DE"];
	  var unescaped=["\u0451", "\u0439", "\u0446", "\u0443", "\u043a", "\u0435", "\u043d", "\u0433", "\u0448", "\u0449", "\u0437", "\u0445", "\u044a", "\u0444", "\u044b", "\u0432", "\u0430", "\u043f", "\u0440", "\u043e", "\u043b", "\u0434", "\u0436", "\u044d", "\u044f", "\u0447", "\u0441", "\u043c", "\u0438", "\u0442", "\u044c", "\u0431", "\u044e","\u0401", "\u0419", "\u0426", "\u0423", "\u041a", "\u0415", "\u041d", "\u0413", "\u0428", "\u0429", "\u0417", "\u0425", "\u042a", "\u0424", "\u042b", "\u0412", "\u0410", "\u041f", "\u0420", "\u041e", "\u041b", "\u0414", "\u0416", "\u042d", "\u042f", "\u0427", "\u0421", "\u041c", "\u0418", "\u0422", "\u042c", "\u0411", "\u042e"];
	  for (var i=0;i<escaped.length;i++)
		str=str.split(escaped[i]).join(unescaped[i]);
     str=str.replace('%23','#');
	  return str;
	}

   function vkFormatTime(t){
      var res, sec, min;
      t = Math.max(t, 0);
      sec = t % 60;
      res = (sec < 10) ? '0'+sec : sec;
      t = Math.floor(t / 60);
      min = t % 60;
      res = min+':'+res;
      t = Math.floor(t / 60);
      if (t > 0) {
         if (min < 10) res = '0' + res;
         res = t+':'+res;
      }
      return res;
   }
	function disableSelectText(node) {
		node=ge(node);
		  node.onselectstart = function() { return false; };
		node.unselectable = "on";
		if (typeof node.style.MozUserSelect != "undefined") node.style.MozUserSelect = "none";
	}
	function disableRightClick (element) {
		function preventer (event) {
			event.preventDefault();
			event.stopPropagation();
			event.cancelBubble = true;
		}

		if(element.addEventListener) {
			element.addEventListener('contextmenu', preventer, false);
		} else if(document.attachEvent) {
			element.attachEvent('oncontextmenu', preventer );
		}
	}
	function vkCe(tagName, attr,inner){
	  var el = document.createElement(tagName);
	  for (var key in attr)  el.setAttribute(key,attr[key]);
	  if (inner) el.innerHTML=inner;
	  return el;
	}

	function insertAfter(node, ref_node) {
		var next = ref_node.nextSibling;
		if (next) next.parentNode.insertBefore(node, next);
		else ref_node.parentNode.appendChild(node);
	}

	function vkNextEl(cur_el){
	  var next_el=cur_el.nextSibling
	  while(next_el && next_el.nodeType==3) next_el=next_el.nextSibling
	  return next_el;
	}
	function vkaddcss(addcss,id) {
		var styleElement = document.createElement("style");
		styleElement.type = "text/css";
      if (id) styleElement.setAttribute('mark',id);
		styleElement.appendChild(document.createTextNode(addcss));
		document.getElementsByTagName("head")[0].appendChild(styleElement);
	}

	function $c(type,params){
		if(type == "#text" || type == "#"){
			return document.createTextNode(params);
		}else if(typeof(type) == "string" && type.substr(0, 1) == "#"){
			return document.createTextNode(type.substr(1));
		}else{
			var node = document.createElement(type);
		}
		for(var i in params){
			switch(i){
				case "kids":
				for(var j in params[i]){
					if(typeof(params[i][j]) == 'object'){
						node.appendChild(params[i][j]);
					}
				}
				break;
				case "#text":
				node.appendChild(document.createTextNode(params[i]));
				break;
				case "html":
				node.innerHTML = params[i];
				break;
				default:
				node.setAttribute(i, params[i]);
			}
		}
		return node;
	}

	function $x(xpath, root) {
		   root = root ? root : document;
		   try {
				   var a = document.evaluate(xpath, root, null, 7, null);
		   } catch(e) {
				   return[];
		   }
		   var b=[];
		   for(var i = 0; i < a.snapshotLength; i++) {
				   b[i] = a.snapshotItem(i);
		   }
		   return b;
	}

	function vkLocalStoreReady(){
	  if (window.localStorage || window.GM_SetValue || window.sessionStorage) {
		return true;
	  } else {
		return false;
	  }
	}

	function vkSetVal(key,val){
	  if (typeof localStorage!='undefined') {localStorage[key]=val;}//Chrome, FF3.5+
	  else if (typeof GM_SetValue!='undefined'){ GM_SetValue(key,val); }//Mozilla
	  else if (typeof sessionStorage!='undefined'){sessionStorage.setItem(key, val);} //Opera 10.5x+
	  else { vksetCookie(key,val)}
	}

	function vkGetVal(key){
	  if (typeof localStorage!='undefined') { return localStorage[key];}//Chrome, Opera, FF3.5+
	  else if (typeof GM_GetValue!='undefined'){ return String(GM_GetValue(key)); }//Mozilla with Greasemonkey
	  else if (typeof sessionStorage!='undefined'){ return sessionStorage.getItem(key);}//Opera 10.5x+
	  else { return vkgetCookie(key)}
	}


	function vksetCookie(cookieName,cookieValue,nDays,domain){
		if (vkLocalStoreReady() && (SetsOnLocalStore[cookieName] || /api\d+_[a-z]+/.test(cookieName))){
		vkSetVal(cookieName,cookieValue);
	  } else {
		var today = new Date();
		var expire = new Date();
		if (nDays==null || nDays==0) nDays=365;
		expire.setTime(today.getTime()+ 3600000*24*nDays);
		document.cookie = cookieName+ "="+ encodeURIComponent(cookieValue)+
		";expires="+ expire.toUTCString()+
		((domain) ? ";domain=" + domain : ";domain="+location.host);
		}
		if (cookieName=='remixbit') SettBit=cookieValue;//vksetCookie('remixbit',SettBit);

	}

	function vkgetCookie(name,temp){
	  if (name=='remixbit' && SettBit && !temp) return SettBit;
	  if (name=='remixmid') { var tmp=remixmid(); if (tmp) return tmp; }
	  if (vkLocalStoreReady() && (SetsOnLocalStore[name] || /api\d+_[a-z]+/.test(name))){
		var val=vkGetVal(name);
		if (val) return val;
	  }
		var dc = document.cookie;
		var prefix = name + "=";
		var begin = dc.indexOf("; " + prefix);
		if (begin == -1){
			begin = dc.indexOf(prefix);
			if (begin != 0) return null;
		}	else	{		begin += 2;	}
		var end = document.cookie.indexOf(";", begin);
		if (end == -1)	{		end = dc.length;	}
		return decodeURIComponent(dc.substring(begin + prefix.length, end));
	}

	function delCookie(name, path, domain) {
		if ( vkgetCookie( name ) ) document.cookie = name + '=' +
		( ( path ) ? ';path=' + path : '') +
		( ( domain ) ? ';domain=' + domain : '' ) +
		';expires=Thu, 01-Jan-1970 00:00:01 GMT';
	}

  function getSet(num,type) {
      if (!SettBit) {
          SettBit = vkgetCookie('remixbit');
          if (!SettBit)
              vksetCookie('remixbit', DefSetBits); // vksetCookie изменяет SettBit, если имя 'remixbit'
      }
   if (!type) type=0;
   if (num=='-') return SettBit.split('-')[type];

    var bit=SettBit.split('-')[type].charAt(num);
   if (!bit) {
     bit=DefSetBits.split('-')[type].charAt(num);
     if (!bit) return 'n';
      }
    else return bit;
  }

	function setSet(num,val,setting) {
	if (!setting) setting=0;
	var settings=vkgetCookie('remixbit').split('-');
	if (num=='-') settings[setting]=val;
	else settings[setting] = settings[setting].replace(new RegExp('^(.{'+num+'}).'), '$1'+val);
	SettBit = settings.join('-');
	vksetCookie('remixbit',SettBit);
	}

	function setCfg(num,val) {
      setSet(num,val,0);
	}

	function vkRand(){return Math.round((Math.random() * (100000000 - 1)));}
	function unixtime() { return Math.round(new Date().getTime());}
	function getScrH(){ return window.innerHeight ? window.innerHeight : (document.documentElement.clientHeight ? document.documentElement.clientHeight : document.body.offsetHeight);}
	function getScrollTop(){ return self.pageYOffset || (document.documentElement && document.documentElement.scrollTop) || (document.body && document.body.scrollTop)}

	function inArr(arr,item){
	  for (var i=0;i<arr.length;i++)
		if (arr[i]==item) return [true,i];
	  return false;
	}

	/* Injection to JsFunctions Lib  */
	Inj={// KiberInfinity's JS_InjToFunc_Lib v1.6
		FRegEx:new RegExp("function.*\\((.*)\\)[\\s\\S]{0,1}{([\\s\\S]+)}$","im"),
		DisableHistrory:false,
		History:{},
		Wait:function(func,callback,check_timeout,check_count,fail_callback){
		  if (check_count == 0) {
			if (fail_callback) fail_callback('WaitForFunc out of allow checkes');
			return;
		  }
		  if (check_count) check_count--;
		  var func_=func;
		  if (typeof func == 'string') func_=eval(func);
		  if (!check_timeout) check_timeout=1000;
		  if (func_) callback(func_);
		  else return   setTimeout(function(){Inj.Wait(func,callback,check_timeout,check_count,fail_callback)},check_timeout);
		  return false;
		},
		Parse:function(func){
			var fn=eval('window.'+func);
			if (!fn) vklog('Inj_Error: "'+func+'" not found',1);
			var res=fn?String(fn).match(Inj.FRegEx):['','',''];
			if (Inj.need_porno()){res[2]=res[2].replace(/\r?\n/g," ");}
			return res;
		},
		Make:function(func,arg,code,args){
			var h=Array.prototype.join.call(args, '#_#');
			var hs=h.replace(/[^A-Za-z0-9]+/g,"");
			if (code.indexOf(hs)!=-1) return;
			var ac='\n_inj_label="'+hs+'";\n'
			//try{
         eval(func+'=function('+arg+'){'+ac+code+'}');
			//} catch(e){	vklog('Inj_Error: '+func+'=function('+arg+'){'+ac+code+'}',1);	}
		},
      need_porno:function(){
         return vkbrowser.mozilla && parseInt(vkbrowser.version) < 17;
      },
		toRE:function(s,m){
			if (Inj.need_porno() && (typeof s)=='string' && (s.indexOf("+'")!=-1 ||s.indexOf("'+")!=-1 || s.indexOf('"+')!=-1)){
				/* this is Porno! */
				s=s.replace(/([\(\)\[\]\\\/\.\^\$\|\?\+])/g,"\\$1");
				s=s.replace(/(["']\\\+)/g,"\\\\?[\"']\\s*\\+\\s*");
				s=s.replace(/(\\\+["'])/g,"\\s*\\+\\s*\\\\?[\"']");
				s=s.replace(/([^\[]|^)["]([^']|$)/g,"$1\\\\?[\"']$2");
				return RegExp(s,m || '');
			} else return s;
		},
		mc:function(s){
			if (Inj.need_porno()){
				if (s.substr(0,2)=="'+") s='"+'+s.substr(2);
				if (s.substr(-2)=="+'") s=s.substr(0,s.length-2)+'+"';
				return s;
			} else return s;
		},
		Start:function(func,inj_code){
		  var s=Inj.Parse(func);
		  Inj.Make(func,s[1],inj_code+' '+s[2],arguments);
		},
		End:function(func,inj_code){
		  var s=Inj.Parse(func);
		  Inj.Make(func,s[1],s[2]+' '+inj_code,arguments);
		},
		Before:function(func,before_str,inj_code){
		  var s=Inj.Parse(func);
		  before_str=Inj.toRE(before_str);
		  inj_code=Inj.mc(inj_code);
		  var orig_code=((typeof before_str)=='string')?before_str:s[2].match(before_str);
		  s[2]=s[2].split(before_str).join(inj_code+' '+orig_code+' ');//maybe split(orig_code) ?
		  //if (func=='nav.go') alert(s[2]);
		  Inj.Make(func,s[1], s[2],arguments);
		},
		After:function(func,after_str,inj_code){
		  var s=Inj.Parse(func);
		  after_str=Inj.toRE(after_str);
		  inj_code=Inj.mc(inj_code);
		  var orig_code=((typeof after_str)=='string')?after_str:s[2].match(after_str);
		  s[2]=s[2].split(after_str).join(orig_code+' '+inj_code+' ');//maybe split(orig_code) ?
		  //if (func=='stManager.add') alert(s[2]);
		  Inj.Make(func,s[1], s[2],arguments);
		},
		Replace:function(func,rep_str,inj_code){
		  var s=Inj.Parse(func);
		  s[2]=s[2].replace(rep_str,inj_code);//split(rep_str).join(inj_code);
		  Inj.Make(func,s[1], s[2],arguments);
		}
	}

	/* Storage broadcast */
	vkBroadcast={
		disabled:false,
		ignore_current_window:true, //возможность отключать реакцию отсылающей сообщение вкладки реагировать на это же сообщение.
		guid:parseInt(Math.random()*10000),
		cmd_item:'vkopt_command',
		last_cmd:'',
		handler:function(id,cmd){topMsg('<b>Maybe conflict detected</b><br>' + app.name + ' may work not correctly<br>'+JSON.stringify(cmd),4);},
		Init:function(handler){
			if (!window.localStorage && window.topMsg){
				topMsg('<b>You use old browser.</b><br>' + app.name + ' can work not correctly',4);
				vkBroadcast.disabled=true;
				return;
			}
			vkBroadcast.last_cmd=localStorage.getItem(vkBroadcast.cmd_item);
			vkBroadcast.handler=handler;
			if (vkbrowser.msie) { // Note: IE listens on document
				document.attachEvent('onstorage', vkBroadcast.onStorage, false);
			} else if (window.opera || vkbrowser.safari || vkbrowser.chrome){ // Note: Opera and WebKits listens on window
				window.addEventListener('storage', vkBroadcast.onStorage, false);
			} else { // Note: FF listens on document.body or document
				document.body.addEventListener('storage', vkBroadcast.onStorage, false);
			}
		},
		Send:function(id,params){
			if (vkBroadcast.disabled) return;
			if (!window.JSON) return;
			var cmd=JSON.stringify({id:id,cmd:params,time:unixtime(),guid:vkBroadcast.guid});
			localStorage.setItem(vkBroadcast.cmd_item, cmd);
			if (window.opera || vkbrowser.safari || vkbrowser.chrome) { // Note: Opera and WebKits don't fire storage event on event source window
				vkBroadcast.onStorage();
			}
		},
		onStorage:function(){
			var cur_cmd=localStorage.getItem(vkBroadcast.cmd_item);
			if (cur_cmd!=vkBroadcast.last_cmd){
				vkBroadcast.last_cmd=cur_cmd;
				var x=JSON.parse(cur_cmd);
				var id=x.id;
				var cmd=x.cmd;
				if (vkBroadcast.ignore_current_window && x.guid==vkBroadcast.guid) return;
				vkBroadcast.handler(id,cmd);
			}
		}
	};
	vkCmd=vkBroadcast.Send;

	function vkGenDelay(base_timeout,more_delay,base_rnd,more_ms){
		base_rnd = base_rnd==null?3000:base_rnd;
		more_ms = more_ms==null?3000:more_ms;
		var d=base_timeout+parseInt(Math.random()*base_rnd);
		if (more_delay) d+=more_ms;
		return d;
	}

/**
 * TODO: Remove these functions completely; use app.ajax directly.
 */

function AjGet( url, callback ) {
  app.ajax.get({ url: url, callback: callback, cache: ENABLE_CACHE });
  return true;
}

function AjPost( url, data, callback ) {
  app.ajax.post({ url: url, data: data, callback: callback, cache: ENABLE_CACHE });
  return true;
}

function AjCrossAttachJS( url ) {
  var evalScript = function( script ) {
    window.eval( script );
  };
  app.ajax.get({ url: url, callback: evalScript });
  return true;
}



String.prototype.leftPad = function (l, c) {
	return new Array(l - this.length + 1).join(c || '0') + this;
};

/// begin color functions
	function rgb2hex(rgb) {
		//rgbcolor=Array(255,15,45)
		return "#".concat(rgb[0].toString(16).leftPad(2), rgb[1].toString(16).leftPad(2), rgb[2].toString(16).leftPad(2));
	}

	function hex2rgb(hexcolor) {
		//example hexcolor='#34A235' or hexcolor='34A235'
		var hex = hexcolor;
		if(hex.substr(0, 1) == "#"){ hex = hex.substr(1); }
      if (hex.length==3) hex=hex.replace(/([A-Z0-9])([A-Z0-9])([A-Z0-9])/i,'$1$1$2$2$3$3');
		return [parseInt(hex.substr(0, 2), 16), parseInt(hex.substr(2, 2), 16), parseInt(hex.substr(4, 2), 16)];
	}

/// end of color functions

/* FUNCTIONS. LEVEL 2*/

/* VK GUI */

	function vkProgressBar(val,max,width,text){
			if (val>max) val=max;
			var pos=(val*100/max).toFixed(2).replace(/\.00/,'');
			var perw=(val/max)*width;
			text=(text || '%').replace("%",pos+'%');
			return '<div class="vkProg_Bar vkPB_Frame" style="width: '+perw+'px;">'+
					'<div class="vkProg_Bar vkProg_BarFr" style="width: '+width+'px;">'+text+'</div>'+
				'</div>'+
				'<div  class="vkProg_Bar vkProg_BarBgFrame" style="width: '+width+'px;">'+
					'<div class="vkProg_Bar vkProg_BarBg" style="width: '+width+'px;">'+text+'</div>'+
				'</div>';
	}

	function vkRoundButton(){ //vkRoundButton(['caption','href'],['caption2','href2'])
	  var html='<div>';//'<ul class="nNav" style="display:inline-block">';
	  for (var i=0;i<arguments.length;i++){
		var param=arguments[i];
		/*html+='<li><b class="nc"><b class="nc1"><b></b></b><b class="nc2"><b></b></b></b><span class="ncc">'+
			  '<a href="'+param[1]+'">'+param[0]+'</a>'+
			  '</span><b class="nc"><b class="nc2"><b></b></b><b class="nc1"><b></b></b></b></li>';*/
		html+='<a class="vk_button" href="'+param[1]+'">'+param[0]+'</a>';
	  }
	  html+='</div>'//'</ul>';
	  return html;
	}
	function vkButton(caption,onclick_attr,gray){
		return '<div class="button_'+(gray?'gray':'blue')+'"><button onclick="' + (onclick_attr?onclick_attr:'') + '">'+caption+'</button></div>';
	}

	function vkMakePageList(cur,end,href,onclick,step,without_ul){
	 var after=2;
	 var before=2;
	 if (!step) step=1;
	 var html=(!without_ul)?'<ul class="page_list">':'';
		if (cur>before) html+='<li><a href="'+href.replace(/%%/g,0)+'" onclick="'+onclick.replace(/%%/g,0)+'">&laquo;</a></li>';
		var from=Math.max(0,cur-before);
		var to=Math.min(end,cur+after);
		for (var i=from;i<=to;i++){
		  html+=(i==cur)?'<li class="current">'+(i+1)+'</li>':'<li><a href="'+href.replace(/%%/g,(i*step))+'" onclick="'+onclick.replace(/%%/g,(i*step))+'">'+(i+1)+'</a></li>';
		}
		if (end-cur>after) html+='<li><a href="'+href.replace(/%%/g,end*step)+'" onclick="'+onclick.replace(/%%/g,end*step)+'">&raquo;</a></li>';
	  html+=(!without_ul)?'</ul>':'';
	  return html;
	}

	function vkMakeTabs(menu,return_ul_element){
	  vkTabsSwitch = function(el){
		var nodes=geByClass("activeLink",el.parentNode);
		if (nodes[0]) nodes[0].className="";
		el.className="activeLink";
	  };
	  //vkaddcss();
	  var html='';
	  for (var i=0;i<menu.length;i++){
		/*
		html+='<li '+(menu[i].active?"class='activeLink'":"")+' onclick="vkTabsSwitch(this);">'+
			  '<a href="'+menu[i].href+'" '+(menu[i].onclick?'onclick="'+menu[i].onclick+'"':"")+(menu[i].id?'id="'+menu[i].id+'"':"")+'><b class="tl1"><b></b></b><b class="tl2"></b>'+
			  '<b class="tab_word">'+menu[i].name+'</b></a></li>';
		//*/
		//*
		html+='<li '+(menu[i].active?"class='activeLink'":"")+' onclick="vkTabsSwitch(this);">'+
			  '<a href="'+menu[i].href+'" '+(menu[i].onclick?'onclick="'+menu[i].onclick+'"':"")+(menu[i].id?'id="'+menu[i].id+'"':"")+'>'+
			  '<b class="tab_word">'+menu[i].name+'</b></a></li>';
		//*/
	  }

	  if (!return_ul_element){
		//html='<ul class="t0">'+html+'</ul>';
		html='<ul class="vk_tab_nav">'+html+'</ul>';
		return html;
	  } else {
		var ul=document.createElement("ul");
		ul.className="vk_tab_nav";
		ul.innerHTML=html;
		return ul;
	  }
	}

	function vkMakeContTabs(trash){
	  if (!window.vkContTabsCount) {
		vkContTabsCount=1;
		vkaddcss(".activetab{display:block} .noactivetab{display:none} ")
	  } else vkContTabsCount++;
	  var j=vkContTabsCount;
	  vkContTabsSwitch=function(idx,show_all){
			var ids=idx.split("_");
			if (show_all){
			  nodes=geByClass("noactivetab",ge('tabcontainer'+ids[0])).slice();
        for (var i=0; i<nodes.length; i++)
				nodes[i].className="activetab";
			} else {
			  var nodes=geByClass("activetab",ge('tabcontainer'+ids[0])).slice();
			  for (var i=0; i<nodes.length; i++) nodes[i].className="noactivetab";
			  //while(nodes[0]) nodes[0].className="noactivetab";
			}

		   var el=ge("tabcontent"+idx);
		   //if (!show_all)
		   el.className=(!show_all)?"activetab":"noactivetab";
	  }
	  var menu=[];
	  var tabs="";
	  for (var i=0;i<trash.length;i++){
		  menu.push({name:trash[i].name,href:'#',id:'ctab'+j+'_'+i, onclick:"this.blur(); vkContTabsSwitch('"+j+'_'+i+"'"+(trash[i].content=='all'?',true':'')+"); return false;",active:trash[i].active});
		  tabs+='<div id="tabcontent'+j+'_'+i+'" class="'+(!trash[i].active?'noactivetab':'activetab')+'">'+trash[i].content+'</div>';
	  }
	  return '<div class="clearFix vk_tBar">'+vkMakeTabs(menu)+'<div style="clear:both"></div></div><div id="tabcontainer'+j+'" style="padding:1px;">'+tabs+'</div>';
	}
	// javascript: ge('content').innerHTML=vkMakeContTabs([{name:'Tab',content:'Tab1 text',active:true},{name:'Qaz(Tab2)',content:'<font size="24px">Tab2 text:qwere qwere qwee</font>'}]); void(0);

vk_hor_slider={
 default_percent:50,
 callbacks:[null],
 upd_callbacks:[null],
 init:function(id,max_value,value,callback,on_update,width){
   var el=ge(id);
   var rh=false;
   if (!el){
      el=vkCe('div',{id:id, style:"width:"+(width || 100)+"px; opacity:0.01;"});
      document.getElementsByTagName('body')[0].appendChild(el);
      rh=true;
   }
   var cback='';
   if (callback){
      vk_hor_slider.callbacks.push(callback);
      cback=' callback="'+(vk_hor_slider.callbacks.length-1)+'" ';
   }
   var ucback='';
   if (on_update){
      vk_hor_slider.upd_callbacks.push(on_update);
      ucback=' ucallback="'+(vk_hor_slider.upd_callbacks.length-1)+'" ';
   }
   var div=vkCe('div',{"id":id+"_slider_wrap",
                       "class":"vk_slider_wrap",
                       "style":"position:relative; width:"+(width || getSize(el,true)[0])+"px;"},'\
         <div id="'+id+'_slider_scale" class="vk_slider_scale" onmousedown="vk_hor_slider.sliderScaleClick(event,this);" slider_id="'+id+'" max_value="'+max_value+'" '+cback+ucback+'>\
           <input type="hidden" id="'+id+'_select">\
           <input type="hidden" id="'+id+'_position">\
           <div id="'+id+'_slider_line" class="vk_slider_line"><!-- --></div>\
           <div id="'+id+'_slider" class="vk_slider" onmousedown="vk_hor_slider.sliderClick(event,this.parentNode);"><!-- --></div>\
         </div>\
         ');
   el.appendChild(div);
   max_value = max_value || 100;
   value=value || 0;
   var percent= value * 100 / max_value;
   vk_hor_slider.sliderUpdate(percent,value,id);
   if (rh){
      var sr=el.innerHTML;
      el.parentNode.removeChild(el);
      return sr;

   }
 },
 sliderScaleClick: function (e,el) {
    var id=el.getAttribute("slider_id");
    if (checkEvent(e)) return;
    var slider = ge(id+'_slider'),
        maxVal=parseInt(el.getAttribute("max_value")) || 0,
        scale = slider.parentNode,
        maxX = (scale.clientWidth || 100) - slider.offsetWidth,
        margin = Math.max(0, Math.min(maxX, (e.offsetX || e.layerX) - slider.offsetWidth / 2)),
        percent = margin / maxX * 100,
        position = margin / maxX * maxVal;

    setStyle(id+'_slider', 'marginLeft', margin);
    vk_hor_slider.sliderUpdate(percent,position,id);
    vk_hor_slider.sliderClick(e,el);
  },
  sliderClick: function (e,el) {
    var id=el.getAttribute("slider_id");
    if (checkEvent(e)) return;
    e.cancelBubble = true;

    var startX = e.clientX || e.pageX,
        slider = ge(id+'_slider'),
        maxVal=parseInt(el.getAttribute("max_value")) || 0,
        scale = slider.parentNode,
        startMargin = slider.offsetLeft || 0,
        maxX = (scale.clientWidth || 100) - slider.offsetWidth,
        selectEvent = 'mousedown selectstart',
        margin, percent,position;

    var _temp = function (e) {
      margin = Math.max(0, Math.min(maxX, startMargin + (e.clientX || e.pageX)- startX));
      percent = margin / maxX * 100;
      position = margin / maxX * maxVal;


      if (maxVal<100){
         percent = Math.round(position)*100/maxVal;
         position = percent / 100 * maxVal;
      }
      /*
      if (Math.abs(percent - 100) < 9) {
        percent = 100;
      }
      if (defPercent > 0 && Math.abs(percent - defPercent) < 3) {
        percent = defPercent;
      }
      */


      percent = intval(percent);
      margin = maxX * percent / 100;
      slider.style.marginLeft = margin + 'px';
      vk_hor_slider.sliderUpdate(percent,position,id);
      return cancelEvent(e);
    }, _temp2 = function () {
      removeEvent(document, 'mousemove', _temp);
      removeEvent(document, 'mouseup', _temp2);
      removeEvent(document, selectEvent, cancelEvent);
      setStyle(bodyNode, 'cursor', '');
      setStyle(scale, 'cursor', '');
      vk_hor_slider.sliderApply(id);
    };

    addEvent(document, 'mousemove', _temp);
    addEvent(document, 'mouseup', _temp2);
    addEvent(document, selectEvent, cancelEvent);
    setStyle(bodyNode, 'cursor', 'pointer');
    setStyle(scale, 'cursor', 'pointer');
  },
  sliderUpdate: function (percent, val,id) {
      percent = intval(percent);
      ge(id+'_select').value=percent;
      ge(id+'_position').value=val;

      var slider = ge(id+'_slider'),
      maxX = (slider.parentNode.clientWidth || 100) - slider.offsetWidth;
      setStyle(id+'_slider', 'marginLeft', maxX * percent / 100);

      var cid=parseInt(ge(id+'_slider_scale').getAttribute('ucallback'));
      if (cid) vk_hor_slider.upd_callbacks[cid](parseInt(ge(id+'_position').value),parseInt(ge(id+'_select').value));
  },
  sliderApply: function (id) {
   var cid=parseInt(ge(id+'_slider_scale').getAttribute('callback'));
   if (cid) vk_hor_slider.callbacks[cid](parseInt(ge(id+'_position').value),parseInt(ge(id+'_select').value));
  }
}

vk_v_slider={
 default_percent:50,
 callbacks:[null],
 upd_callbacks:[null],
 init:function(id,max_value,value,callback,on_update,height){
   var el=ge(id);
   var rh=false;
   if (!el){
      el=vkCe('div',{id:id, style:"height:"+(height || 100)+"px; opacity:0.01;"});
      document.getElementsByTagName('body')[0].appendChild(el);
      rh=true;
   }
   var cback='';
   if (callback){
      vk_v_slider.callbacks.push(callback);
      cback=' callback="'+(vk_v_slider.callbacks.length-1)+'" ';
   }
   var ucback='';
   if (on_update){
      vk_v_slider.upd_callbacks.push(on_update);
      ucback=' ucallback="'+(vk_v_slider.upd_callbacks.length-1)+'" ';
   }
	var h=(height || getSize(el,true)[1]);
   var div=vkCe('div',{"id":id+"_slider_wrap",
                       "class":"vk_vslider_wrap",
                       "style":"position:relative; height:"+h+"px;"},'\
         <div id="'+id+'_slider_scale" class="vk_vslider_scale" style="height: '+h+'px;"  onmousedown="vk_v_slider.sliderScaleClick(event,this);" slider_id="'+id+'" max_value="'+max_value+'" '+cback+ucback+'>\
           <input type="hidden" id="'+id+'_select">\
           <input type="hidden" id="'+id+'_position">\
           <div id="'+id+'_slider_line" style="height: '+h+'px;" class="vk_vslider_line">\
				<div id="'+id+'_slider_line_bg" class="vk_vslider_line_bg"></div>\
				<!-- -->\
		   </div>\
           <div id="'+id+'_slider" class="vk_vslider" onmousedown="vk_v_slider.sliderClick(event,this.parentNode);"><!-- --></div>\
         </div>\
         ');
   el.appendChild(div);
   max_value = max_value || 100;
   value=value || 0;
   var percent= value * 100 / max_value;
   vk_v_slider.sliderUpdate(percent,value,id);
   if (rh){
      var sr=el.innerHTML;
      el.parentNode.removeChild(el);
      return sr;

   }
 },
 sliderScaleClick: function (e,el) {
    var id=el.getAttribute("slider_id");
    disableSelectText(el);
    disableSelectText(ge(id+'_slider'));
    disableSelectText(ge(id+'_slider_line'));
    disableSelectText(ge(id+'_slider_line_bg'));

    if (checkEvent(e)) return;
    var slider = ge(id+'_slider'),
		h = ge(id+'_slider_line').offsetHeight,
		halfH=(slider.offsetHeight / 2),
        maxVal=parseInt(el.getAttribute("max_value")) || 0,
        scale = slider.parentNode,
        maxY = (scale.clientHeight || 100) /*- slider.offsetHeight*/,
        margin = Math.max(0, Math.min(maxY, (e.offsetY || e.layerY))),
        percent = 100 - (margin / maxY * 100),
        position = Math.max(0,(h-margin)) / maxY * maxVal;

    setStyle(id+'_slider', 'marginTop', margin-halfH);
	setStyle(id+'_slider_line_bg', {'marginTop': Math.floor(margin), 'height':Math.ceil(h-margin)});
	// id+'_slider_line_bg' 100px height:70px;  margin-top:30px
    vk_v_slider.sliderUpdate(percent,position,id);
    vk_v_slider.sliderClick(e,el);
  },
  sliderClick: function (e,el) {
    var id=el.getAttribute("slider_id");
    if (checkEvent(e)) return;
    e.cancelBubble = true;

    var startY = e.clientY || e.pageY,
        slider = ge(id+'_slider'),
		halfH=(slider.offsetHeight / 2),
        maxVal=parseInt(el.getAttribute("max_value")) || 0,
        scale = slider.parentNode,
        startMargin = (slider.offsetTop+halfH) || 0,
        maxY = (scale.clientHeight || 100) /*- slider.offsetHeight*/,
        selectEvent = 'mousedown selectstart',
        margin, percent,position,h;

    var _temp = function (e) {
      h = ge(id+'_slider_line').offsetHeight;
	  margin = Math.max(0, Math.min(maxY, startMargin + (e.clientY || e.pageY)- startY));
      percent = 100 - (margin / maxY * 100);
      position = Math.max(0,(h-margin)) / maxY * maxVal;
      if (maxVal<100){
         percent = Math.round(position)*100/maxVal;
      }
      percent = intval(percent);
      position = Math.round(percent / 100 * maxVal);
      margin = maxY * (100-percent) / 100;
      slider.style.marginTop = (margin-halfH) + 'px';
	  //console.log(percent,position);
      vk_v_slider.sliderUpdate(percent,position,id);
      return cancelEvent(e);
    }, _temp2 = function () {
      removeEvent(document, 'mousemove', _temp);
      removeEvent(document, 'mouseup', _temp2);
      removeEvent(document, selectEvent, cancelEvent);
      setStyle(bodyNode, 'cursor', '');
      setStyle(scale, 'cursor', '');
      vk_v_slider.sliderApply(id);
    };

    addEvent(document, 'mousemove', _temp);
    addEvent(document, 'mouseup', _temp2);
    addEvent(document, selectEvent, cancelEvent);
    setStyle(bodyNode, 'cursor', 'pointer');
    setStyle(scale, 'cursor', 'pointer');
  },
  sliderUpdate: function (percent, val,id) {
      percent = intval(percent);
      ge(id+'_select').value=percent;
      ge(id+'_position').value=val;

      var slider = ge(id+'_slider'),
	  halfH =slider.offsetHeight / 2,
      maxY = (slider.parentNode.clientHeight || 100) - halfH/*- slider.offsetHeight*/,
      margin= maxY * (100-percent) / 100;
	  setStyle(id+'_slider', 'marginTop', margin-halfH);
	  //console.log(percent, val,'\n',margin,halfH, slider.style.marginTop);
	  setStyle(id+'_slider_line_bg', {'marginTop': Math.floor(margin), 'height':Math.ceil(ge(id+'_slider_line').offsetHeight-margin)});
		// id+'_slider_line_bg' 100px height:70px;  margin-top:30px
      var cid=parseInt(ge(id+'_slider_scale').getAttribute('ucallback'));
      if (cid) vk_v_slider.upd_callbacks[cid](parseInt(ge(id+'_position').value),parseInt(ge(id+'_select').value));
  },
  sliderApply: function (id) {
   var cid=parseInt(ge(id+'_slider_scale').getAttribute('callback'));
   if (cid) vk_v_slider.callbacks[cid](parseInt(ge(id+'_position').value),parseInt(ge(id+'_select').value));
  }
}

//vk_v_slider.init('photos_albums_container',100,20,function(){},function(){},100);

/*END OF VK GUI*/

function vkSetMouseScroll(el,next,back){
 addEvent(ge(el),'mousewheel DOMMouseScroll',function(e){//
      e = e ? e : window.event;
      var wheelData = e.detail ? e.detail * -1 : e.wheelDelta / 40;
      if (Math.abs(wheelData)>100) { wheelData=Math.round(wheelData/100); }
      if (wheelData<0) next(e); else back(e);
      return cancelEvent(e);
 });
}

vkApis={
    /* получение всех фотографий из альбома aid владельца oid через API.
     * callback: function( [{pid, src}, ...] )
     * progress: function(cur, total)
     */
    photos: function (oid, aid, callback, progress) {
        var result = [];
        var total = 0;      // Общее количество фотографий
        var PER_REQ = 1000; // Ограничение Вконтакта (см. https://vk.com/dev/photos.get)
        var run = function (i) {
            if (isFunction(progress)) progress(i * PER_REQ, total);
            var params = {owner_id: oid,
                          album_id: aid,
                          offset: i * PER_REQ,
                          count: PER_REQ,
                          v: '4.1'};
            app.vkApi.request({
                method: "photos.get",
                data: params,
                callback: function (r) {
                    total = r.response[0];
                    for (var j = 1; j < r.response.length; j++)
                        result.push({pid: r.response[j].pid,
                              src: r.response[j].src_xxxbig
                                || r.response[j].src_xxbig
                                || r.response[j].src_xbig
                                || r.response[j].src_big
                                || r.response[j].src
                                || r.response[j].src_small});
                    if (++i * PER_REQ < total)  //Условие продолжения рекурсии - количество обработанных записей меньше общего количества
                        run(i);
                    else
                        callback(result);
                }
            });
        }
        run(0);
    },
	photos_hd:function(oid,aid,callback,progress){
		var listId=(aid=='tag' || aid=='photos') ?  aid+oid : "album"+oid+"_"+aid;
      if (aid==null) listId=oid;
		var PER_REQ=10;
		var cur=0;
		var count=0;
      var from=0;
      var to=0;
		var photos=[];
		var temp={};
      if (!isFunction(callback)){
         var params=callback;
         callback=params.callback;
         progress=params.progress;
         from=params.from;
         to=params.to;
         if (from) cur=from;
      }

		var get=function(){
			if (progress) progress(cur,count);
			ajax.post('al_photos.php', {act: 'show', list: listId, offset: cur}, {
            onDone: function(listId, ph_count, offset, data) {
               if (!count) count=ph_count;
               for(var i=0; i<data.length;i++){
                  if (temp[data[i].id]) continue;
                  temp[data[i].id]=true;
                  var p=data[i];
                  var max_src= p.w_src || p.z_src || p.y_src || p.x_src;
                  //p.max_src=max_src;
                  photos.push(max_src);//p
                  data[i]=null;
                  p=null;
               }
               if (!to) to=count;
               if (cur<Math.min(to,count)){
                  cur+=PER_REQ;
                  setTimeout(nxt,50); // активируем костыль
                  //setTimeout(get,50);
               } else callback(photos);
            },
            onFail: function(){
               //alert('Request failed..\n'+arguments);
               console.log(arguments);
               setTimeout(function(){next=true;},5000); // активируем костыль
            }
         });
		}
      var next=true;
      var nxt=function(){next=true;};
      setInterval(function(){ // знаю... этот ужасный костыль для избежания наращивания стека вызовов...
         if (!next) return;
         next=false;
         get();
      },100);
	},

    /* получение всех фотографий владельца oid с группировкой по альбомам.
     * callback: function( [{title, list: [{pid, src}, ...]}, ...] )
     * progress: function(cur, total) для альбомов и фоток внутри них
     */
    albums: function (oid, callback, progress_albums, progress_photos) {
        var result = [];
        var data;   // здесь будет инфа об альбомах, полученная из API
        var run = function (i) {
            if (isFunction(progress_albums)) progress_albums(i, data.length);
            if (i == data.length)   // условие окончания рекурсии
                callback(result);
            else if (data[i].size > 0) {
                switch (data[i].aid) {  // замена отрицательных айдишников системных альбомов на пригодные к скачиванию.
                    case -6:    data[i].aid = 'profile'; break;
                    case -7:    data[i].aid = 'wall'; break;
                    case -15:   data[i].aid = 'saved'; break;
                }
                vkApis.photos(oid, data[i].aid, function (_list) {
                    result.push({title: data[i].title, list: _list});
                    run(++i);   // продолжение рекурсии. рекурсия здесь используется для превращения асинхронного цикла в синхронный.
                }, progress_photos);
            } else run(++i);
        };

        app.vkApi.request({
            method: "photos.getAlbums",
            data: {oid: oid, need_system: 1},
            callback: function (r) {
                data = r.response;
                if (data) run(0);   // запуск рекурсии с первого альбома.
                else callback(result);
            }
        });
    },
   faves:function(callback){
      AjGet('/fave?section=users&al=1',function(t){
         var r=t.match(/"faveUsers"\s*:\s*(\[[^\]]+\])/);
         if (r){
            r=eval('('+r[1]+')');
            var onlines=[];
            for(var i=0;i<r.length;i++) if(r[i].online) onlines.push(r[i]);
            callback(r,onlines);
         } else callback(null,null);
      });
   }
}

function base64_encode(str){ var res = '';    var c1, c2, c3, e1, e2, e3, e4;    var key = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";    var i = 0; while(i < str.length)   {   c1 = str.charCodeAt(i++);  c2 = str.charCodeAt(i++);  c3 = str.charCodeAt(i++);  e1 = c1 >> 2;   e2 = ((c1 & 3) << 4) | (c2 >> 4);  e3 = ((c2 & 15) << 2) | (c3 >> 6);  e4 = c3 & 63;  if(isNaN(c2)) {e3 = e4 = 64;} else if(isNaN(c3)){ e4 = 64;}   res += key.charAt(e1) + key.charAt(e2) + key.charAt(e3) + key.charAt(e4);} return res;}
function utf8_encode ( str_data ) {
	str_data = str_data.replace(/\r\n/g,"\n");
	var utftext = "";
	for (var n = 0; n < str_data.length; n++) {
		var c = str_data.charCodeAt(n);
		if (c < 128) {
			utftext += String.fromCharCode(c);
		} else if((c > 127) && (c < 2048)) {
			utftext += String.fromCharCode((c >> 6) | 192);
			utftext += String.fromCharCode((c & 63) | 128);
		} else {
			utftext += String.fromCharCode((c >> 12) | 224);
			utftext += String.fromCharCode(((c >> 6) & 63) | 128);
			utftext += String.fromCharCode((c & 63) | 128);
		}
	}
	return utftext;
}

 function utf8ToWindows1251(str){ //function from SaveFrom.Net extension
    var res = '', i = 0, c = 0, c2 = 0;
    var a = {
      208: {
        160: 208, 144: 192, 145: 193, 146: 194,
        147: 195, 148: 196, 149: 197, 129: 168,
        150: 198, 151: 199, 152: 200, 153: 201,
        154: 202, 155: 203, 156: 204, 157: 205,
        158: 206, 159: 207, 161: 209, 162: 210,
        163: 211, 164: 212, 165: 213, 166: 214,
        167: 215, 168: 216, 169: 217, 170: 218,
        171: 219, 172: 220, 173: 221, 174: 222,
        175: 223, 176: 224, 177: 225, 178: 226,
        179: 227, 180: 228, 181: 229, 182: 230,
        183: 231, 184: 232, 185: 233, 186: 234,
        187: 235, 188: 236, 189: 237, 190: 238,
        191: 239
      },

      209: {
        145: 184, 128: 240, 129: 241, 130: 242,
        131: 243, 132: 244, 133: 245, 134: 246,
        135: 247, 136: 248, 137: 249, 138: 250,
        139: 251, 140: 252, 141: 253, 142: 254,
        143: 255
      }
    };
    while(i < str.length){
      c = str.charCodeAt(i);
      if(c < 128){
        res += String.fromCharCode(c);
        i++;
      } else if((c > 191) && (c < 224)){
        if(c == 208 || c == 209){
          c2 = str.charCodeAt(i + 1);
          if(a[c][c2]) res += String.fromCharCode(a[c][c2]);
          else res += '?';
        } else res += '?';
        i += 2;
      } else {
        res += '?';
        i += 3;
      }
    }
    return res;
}

function vkFileSize(size,c){
	c = (c==null)?2:c;
	var x=[]; x[c]=''; x='.'+x.join('0');
	var filesizename = [" Bytes", " KB", " MB", " GB", " TB", " PB", " EB", " ZB", " YB"];
	return size ? (size/Math.pow(1024, (i = Math.floor(Math.log(size)/Math.log(1024))))).toFixed(c).replace(x,'')+filesizename[i] : '0 Bytes';
}

// DATA SAVER
var VKFDS_SWF_LINK='http://cs6147.vk.me/u13391307/c0b944fc2c34a1.zip';
var VKFDS_SWF_HTTPS_LINK='https://pp.vk.me/c6147/u13391307/c0b944fc2c34a1.zip';

var VKTextToSave="QweQwe Test File"; var VKFNameToSave="vkontakte.txt";

function vkOnSaveDebug(t,n){/*alert(n+"\n"+t)*/}
function vkOnResizeSaveBtn(w,h){ // Вызывается из флешки как и vkOnSaveDebug
			ge("vkdatasaver").setAttribute("height",h);
			ge("vkdatasaver").setAttribute("width",w+2);
			hide("vkdsldr"); show("vksavetext");
			return {text:VKTextToSave,name:VKFNameToSave};
}
function vkSaveText(text,fname){
  app.saveFile.saveText({ text: text, filename: fname });
}

//END DATA SAVER

// DATA LOADER
var VKFDL_SWF_LINK='http://cs6147.vk.me/u13391307/8f4dac1239fc88.zip';
var VKFDL_SWF_HTTPS_LINK='https://pp.vk.me/c6147/u13391307/8f4dac1239fc88.zip';

function vkLoadTxt(callback,mask){
	DataLoadBox = new MessageBox({title: app.i18n.IDL('LoadFromFile')});
	var Box = DataLoadBox;

	vkOnDataLoaded=function(text){
		//alert(text);
      Box.hide();
		setTimeout(function(){callback(text);},10);
	}
	vkOnInitDataLoader=function(w,h){
	  ge("vkdataloader").style.width=w+2;
			ge("vkdataloader").style.height=h;
			hide("vkdlldr"); show("vkloadtext");
	}
	var html = '<div><span id="vkdlldr"><div class="box_loader"></div></span>'+
		 '<span id="vkloadtext" style="display:none">'+app.i18n.IDL("ClickForLoad")+'</span>'+
		 '<div id="dlcontainer" style="display:inline-block;position:relative;top:8px;"></div>'+
		 '</div>';
	Box.removeButtons();
	Box.addButton(app.i18n.IDL('Cancel'),Box.hide,'no');
	Box.content(html).show();
   var swf=location.protocol=='https:'?VKFDL_SWF_HTTPS_LINK:VKFDL_SWF_LINK;

	var params={width:100, height:29, "allowscriptaccess":"always","wmode":"transparent","preventhide":"1","scale":"noScale"};
	var vars={'idl_browse':app.i18n.IDL('Browse'),'mask_name':mask[0],'mask_ext':mask[1]};
	renderFlash('dlcontainer',
		{url:swf,id:"vkdataloader"},
		params,vars
	);
}
//END DATA LOADER

function vkDisableAjax(){
  if (window.nav && nav.go) Inj.Before('nav.go',"var _a = window.audioPlayer","{ location.href='/'+strLoc; return true;};");
}


function vkWnd(text,title){
	var url='about:blank';
	var as_data=true;
	text = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\"><html>" +
		"<head><title>" + ( title ? title : app.name ) + "</title></head>" +
		"<body>" + text + "</body></html>";
	if (as_data){
		url='data:text/html;charset=utf-8,'+encodeURIComponent(text);//charset=utf-8,
	}
	var wnd	= window.open(url, '_blank', '');//dialog,width=300,height=150,scrollbars=yes
	if (!as_data){
		var doc	= wnd.document;
		doc.write(text);
		doc.close();
	}
	wnd.focus();
}

function vkMsg(text,show_timeout){
	if (!show_timeout) show_timeout=1000;
	var showDoneBox=function(msg, opts){
	  opts = opts || {};
	  var l = (opts.w || 380) + 20;
	  var styles="z-index:9999;";
	  var style = ' style="'+(opts.w ? 'width: ' + opts.w + 'px; ' : '')+styles+'"';
	  var pageW = bodyNode.offsetWidth,
		  resEl = ce('div', {
		  className: 'top_result_baloon_wrap fixed',
		  innerHTML: '<div class="top_result_baloon"' + style + '>' + msg + '</div>'
	  }, {left: (pageW - l) / 2});
	  resEl.setAttribute('style','z-index:9999; '+resEl.getAttribute('style'));
	  bodyNode.insertBefore(resEl, ge('page_wrap'));
	  boxRefreshCoords(resEl);
	  var out = opts.out || 1000;
	  setTimeout(function () {
		fadeOut(resEl.firstChild, 500, function () {
		  re(resEl);
		  if (opts.callback) {
			opts.callback();
		  }
		});
	  }, out);
	}
	showDoneBox(text,{out: show_timeout});
}

vkLdr={
	box:null,
	show:function(){
		vkLdr.box=new MessageBox({title:''});
		vkLdr.box.setOptions({title: false, hideButtons: true,onHide:__bq.hideLast}).show();
		hide(vkLdr.box.bodyNode);
		show(boxLoader);
		boxRefreshCoords(boxLoader);
	},
	hide:function(){
		vkLdr.box.hide();
		hide(boxLoader);
	}
}

function vkAlertBox(title, text, callback, confirm) {// [callback] - "Yes" or "Close" button; [confirm] - "No" button
  var aBox = new MessageBox({title: title});
  aBox.removeButtons();
  if (confirm) {
   aBox.addButton(getLang('box_no'),function(){  aBox.hide(); if (isFunction(confirm)) confirm();	 }, 'no').addButton(getLang('box_yes'),function(){  aBox.hide(); if (callback) callback();	 },'yes');
  } else {
    aBox.addButton(getLang('box_close'),callback?function(){aBox.hide(); callback();}:aBox.hide);
  }
  aBox.content(text);
  return aBox.show();
}
//Download with normal name by dragout link
function vkDragOutFile(el) {
    var a = el.getAttribute("href");
    var d = el.getAttribute("download");
    var url='';
    var name='';
    if (a.indexOf("&/") != -1) {
        a = a.split("&/");
        url=a[0];
        name=d || a[1];
        a = ":" + name + ":" + url;
        //alert(a);
    } else {
        a = ':'+(d?d:'')+':' + a
    }
    el.addEventListener("dragstart", function(e) {
        e.dataTransfer.setData("DownloadURL", a);//
    },false);
}
function vkDownloadFile(el,ignore) {
  // See #140.
  return true;
}

/* NOTIFY TOOLS */
function vkShowNotify(params){
   params = params || {};
   var vk_nf_id=unixtime()+vkRand();//window.vk_nf_id || 0;
   params.id='vk_nf_id_'+vk_nf_id;//(++);
   params.type='vkopt';
   Inj.Wait('curNotifier.version',function(){
      var notify=[
         curNotifier.version,
         params.type,
         params.title || '',
         params.author_photo || '',
         params.author_link || false,
         params.text || '',
         params.add_photo || '',// WTF?
         params.link,
         params.onclick,
         params.add,
         params.id
      ];
      Notifier.lcSend('feed',{events:[notify.join('<!>')],full:true,sound:params.sound});
      Notifier.pushEvents([notify.join('<!>')],false,params.sound);
   });
}

//*
_vk_notifiers={};
function vkHideEvent(id){
   if (_vk_notifiers[id]){
      Notifier.lcSend('hide', {event_id: id+_vk_notifiers[id]});
      Notifier.onEventHide(id+_vk_notifiers[id]);
   }
}
function vkShowEvent(obj){ // vkShowEvent({id:'vk_typing_123',title:'%USERNAME%', text:'Typing...',author_photo:'http://cs9994.userapi.com/u39226536/e_62b2fd31.jpg'})
   obj=obj || {};
   var vk_nf_id=unixtime()+vkRand();
   var id=obj.id || 'vk_nf_id_'+vk_nf_id;

   Inj.Wait('curNotifier.version',function(){

      if (_vk_notifiers[id]){
         Notifier.lcSend('hide', {event_id: id+_vk_notifiers[id]});
         Notifier.onEventHide(id+_vk_notifiers[id]);
      }
      if (!_vk_notifiers[id]) _vk_notifiers[id]=0;
      _vk_notifiers[id]++;
      id=id+_vk_notifiers[id];

      var msg=[
         curNotifier.version,
         obj.type || 'vkcustomnotifier',
         obj.title || "",
         obj.author_photo || "",
         obj.author_link || "",
         obj.text,
         obj.add_photo || "",
         obj.link,
         obj.onclick,
         obj.add,
         id,
         obj.author_id || "",
         obj.custom || ""
      ];
      var events=[msg.join('<!>')];

      var response={events:events,sound:obj.sound};
      Notifier.lcSend('feed',extend({
                                       full: curNotifier.idle_manager && curNotifier.idle_manager.is_idle && !Notifier.canNotifyUi(),
                                       key: curNotifier.key
                                    }, response));
      curNotifier.timestamp = vkNow();
      if (!obj.hide_in_current_tab){
         Notifier.pushEvents(events,false,obj.sound);
      }
   });
}

/* FOR VKOPT PLUGINS */
if (!window.vkopt_plugins) vkopt_plugins={};

vk_plugins={
	run:function(PLUGIN_ID){
		var p=vkopt_plugins[PLUGIN_ID];
		if (p.init) p.init();
		if (p.css) vkaddcss(p.css);
		if (p.onLocation) vkOnNewLocation();
		if (p.onLibFiles) {
		  for (var key in StaticFiles)  if (key.indexOf('.js') != -1) vkInj(key);
		}
		if (p.processLinks) vkProccessLinks();
	},
	init:function(){
		for (var key in vkopt_plugins){
			var p=vkopt_plugins[key];
			if (p.init){
				var tstart=unixtime();
				p.init();
				vklog('Plugin "'+key+'" inited. '+(unixtime()-tstart)+'ms');
			}
		}
	},
	css:function(){
		var css='';
		for (var key in vkopt_plugins){
			var p=vkopt_plugins[key];
			if (p.css) css+=(Object.prototype.toString.call(p.css) === '[object Function]')?p.css():p.css;
		}
		return css;
	},
	onloc:function(){
		for (var key in vkopt_plugins){
			var p=vkopt_plugins[key];
			if (p.onLocation){
				var tstart=unixtime();
				p.onLocation(nav.objLoc,cur.module);
				vklog('Plugin "'+key+'" onLocation: '+(unixtime()-tstart)+'ms');
			}
		}
	},
	onjs:function(file){
		for (var key in vkopt_plugins){
			var p=vkopt_plugins[key];
			if (p.onLibFiles) {
				var tstart=unixtime();
				p.onLibFiles(file);
				vklog('Plugin "'+key+'" onLibFiles: '+(unixtime()-tstart)+'ms');
			}
		}
	},
	processlink:function(node){
		for (var key in vkopt_plugins){
			var p=vkopt_plugins[key];
			if (p.processLinks) p.processLinks(node);
		}
	},
	processnode:function(node,is_lite){
		for (var key in vkopt_plugins){
			var p=vkopt_plugins[key];
			if (p.processNode){
				var tstart=unixtime();
				p.processNode(node,is_lite);
				vklog('Plugin "'+key+'" ProcessNode: '+(unixtime()-tstart)+'ms');
			}
		}
	},
	photoview_actions:function(ph){
		var r='';
		for (var key in vkopt_plugins){
			var p=vkopt_plugins[key];
			if (p.pvActions) {
				var tstart=unixtime();
				r+=isFunction(p.pvActions)?p.pvActions(ph):p.pvActions;
				vklog('Plugin "'+key+'" PhView actions: '+(unixtime()-tstart)+'ms');
			}
		}
		return r;
	},
	album_actions:function(oid,aid){
		var a=[];
		for (var key in vkopt_plugins){
			var p=vkopt_plugins[key];
			if (p.albumActions) {
				var tstart=unixtime();
				a=a.concat(isFunction(p.albumActions)?p.albumActions(oid,aid):p.albumActions);
				vklog('Plugin "'+key+'" Album actions items: '+(unixtime()-tstart)+'ms');
			}
			p.album_actions_ok=true;
		}
		return a;
	},
   videos_actions:function(oid,aid){
		var a=[];
		for (var key in vkopt_plugins){
			var p=vkopt_plugins[key];
			if (p.videosActions) {
				var tstart=unixtime();
				a=a.concat(isFunction(p.videosActions)?p.videosActions(oid,aid):p.videosActions);
				vklog('Plugin "'+key+'" Videos actions items: '+(unixtime()-tstart)+'ms');
			}
		}
		return a;
   },
	video_links:function(video_data,links_array){
		var r='';
		for (var key in vkopt_plugins){
			var p=vkopt_plugins[key];
			if (p.vidActLinks) {
				var tstart=unixtime();
				r+=isFunction(p.vidActLinks)?p.vidActLinks(video_data,links_array):p.vidActLinks;
				vklog('Plugin "'+key+'" VidLinks actions: '+(unixtime()-tstart)+'ms');
			}
		}
		return r;
	},
	process_response:function(answer,url,params){
		var r='';
		for (var key in vkopt_plugins){
			var p=vkopt_plugins[key];
			if (p.onResponseAnswer) {
				var tstart=unixtime();
				r=p.onResponseAnswer(answer,url,params);
				if (r){
					vklog('Plugin "'+key+'" onResponseAnswer: '+(unixtime()-tstart)+'ms');
				}
			}
		}
		//return r;
	},
   user_menu_items:function(uid,gid){
		var r='';
		for (var key in vkopt_plugins){
			var p=vkopt_plugins[key];
			if (p.UserMenuItems) {
				var tstart=unixtime();
            var i = p.UserMenuItems(uid,gid) || '';
            if (isArray(i)){
               r+='<li><div class="vk_user_menu_divider"></div></li>';
               for (var j=0; j<i.length;j++)
                  r+='<li onmousemove="clearTimeout(pup_tout);" onmouseout="pup_tout=setTimeout(pupHide, 400);">'+i[j]+'</li>';
            } else {
               if (i) r+='<li><div class="vk_user_menu_divider"></div></li>';
               r+='<li onmousemove="clearTimeout(pup_tout);" onmouseout="pup_tout=setTimeout(pupHide, 400);">'+i+'</li>';
            }
				if (r) vklog('Plugin "'+key+'" user_menu_items: '+(unixtime()-tstart)+'ms');
			}
		}
		return r;
   }
}
vkopt_plugin_run=vk_plugins.run;

/*! CONNECT PLUGIN CODE

if (!window.vkopt_plugins) vkopt_plugins={};
(function(){
   var PLUGIN_ID = 'vkmyplugin';
   var PLUGIN_NAME = 'vk my test plugin';
   var ADDITIONAL_CSS='';

   vkopt_plugins[PLUGIN_ID]={
      Name:PLUGIN_NAME,
      css:ADDITIONAL_CSS,
   // FUNCTIONS
      init:             null,                    // function();                        //run on connect plugin to vkopt
      onLocation:       null,                    // function(nav_obj,cur_module_name); //On new location
      onLibFiles:       null,                    // function(file_name);               //On connect new vk script
      onStorage :       null,                    // function(command_id,command_obj);
      processLinks:     null,                    // function(link);
      processNode:      null,                    // function(node);
      pvActions:        null,                    // function(photo_data); ||  String    //PHOTOVIEWER_ACTIONS
      albumActions:     null,                    // function(oid,aid); || Array with items. Example  [{l:'Link1', onClick:Link1Func},{l:'Link2', onClick:Link2Func}]
      videosActions:    null,                    // see "albumActions"
      vidActLinks:      null,                    // function(video_data,links_array); ||  String.   video_data may contain iframe url
      onResponseAnswer: null,                    // function(answer,url,params); 'answer' is array. modify only array items
      UserMenuItems:    null                     // function(uid) || string
   };
   if (window.vkopt_ready) vkopt_plugin_run(PLUGIN_ID);
})();

*/

if (!window.winToUtf) winToUtf=function(text) {
  text=text.replace(/&#0+(\d+);/g,"&#$1;");
  var m, j, code;  m = text.match(/&#[0-9]{2}[0-9]*;/gi);
  for (j in m) {   var val = '' + m[j]; code = intval(val.substr(2, val.length - 3));
    if (code >= 32 && ('&#' + code + ';' == val)) text = text.replace(val, String.fromCharCode(code));
  }  text = text.replace(/&quot;/gi, '"').replace(/&amp;/gi, '&').replace(/&lt;/gi, '<').replace(/&gt;/gi, '>');
  return text;
}
if (!window.ge) ge=function(q) {return document.getElementById(q);}
if (!window.geByTag) geByTag=function(searchTag, node) {return (node || document).getElementsByTagName(searchTag);}
if (!window.geByTag1) geByTag1=function(searchTag, node) {return geByTag(searchTag, node)[0];}

var dloc=document.location.href.split('/')[2] || '';
