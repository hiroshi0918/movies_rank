import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "input", "submit", "list"]

  submit(event) {
    event.preventDefault();
    this.submitTarget.disabled = true;

    const formData = new FormData(this.formTarget);
    const url = this.formTarget.action;
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

    fetch(url, {
      method: "POST",
      body: formData,
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": csrfToken
      }
    })
    .then(response => {
      if (!response.ok) {
        return response.json().then(err => { throw err });
      }
      return response.json();
    })
    .then(data => {
      this.listTarget.appendChild(this.buildCommentElement(data));
      this.inputTarget.value = "";
    })
    .catch(error => {
      let message = "コメントの送信に失敗しました";
      if (error && error.errors && error.errors.length > 0) {
        message = error.errors.join("\\n");
      }
      alert(message);
    })
    .finally(() => {
      this.submitTarget.disabled = false;
    });
  }

  buildCommentElement(comment) {
    const item = document.createElement("div");
    item.className = "comment-item";
    
    const userDiv = document.createElement("div");
    userDiv.className = "comment-item__user";
    userDiv.textContent = comment.user_name;
    
    const textDiv = document.createElement("div");
    textDiv.className = "comment-item__text";
    textDiv.textContent = comment.text;

    item.appendChild(userDiv);
    item.appendChild(textDiv);

    return item;
  }
}
