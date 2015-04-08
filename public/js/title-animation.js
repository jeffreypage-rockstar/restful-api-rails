var ismobile=navigator.userAgent.match(/(iPad)|(iPhone)|(iPod)|(android)|(webOS)/i);
if( (!ismobile)) {
	$(window).bind("load", function() {	
		$('#first-title').hide().delay(600).fadeIn(300);
		$('#second-title').hide().delay(1800).fadeIn(300);
		$('#third-title').hide().delay(3000).fadeIn(300);
	});	
}
else {
	$(".big-title").css('display','block');
}
