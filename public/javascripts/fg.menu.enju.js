jQuery(function(){
  jQuery('.fg-button').hover(
    function(){ jQuery(this).removeClass('ui-state-default').addClass('ui-state-focus'); },
    function(){ jQuery(this).removeClass('ui-state-focus').addClass('ui-state-default'); }
  );
  jQuery('#fg_search').menu({ 
    content: jQuery('#fg_search').next().html(),
    showSpeed: 100 
  });
  jQuery('#fg_message').menu({ 
    content: jQuery('#fg_message').next().html(),
    showSpeed: 100 
  });
  jQuery('#fg_circulation').menu({ 
    content: jQuery('#fg_circulation').next().html(),
    showSpeed: 100 
  });
  jQuery('#fg_acquisition').menu({ 
    content: jQuery('#fg_acquisition').next().html(),
    showSpeed: 100 
  });
  jQuery('#fg_request').menu({ 
    content: jQuery('#fg_request').next().html(),
    showSpeed: 100 
  });
  jQuery('#fg_event').menu({ 
    content: jQuery('#fg_event').next().html(),
    showSpeed: 100 
  });
  jQuery('#fg_management').menu({ 
    content: jQuery('#fg_management').next().html(),
    showSpeed: 100 
  });
});
