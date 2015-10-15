(function ($) {

    function initBackToTop(){
	      $('.back-to-top').click(function(){
		        $('body,html').animate({'scroll-top':0},600);
		        return false;
	      });
    }

    function initResetForm(){
	      $('.reset-form').click(function(){
		        $(this).closest('form').find('input[type="text"]').val('');
		        $(this).closest('form').find('select').each(function(){
			          var v = $(this).children().first().val();
			          $(this).val(v);
		        });
	      });
    }

    function initAnnotations(){
	      $('.annotation-link').hover(function(){
		        $(this).parent().addClass('active');
	      },function(){

	      });
	      $('.annotation').hover(function(){

	      },function(){
		        $(this).removeClass('active');
	      });
    }

    function initSmoothScrollLinks(){
	      $('a').each(function(){
		        if($(this).hasClass('ssdone')){return;}
		        $(this).addClass('ssdone');
		        $(this).click(function(){
			          var href=$(this).attr('href');
			          if(href === undefined){return;}
                href = href.replace ('.', '\\.');
			          var io = href.indexOf('#');
			          if(io == -1){return;}
			          href = href.substr(io);
			          var target = $(href);
			          if(target.length > 0){
				            var off = 0;
				            off = target.first().offset().top;
				            $('body,html').animate({'scroll-top':off},600);
				            return false;
			          }
		        });

	      });
    }

    $(document).ready (function () {
	      setTimeout (initBackToTop,0);
	      setTimeout (initAnnotations,0);
	      setTimeout (initSmoothScrollLinks,0);
        setTimeout (initResetForm,0);
    });

})(jQuery);
