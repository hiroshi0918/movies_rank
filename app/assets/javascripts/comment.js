$(function(){
  function buildHTML(comment){
    var html = `<p>
                    <a href=/users/${comment.user_id}>${comment.user_name}</a>
                  ${comment.text}
                </p>`
    return html;
  }
  $('#new-comment').on('submit', function(e){
    e.preventDefault();
    var formData = new FormData(this);
    var url = $(this).attr('action')
    $.ajax({
      url: url,
      type: "POST",
      data: formData,
      dataType: 'json',
      processData: false,
      contentType: false
    })
    .done(function(data){
      var html = buildHTML(data);
      $('.comments').append(html);
      $('.chat-form--box').val('');
      $('.chat-form--btn').prop('disabled', false);
    })
    .fail(function(){
      alert('error');
    })
  })
})