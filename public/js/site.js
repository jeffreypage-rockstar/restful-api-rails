jQuery(document).ready(function($) {
	 var $window = $(window); //You forgot this line in the above example

	$('section[data-type="background"]').each(function(){
		var $bgobj = $(this); // assigning the object
		$(window).scroll(function() {
			var yPos = -( ($window.scrollTop() - $bgobj.offset().top) / $bgobj.data('speed'));
			// Put together our final background position
			var coords = '50% '+ yPos + 'px';
			// Move the background
			$bgobj.css({ backgroundPosition: coords });
		});
	});   
	var ismobile=navigator.userAgent.match(/(iPhone)|(iPod)|(android)|(webOS)/i);
	var homeSection = $('.home-section');
	if(homeSection.length) {
		if( (!ismobile && full !== '1')) {
			$('.home-section').addClass('full-home');
			$('.home-section').css('height', window.innerHeight+'px');
			$(window).resize(function() {
				$('.home-section').css('height', window.innerHeight+'px');
			});
		}
	}
	if(ismobile) {
		$('.video-bg').remove();
	}

	if (!$('html').hasClass('ie8')) {
		$("body").queryLoader2({
		    percentage        : true,
		    barHeight         : 1,
		    minimumTime       : 1000,
		    barColor          : "#666",
		    backgroundColor   : "#000",
		    onComplete: function() {
		    	TweenMax.to( $('#menu-top'), 1, {css:{top:0,opacity:1}});
		    	sortable();
		    	
		    	
			    var leftProduct = $('.left-product');
			    var rightProduct = $('.right-product');
			      if(leftProduct.length) {
			      	TweenMax.to( $('.left-product'), 1, {css:{bottom:0,opacity:1}});
			      }
			      if(rightProduct.length) {
			      	TweenMax.to( $('.right-product'), 1, {css:{top:0,opacity:1}});
			      }
			   },
		});
	} else {
		$('.video-bg').remove();
	}
	jQuery(window).load(function(){
        $('#prepage').fadeOut().remove();
    });
	$('.section-page').last().addClass('last-section');	
	$(".swipebox").swipebox( {
		hideBarsDelay : 0,
		useSVG : false
	}); 
});
$(".open-link").click(function() {
	var source = $(this).attr("href");
	$('.filter').slideUp('slow');
	$('html,body').animate({
		scrollTop : $("#portfolio").offset().top
	}, 'slow', function() {
		$('div.portfolio-loading').fadeIn('slow');
		$('.portfolio-detail-container').load(source, function() {
			$('div.portfolio-loading').fadeOut('slow');
			$('.portfolio-carousel').carousel('pause');
				$('.carousel-inner .item').first().addClass('active');
				$('div.portfolio-item').hide().delay(1000).slideDown(1000, function() {
					$('.description-btn').click(function(e) {
						$('#overlay').fadeIn(400);
						$(".description-item").slideDown('slow');
						$(this).toggleClass('active-description');
						e.preventDefault();
						$('#close-content').click(function(e) {
							$('#overlay').fadeOut(400);
							$(".description-item").slideUp('slow');
							e.preventDefault();
						});
				});
				$('.portfolio-item .close-item').click(function() {
					$(this).parent().parent().parent('.portfolio-item').slideUp(1000, function() {
						$('.portfolio-detail-container').empty();
						$('.filter').slideDown('slow');
					});
					return false;
				});
				//click() ends
			});
			//slideDown ends
		});
		//load() ends
	});
	//animate ends

	return false;
});
//navigation
var lastId,
    topMenu = $(".top-nav"),
    scrollDown = $(".scroll-down"),
    topMenuHeight = topMenu.outerHeight()+15,
    // All list items
    menuItems = topMenu.find("a"),
    // Anchors corresponding to menu items
    scrollItems = menuItems.map(function(){
      var item = $($(this).parent().not('.custom-link,.sub-menu li').children().attr("href"));
      if (item.length) { return item; }
    });


var homeSection = $('.home-section');
if(homeSection.length) {
	var id = $('.home-section').attr('id');
	$('#mini-logo a').attr("href","#"+id);
}
		menuItems.add(scrollDown).click(function(e){
			var href = this.hash,
			offsetTop = href === "#" ? 0 : $(href).offset().top-topMenuHeight+window.topOffset;
		  	$('html, body').stop().animate({ 
		      scrollTop: offsetTop
		  	}, window.speed, 'easeInOutExpo');
		  	e.preventDefault();
		});
		$('.home-link a,#mini-logo a').add(scrollDown).click(function(e) {
			var href = this.hash,
			offsetTop = href === "#" ? 0 : $(href).offset().top-topMenuHeight+window.topOffset;
		  	$('html, body').stop().animate({ 
		      scrollTop: offsetTop
		  	}, window.speed, 'easeInOutExpo');
		  	e.preventDefault();
		});
	var homeBubble = $('#nav-home li').each(function() {
		if (!$(this).hasClass('custom-link')) {
			$('#nav-home a').add(scrollDown).click(function(e){
				var href = this.hash,
				offsetTop = href === "#" ? 0 : $(href).offset().top-topMenuHeight+window.topOffset;
			  	$('html, body').stop().animate({ 
			      scrollTop: offsetTop
			  	}, window.speed, 'easeInOutExpo');
			  	e.preventDefault();
			});
		}
		return this;
	});

		

var ismobile=navigator.userAgent.match(/(iPhone)|(iPod)|(iPad)|(android)|(webOS)/i);
if( (ismobile)) {
	$('.nav-collapse a').click(function(e) {
		$('.nav-collapse').slideUp(400, function () {
			$('.nav-collapse').css('height','0');
			$('.btn-navbar').click(function() {
				$('.nav-collapse').toggleClass('menu-height');
				$('.nav-collapse').slideDown(400);
			});
		});
	});
}


var stickyHeaderTop = 500;
  
// Bind to scroll
$(window).bind('scroll', function() {
   // Get container scroll position
   var fromTop = $(this).scrollTop()+topMenuHeight;
   
   // Get id of current scroll item
   var cur = scrollItems.map(function(){
     if ($(this).offset().top < fromTop)
       return this;
   });
   
   // Get the id of the current element
   cur = cur[cur.length-1];
   var id = cur && cur.length ? cur[0].id : "";
   
   if (lastId !== id) {
       lastId = id;
       // Set/remove active class
       menuItems
         .parent().removeClass("active")
         .end().filter("[href=#"+id+"]").parent().addClass("active");
   }
   if( jQuery(window).scrollTop() > stickyHeaderTop && $("#menu-top").hasClass('hide-menu')) {
        jQuery('.hide-menu').fadeIn();
    } else {
        jQuery('.hide-menu').fadeOut();
    }
});

function sortable() {
  var $portfolioClone = $(".portfolio-wrapper").clone();
	$(".filter a").click(function(e){
	  $(".filter li").removeClass("current");
	  var $filterClass = $(this).parent().attr("class");
	  if ($filterClass == "all") {
	    var $filteredPortfolio = $portfolioClone.find(".item");
	  } 
	  else {
	    var $filteredPortfolio = $portfolioClone.find(".item[data-type~="+$filterClass+"]");
	  }
    $(".portfolio-wrapper").quicksand($filteredPortfolio, {
    	adjustHeight: false,
    	adjustWidth: false
    }, function() {
    	$(".open-link").click(function() {
				var source = $(this).attr("href");
				$('.filter').slideUp('slow');
				$('html,body').animate({
					scrollTop : $("#portfolio").offset().top
				}, 'slow', function() {
					$('div.portfolio-loading').fadeIn('slow');
					$('.portfolio-detail-container').load(source, function() {
						$('div.portfolio-loading').fadeOut('slow');
						$('.portfolio-carousel').carousel('pause');
							$('.carousel-inner .item').first().addClass('active');
							$('div.portfolio-item').hide().delay(1000).slideDown(1000, function() {
								$('.description-btn').click(function(e) {
									$('#overlay').fadeIn(400);
									$(".description-item").slideDown('slow');
									$(this).toggleClass('active-description');
									e.preventDefault();
									$('#close-content').click(function(e) {
										$('#overlay').fadeOut(400);
										$(".description-item").slideUp('slow');
										e.preventDefault();
									});
								});
								$('.portfolio-item .close-item').click(function() {
									$(this).parent().parent().parent('.portfolio-item').slideUp(1000, function() {
										$('.portfolio-detail-container').empty();
										$('.filter').slideDown('slow');
									});
									return false;
								});
								//click() ends
							});
							//slideDown ends
						});
						//load() ends
					});
					//animate ends
				return false;
			});
    });
	  $(this).parent().addClass("current");
	  e.preventDefault();
	});
	$(".nav-tabs li").click(function() {

      $(this).parent().find('.active').removeClass("active"); 
      $(this).addClass("active");
      $(this).parent().parent().find(".tab-pane").hide(); 

      var activeTab = $(this).find("a").attr("href");
      $(activeTab).fadeIn(700);
      return false;
  });
}