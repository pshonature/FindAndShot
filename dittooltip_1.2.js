//===================================================================
// ditip: Tool Tip Library
// version: 1.2  (2016. 10. 20)
// ------------------------------------------------------------------
// Developed by Pongsik, Ho
// Copyright (c) 2016 All rights reserved by Pongsik, Ho.
//===================================================================
var DITip = {
		div: null,
		lastElement: null,
		onair: false,
		bgcolor: function(color) { $(this.div).css('background-color', color); },
		color: function(color) {$(this.div).css('color', color); }
};
function ditToolTipInit() {   // call window.onload
	DITip.div = document.createElement('div');
	$(DITip.div).css({  'border-style': 'solid',
					  'border-width': '1px',
					  'border-color': 'gray',
					       'z-index': 1,
				  'background-color': '#FFFFDD',
					      'position': 'absolute',
				     'border-radius': '3px',
					       'padding': '7px',
					    'box-shadow': '2px 2px 3px'
				   });
	document.body.appendChild(DITip.div);
	$(DITip.div).hide();
}
//===================================================================
function ditToolTipShow(){
	if(DITip.onair)
		return;

	var txt = $(this).attr('ditip');
	$(DITip.div).css('left', (event.clientX+8)+'px');
	$(DITip.div).css('top', (event.clientY+8)+'px');

	if(txt.indexOf('//') >= 0) {
		var com = txt.split('//');
		txt = '<span style="font-size: 12pt;padding: 0px; margin: 0px;"><strong>'+com[0]+'</strong></span><hr>'
		txt += com[1];
	}

	$(DITip.div).html(txt);
	$(DITip.div).fadeIn(400);
	DITip.onair = true;
}
function ditToolTipHide() {
	$(DITip.div).fadeOut(400);
	DITip.onair = false;
}
$(document).ready(function () {
	$('[ditip]').mouseover(ditToolTipShow);
	$('[ditip]').mouseout(ditToolTipHide);
	ditToolTipInit();
	// console.log(typeof($('[help]').attr('kkk')));
});
//===================================================================