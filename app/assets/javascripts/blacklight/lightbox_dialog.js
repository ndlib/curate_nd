//= require blacklight/core
Blacklight.setup_modal = function(link_selector, form_selector, launch_modal) {
  'use strict';

  // Event indicating blacklight is setting up a modal link
  var e = $.Event('lightbox.setup_modal');
  $(link_selector).trigger(e);
  if (e.isDefaultPrevented()){ return; }

  $(link_selector).click(function(e) {
    var link = $(this);
    e.preventDefault();

    var jqxhr = $.ajax({
      url: link.attr('href'),
      dataType: 'script'
    });

    jqxhr.always( function (data) {
      $('#ajax-modal').html(data.responseText);
      Blacklight.setup_modal('.modal-footer a', '#ajax-modal form.ajax_form', false);

      if (launch_modal) {
        $('#ajax-modal').modal();
        Blacklight.launch_modal_callback();
      }
      Blacklight.check_close_ajax_modal();
    });
  });

  $(form_selector).submit(function() {
    var jqxhr = $.ajax({
      url: $(this).attr('action'),
      data: $(this).serialize(),
      type: 'POST',
      dataType: 'script'
    });

    jqxhr.always (function (data) {
      $('#ajax-modal').html(data.responseText);
      Blacklight.setup_modal('#ajax-modal .ajax_reload_link', '#ajax-modal form.ajax_form', false);
      Blacklight.check_close_ajax_modal();
    });

    return false;
  });
};

Blacklight.check_close_ajax_modal = function() {
  'use strict';
  if ($('#ajax-modal span.ajax-close-modal').length) {
    var modal_flashes = $('#ajax-modal .flash_messages'),
        main_flashes = $('#main-flashes .flash_messages:nth-of-type(1)');

    $('#ajax-modal *[data-dismiss="modal"]:nth-of-type(1)').trigger('click');
    main_flashes.append(modal_flashes);
    modal_flashes.fadeIn(500);
  }
};

Blacklight.launch_modal_callback = function() {
  'use strict';
  $('.facet-hierarchy.collapsible > .h-node > .facet_select').each(function(){
    var $this = $(this),
    $subCollections = $this.siblings('ul'),
    hasSubCollections = ($subCollections.length === 1);

    if (hasSubCollections){
    var $parentElement = $this.parent(),
        $countElement = $this.next('.count'),
        countNumber = $countElement.text(),
        targetPath = $this.attr('href'),
        seeAllBtn = '<a href="'+ targetPath +'" class="btn btn-default btn-sm see-all">See all '+ countNumber +'</a>',
        hasNoneSelected = ($('.remove', $parentElement).length === 0);

      $parentElement.append(seeAllBtn);
      $countElement.remove();

      if (hasNoneSelected){
        $subCollections.hide();
      } else {
        $this.addClass('expanded');
      }

      $this.addClass('can-collapse').on('click', function(e){
        e.preventDefault();

        $(this)
          .toggleClass('expanded')
          .next('ul').slideToggle();
      });
    }
  });
};

Blacklight.onLoad(function() {
  'use strict';
  Blacklight.setup_modal('a.lightboxLink,a.more_facets_link,.ajax_modal_launch', '#ajax-modal form.ajax_form', true);
  Blacklight.launch_modal_callback();
});
