// Accounting.js
(function(p,z){function q(a){return!!(""===a||a&&a.charCodeAt&&a.substr)}function m(a){return u?u(a):"[object Array]"===v.call(a)}function r(a){return"[object Object]"===v.call(a)}function s(a,b){var d,a=a||{},b=b||{};for(d in b)b.hasOwnProperty(d)&&null==a[d]&&(a[d]=b[d]);return a}function j(a,b,d){var c=[],e,h;if(!a)return c;if(w&&a.map===w)return a.map(b,d);for(e=0,h=a.length;e<h;e++)c[e]=b.call(d,a[e],e,a);return c}function n(a,b){a=Math.round(Math.abs(a));return isNaN(a)?b:a}function x(a){var b=c.settings.currency.format;"function"===typeof a&&(a=a());return q(a)&&a.match("%v")?{pos:a,neg:a.replace("-","").replace("%v","-%v"),zero:a}:!a||!a.pos||!a.pos.match("%v")?!q(b)?b:c.settings.currency.format={pos:b,neg:b.replace("%v","-%v"),zero:b}:a}var c={version:"0.3.2",settings:{currency:{symbol:"$",format:"%s%v",decimal:".",thousand:",",precision:2,grouping:3},number:{precision:0,grouping:3,thousand:",",decimal:"."}}},w=Array.prototype.map,u=Array.isArray,v=Object.prototype.toString,o=c.unformat=c.parse=function(a,b){if(m(a))return j(a,function(a){return o(a,b)});a=a||0;if("number"===typeof a)return a;var b=b||".",c=RegExp("[^0-9-"+b+"]",["g"]),c=parseFloat((""+a).replace(/\((.*)\)/,"-$1").replace(c,"").replace(b,"."));return!isNaN(c)?c:0},y=c.toFixed=function(a,b){var b=n(b,c.settings.number.precision),d=Math.pow(10,b);return(Math.round(c.unformat(a)*d)/d).toFixed(b)},t=c.formatNumber=function(a,b,d,i){if(m(a))return j(a,function(a){return t(a,b,d,i)});var a=o(a),e=s(r(b)?b:{precision:b,thousand:d,decimal:i},c.settings.number),h=n(e.precision),f=0>a?"-":"",g=parseInt(y(Math.abs(a||0),h),10)+"",l=3<g.length?g.length%3:0;return f+(l?g.substr(0,l)+e.thousand:"")+g.substr(l).replace(/(\d{3})(?=\d)/g,"$1"+e.thousand)+(h?e.decimal+y(Math.abs(a),h).split(".")[1]:"")},A=c.formatMoney=function(a,b,d,i,e,h){if(m(a))return j(a,function(a){return A(a,b,d,i,e,h)});var a=o(a),f=s(r(b)?b:{symbol:b,precision:d,thousand:i,decimal:e,format:h},c.settings.currency),g=x(f.format);return(0<a?g.pos:0>a?g.neg:g.zero).replace("%s",f.symbol).replace("%v",t(Math.abs(a),n(f.precision),f.thousand,f.decimal))};c.formatColumn=function(a,b,d,i,e,h){if(!a)return[];var f=s(r(b)?b:{symbol:b,precision:d,thousand:i,decimal:e,format:h},c.settings.currency),g=x(f.format),l=g.pos.indexOf("%s")<g.pos.indexOf("%v")?!0:!1,k=0,a=j(a,function(a){if(m(a))return c.formatColumn(a,f);a=o(a);a=(0<a?g.pos:0>a?g.neg:g.zero).replace("%s",f.symbol).replace("%v",t(Math.abs(a),n(f.precision),f.thousand,f.decimal));if(a.length>k)k=a.length;return a});return j(a,function(a){return q(a)&&a.length<k?l?a.replace(f.symbol,f.symbol+Array(k-a.length+1).join(" ")):Array(k-a.length+1).join(" ")+a:a})};if("undefined"!==typeof exports){if("undefined"!==typeof module&&module.exports)exports=module.exports=c;exports.accounting=c}else"function"===typeof define&&define.amd?define([],function(){return c}):(c.noConflict=function(a){return function(){p.accounting=a;c.noConflict=z;return c}}(p.accounting),p.accounting=c)})(this);
// ISO Mapping
var mapping = {"ALL":{"text":"Lek","uniDec":"76, 101, 107","uniHex":"4c, 65, 6b"},"AFN":{"text":"؋","uniDec":"1547","uniHex":"60b"},"ARS":{"text":"$","uniDec":"36","uniHex":"24"},"AWG":{"text":"ƒ","uniDec":"402","uniHex":"192"},"AUD":{"text":"$","uniDec":"36","uniHex":"24"},"AZN":{"text":"ман","uniDec":"1084, 1072, 1085","uniHex":"43c, 430, 43d"},"BSD":{"text":"$","uniDec":"36","uniHex":"24"},"BBD":{"text":"$","uniDec":"36","uniHex":"24"},"BYR":{"text":"p.","uniDec":"112, 46","uniHex":"70, 2e"},"BZD":{"text":"BZ$","uniDec":"66, 90, 36","uniHex":"42, 5a, 24"},"BMD":{"text":"$","uniDec":"36","uniHex":"24"},"BOB":{"text":"$b","uniDec":"36, 98","uniHex":"24, 62"},"BAM":{"text":"KM","uniDec":"75, 77","uniHex":"4b, 4d"},"BWP":{"text":"P","uniDec":"80","uniHex":"50"},"BGN":{"text":"лв","uniDec":"1083, 1074","uniHex":"43b, 432"},"BRL":{"text":"R$","uniDec":"82, 36","uniHex":"52, 24"},"BND":{"text":"$","uniDec":"36","uniHex":"24"},"KHR":{"text":"៛","uniDec":"6107","uniHex":"17db"},"CAD":{"text":"$","uniDec":"36","uniHex":"24"},"KYD":{"text":"$","uniDec":"36","uniHex":"24"},"CLP":{"text":"$","uniDec":"36","uniHex":"24"},"CNY":{"text":"¥","uniDec":"165","uniHex":"a5"},"COP":{"text":"$","uniDec":"36","uniHex":"24"},"CRC":{"text":"₡","uniDec":"8353","uniHex":"20a1"},"HRK":{"text":"kn","uniDec":"107, 110","uniHex":"6b, 6e"},"CUP":{"text":"₱","uniDec":"8369","uniHex":"20b1"},"CZK":{"text":"Kč","uniDec":"75, 269","uniHex":"4b, 10d"},"DKK":{"text":"kr","uniDec":"107, 114","uniHex":"6b, 72"},"DOP":{"text":"RD$","uniDec":"82, 68, 36","uniHex":"52, 44, 24"},"XCD":{"text":"$","uniDec":"36","uniHex":"24"},"EGP":{"text":"£","uniDec":"163","uniHex":"a3"},"SVC":{"text":"$","uniDec":"36","uniHex":"24"},"EEK":{"text":"kr","uniDec":"107, 114","uniHex":"6b, 72"},"EUR":{"text":"€","uniDec":"8364","uniHex":"20ac"},"FKP":{"text":"£","uniDec":"163","uniHex":"a3"},"FJD":{"text":"$","uniDec":"36","uniHex":"24"},"GHC":{"text":"¢","uniDec":"162","uniHex":"a2"},"GIP":{"text":"£","uniDec":"163","uniHex":"a3"},"GTQ":{"text":"Q","uniDec":"81","uniHex":"51"},"GGP":{"text":"£","uniDec":"163","uniHex":"a3"},"GYD":{"text":"$","uniDec":"36","uniHex":"24"},"HNL":{"text":"L","uniDec":"76","uniHex":"4c"},"HKD":{"text":"$","uniDec":"36","uniHex":"24"},"HUF":{"text":"Ft","uniDec":"70, 116","uniHex":"46, 74"},"ISK":{"text":"kr","uniDec":"107, 114","uniHex":"6b, 72"},"INR":{"text":"","uniDec":"","uniHex":""},"IDR":{"text":"Rp","uniDec":"82, 112","uniHex":"52, 70"},"IRR":{"text":"﷼","uniDec":"65020","uniHex":"fdfc"},"IMP":{"text":"£","uniDec":"163","uniHex":"a3"},"ILS":{"text":"₪","uniDec":"8362","uniHex":"20aa"},"JMD":{"text":"J$","uniDec":"74, 36","uniHex":"4a, 24"},"JPY":{"text":"¥","uniDec":"165","uniHex":"a5"},"JEP":{"text":"£","uniDec":"163","uniHex":"a3"},"KZT":{"text":"лв","uniDec":"1083, 1074","uniHex":"43b, 432"},"KPW":{"text":"₩","uniDec":"8361","uniHex":"20a9"},"KRW":{"text":"₩","uniDec":"8361","uniHex":"20a9"},"KGS":{"text":"лв","uniDec":"1083, 1074","uniHex":"43b, 432"},"LAK":{"text":"₭","uniDec":"8365","uniHex":"20ad"},"LVL":{"text":"Ls","uniDec":"76, 115","uniHex":"4c, 73"},"LBP":{"text":"£","uniDec":"163","uniHex":"a3"},"LRD":{"text":"$","uniDec":"36","uniHex":"24"},"LTL":{"text":"Lt","uniDec":"76, 116","uniHex":"4c, 74"},"MKD":{"text":"ден","uniDec":"1076, 1077, 1085","uniHex":"434, 435, 43d"},"MYR":{"text":"RM","uniDec":"82, 77","uniHex":"52, 4d"},"MUR":{"text":"₨","uniDec":"8360","uniHex":"20a8"},"MXN":{"text":"$","uniDec":"36","uniHex":"24"},"MNT":{"text":"₮","uniDec":"8366","uniHex":"20ae"},"MZN":{"text":"MT","uniDec":"77, 84","uniHex":"4d, 54"},"NAD":{"text":"$","uniDec":"36","uniHex":"24"},"NPR":{"text":"₨","uniDec":"8360","uniHex":"20a8"},"ANG":{"text":"ƒ","uniDec":"402","uniHex":"192"},"NZD":{"text":"$","uniDec":"36","uniHex":"24"},"NIO":{"text":"C$","uniDec":"67, 36","uniHex":"43, 24"},"NGN":{"text":"₦","uniDec":"8358","uniHex":"20a6"},"NOK":{"text":"kr","uniDec":"107, 114","uniHex":"6b, 72"},"OMR":{"text":"﷼","uniDec":"65020","uniHex":"fdfc"},"PKR":{"text":"₨","uniDec":"8360","uniHex":"20a8"},"PAB":{"text":"B/.","uniDec":"66, 47, 46","uniHex":"42, 2f, 2e"},"PYG":{"text":"Gs","uniDec":"71, 115","uniHex":"47, 73"},"PEN":{"text":"S/.","uniDec":"83, 47, 46","uniHex":"53, 2f, 2e"},"PHP":{"text":"₱","uniDec":"8369","uniHex":"20b1"},"PLN":{"text":"zł","uniDec":"122, 322","uniHex":"7a, 142"},"QAR":{"text":"﷼","uniDec":"65020","uniHex":"fdfc"},"RON":{"text":"lei","uniDec":"108, 101, 105","uniHex":"6c, 65, 69"},"RUB":{"text":"руб","uniDec":"1088, 1091, 1073","uniHex":"440, 443, 431"},"SHP":{"text":"£","uniDec":"163","uniHex":"a3"},"SAR":{"text":"﷼","uniDec":"65020","uniHex":"fdfc"},"RSD":{"text":"Дин.","uniDec":"1044, 1080, 1085, 46","uniHex":"414, 438, 43d, 2e"},"SCR":{"text":"₨","uniDec":"8360","uniHex":"20a8"},"SGD":{"text":"$","uniDec":"36","uniHex":"24"},"SBD":{"text":"$","uniDec":"36","uniHex":"24"},"SOS":{"text":"S","uniDec":"83","uniHex":"53"},"ZAR":{"text":"R","uniDec":"82","uniHex":"52"},"LKR":{"text":"₨","uniDec":"8360","uniHex":"20a8"},"SEK":{"text":"kr","uniDec":"107, 114","uniHex":"6b, 72"},"CHF":{"text":"CHF","uniDec":"67, 72, 70","uniHex":"43, 48, 46"},"SRD":{"text":"$","uniDec":"36","uniHex":"24"},"SYP":{"text":"£","uniDec":"163","uniHex":"a3"},"TWD":{"text":"NT$","uniDec":"78, 84, 36","uniHex":"4e, 54, 24"},"THB":{"text":"฿","uniDec":"3647","uniHex":"e3f"},"TTD":{"text":"TT$","uniDec":"84, 84, 36","uniHex":"54, 54, 24"},"TRY":{"text":"","uniDec":"","uniHex":""},"TRL":{"text":"₤","uniDec":"8356","uniHex":"20a4"},"TVD":{"text":"$","uniDec":"36","uniHex":"24"},"UAH":{"text":"₴","uniDec":"8372","uniHex":"20b4"},"GBP":{"text":"£","uniDec":"163","uniHex":"a3"},"USD":{"text":"$","uniDec":"36","uniHex":"24"},"UYU":{"text":"$U","uniDec":"36, 85","uniHex":"24, 55"},"UZS":{"text":"лв","uniDec":"1083, 1074","uniHex":"43b, 432"},"VEF":{"text":"Bs","uniDec":"66, 115","uniHex":"42, 73"},"VND":{"text":"₫","uniDec":"8363","uniHex":"20ab"},"YER":{"text":"﷼","uniDec":"65020","uniHex":"fdfc"},"ZWD":{"text":"Z$","uniDec":"90, 36","uniHex":"5a, 24"}};


function isoCurrency(value, iso, decimal, decimalSep, thousSep)
{
	return accounting.formatMoney(value, mapping[iso].text||$, parseInt(decimal)||2, thousSep||",", decimalSep||".");
}
