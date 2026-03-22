$(document).on('turbolinks:load', function() {
  var $searchList = $('.contents');
  var searchTimer;

  if ($searchList.length === 0) {
    return;
  }

  function appendMovie(movie) {
    var $link = $('<a>', {
      'class': 'content',
      href: '/movies/' + movie.id
    });

    $('<img>', {
      src: movie.image,
      alt: '映画',
      'class': 'content__image'
    }).appendTo($link);

    $('<div>', {
      'class': 'content__title',
      text: movie.title
    }).appendTo($link);

    $('<div>', {
      'class': 'content__like',
      text: 'いいね:' + movie.count
    }).appendTo($link);

    $searchList.append($link);
  }

  function appendErrMsgToHTML(msg) {
    $('<div>', {
      'class': 'name',
      text: msg
    }).appendTo($searchList);
  }

  $(document).off('keyup.movieSearch', '.sbox');
  $(document).on('keyup.movieSearch', '.sbox', function() {
    var input = $(this).val();

    clearTimeout(searchTimer);
    searchTimer = setTimeout(function() {
      $.ajax({
        type: 'GET',
        url: '/movies/search/',
        data: { keyword: input },
        dataType: 'json'
      })
      .done(function(movies) {
        $searchList.empty();
        if (movies.length !== 0) {
          movies.forEach(function(movie) {
            appendMovie(movie);
          });
        } else {
          appendErrMsgToHTML("該当する映画がありません");
        }
      })
      .fail(function(jqXHR) {
        if (jqXHR.status !== 0) {
          alert('検索に失敗しました');
        }
      });
    }, 300);
  });
});
