$(function() {
  var search_list = $(".contents");

  function appendMovie(movie) {
    var html = `<a class="content" href="/movies/${movie.id}">
                    <img src="${movie.image}" alt="映画" class="content__image">
                    <div class="content__title">${movie.title}</div>
                    <div class="content__like">
                    いいね:${movie.count}
                    </div></a>`
    search_list.append(html);
   }
   function appendErrMsgToHTML(msg) {
    var html = `<div class='name'>${ msg }</div>`
    search_list.append(html);
  }
  $(".sbox").on("keyup", function() {
    var input = $(".sbox").val();
    $.ajax({
      type: 'GET',
      url: '/movies/search/',
      data: { keyword: input },
      dataType: 'json'
    })
    .done(function(movies) {
      search_list.empty();
      if (movies.length !== 0) {
        movies.forEach(function(movie){
          console.log(movie);
          appendMovie(movie);
        });
      }
      else {
        appendErrMsgToHTML("映画がありません");
      }
    })
    .fail(function (jqXHR, textStatus, errorThrown) {
      alert('error');
      console.log("ajax通信に失敗しました");
      console.log("jqXHR          : " + jqXHR.status);
      console.log("textStatus     : " + textStatus);
      console.log("errorThrown    : " + errorThrown.message);
      console.log("URL            : " + url);
});
  });
});