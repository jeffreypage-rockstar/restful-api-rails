var ismobile=navigator.userAgent.match(/(iPad)|(iPhone)|(iPod)|(android)|(webOS)/i);
if( (!ismobile)) {
	jQuery(document).ready(function($) {
		var controller = $.superscrollorama();
		if ($('#staff-desc').length) {
			controller.addTween('#staff-desc',
			TweenMax.from( $('#staff-desc'), .5, {css:{left:-1700}}));
		}
		if ($('#staff-team').length) {
			controller.addTween('#staff-team',
			TweenMax.from( $('#staff-team'), .5, {css:{right:-1700}}));
		}
		$('.gallery').each(function() {
			controller.addTween($(this),
			TweenMax.from( $(this), .5, {css:{opacity:0}}));
		});
		$('.portfolio-container').each(function() {
			controller.addTween($(this),
			TweenMax.from( $(this), .5, {css:{opacity:0}}));
		});
		if ($('#find-us').length) {
			controller.addTween('#find-us',
			TweenMax.from( $('#find-us'), .5, {css:{top:20}}));
		}
		if ($('#contact-info').length) {
			controller.addTween('#contact-info',
			TweenMax.from( $('#contact-info'), .5, {css:{top:20}}));
		}
		$('.full-width-container').each(function() {
			controller.addTween($(this),
			TweenMax.from( $(this), .5, {css:{opacity:0}}));
		});
		
	});
}
