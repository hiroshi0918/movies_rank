// Netflix UI JavaScript
// Scroll arrows and header scroll behavior

$(document).ready(function() {
  // ============================
  // Header scroll background
  // ============================
  $(window).on('scroll', function() {
    var header = $('.header');
    if ($(window).scrollTop() > 50) {
      header.addClass('scrolled');
    } else {
      header.removeClass('scrolled');
    }
  });

  // ============================
  // Movie Row Scroll Arrows
  // ============================
  $(document).on('click', '.movie-row__arrow--right', function() {
    var container = $(this).siblings('.movie-row__container');
    var scrollAmount = container.width() * 0.8;
    container.animate({
      scrollLeft: container.scrollLeft() + scrollAmount
    }, 400, 'swing');
  });

  $(document).on('click', '.movie-row__arrow--left', function() {
    var container = $(this).siblings('.movie-row__container');
    var scrollAmount = container.width() * 0.8;
    container.animate({
      scrollLeft: container.scrollLeft() - scrollAmount
    }, 400, 'swing');
  });

  // ============================
  // Auto-dismiss flash notifications
  // ============================
  setTimeout(function() {
    $('.notifications .notice, .notifications .alert').fadeOut(500, function() {
      $(this).remove();
    });
  }, 4000);
});
