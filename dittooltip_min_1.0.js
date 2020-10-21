//===================================================================
// ditip: Tool Tip Library
// version: 1.0  (2016. 10. 20)
// ------------------------------------------------------------------
// Developed by Pongsik, Ho
// Copyright (c) 2016 All rights reserved by Pongsik, Ho.
//===================================================================
var ditToolTipDiv;function ditToolTipInit(){ditToolTipDiv=document.createElement("div");$(ditToolTipDiv).css({"border-style":"solid","border-width":"1px","border-color":"gray","z-index":1,"background-color":"#FFFFDD",position:"absolute","border-radius":"3px",padding:"7px"});document.body.appendChild(ditToolTipDiv);$(ditToolTipDiv).hide()}
function ditToolTipShow(){var a=$(this).attr("ditip");$(ditToolTipDiv).css("left",event.clientX+8+"px");$(ditToolTipDiv).css("top",event.clientY+8+"px");if(0<=a.indexOf("//"))var b=a.split("//"),a='<span style="font-size: 12pt;padding: 0px; margin: 0px;"><strong>'+b[0]+"</strong></span><hr>",a=a+b[1];$(ditToolTipDiv).html(a);$(ditToolTipDiv).fadeIn(500)}function ditToolTipHide(){$(ditToolTipDiv).fadeOut(400)}
$(document).ready(function(){$("[ditip]").mouseover(ditToolTipShow);$("[ditip]").mouseout(ditToolTipHide);ditToolTipInit()});