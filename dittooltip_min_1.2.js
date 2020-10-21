//===================================================================
// ditip: Tool Tip Library
// version: 1.2  (2016. 10. 20)
// ------------------------------------------------------------------
// Developed by Pongsik, Ho
// Copyright (c) 2016 All rights reserved by Pongsik, Ho.
//===================================================================
var DITip={div:null,lastElement:null,onair:!1,bgcolor:function(a){$(this.div).css("background-color",a)},color:function(a){$(this.div).css("color",a)}};function ditToolTipInit(){DITip.div=document.createElement("div");$(DITip.div).css({"border-style":"solid","border-width":"1px","border-color":"gray","z-index":1,"background-color":"#FFFFDD",position:"absolute","border-radius":"3px",padding:"7px","box-shadow":"2px 2px 3px"});document.body.appendChild(DITip.div);$(DITip.div).hide()}
function ditToolTipShow(){if(!DITip.onair){var a=$(this).attr("ditip");$(DITip.div).css("left",event.clientX+8+"px");$(DITip.div).css("top",event.clientY+8+"px");if(0<=a.indexOf("//"))var b=a.split("//"),a='<span style="font-size: 12pt;padding: 0px; margin: 0px;"><strong>'+b[0]+"</strong></span><hr>",a=a+b[1];$(DITip.div).html(a);$(DITip.div).fadeIn(400);DITip.onair=!0}}function ditToolTipHide(){$(DITip.div).fadeOut(400);DITip.onair=!1}
$(document).ready(function(){$("[ditip]").mouseover(ditToolTipShow);$("[ditip]").mouseout(ditToolTipHide);ditToolTipInit()});
