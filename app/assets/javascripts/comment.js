$(document).on('turbolinks:load', function() {
  function buildCommentElement(comment) {
    var $paragraph = $('<p>');

    $('<a>', {
      href: '/users/' + comment.user_id,
      text: comment.user_name
    }).appendTo($paragraph);

    $paragraph.append(document.createTextNode(': ' + comment.text));

    return $paragraph;
  }

  $(document).off('submit.commentForm', '#new-comment');
  $(document).on('submit.commentForm', '#new-comment', function(e) {
    e.preventDefault();
    var $form = $(this);
    var $submitBtn = $form.find('.chat-form--btn');
    $submitBtn.prop('disabled', true);
    var formData = new FormData(this);
    var url = $form.attr('action');

    $.ajax({
      url: url,
      type: 'POST',
      data: formData,
      dataType: 'json',
      processData: false,
      contentType: false
    })
    .done(function(data) {
      var $commentElement = buildCommentElement(data);
      $('.comments').append($commentElement);
      $form.find('.chat-form--box').val('');
    })
    .fail(function(xhr) {
      var message = 'コメントの送信に失敗しました';

      if (xhr.responseJSON && xhr.responseJSON.errors && xhr.responseJSON.errors.length > 0) {
        message = xhr.responseJSON.errors.join('\n');
      }

      alert(message);
    })
    .always(function() {
      $submitBtn.prop('disabled', false);
    });
  });
});
