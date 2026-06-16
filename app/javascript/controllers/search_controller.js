import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "list" ]

  connect() {
    this.timeout = null;
  }

  performSearch() {
    clearTimeout(this.timeout);

    this.timeout = setTimeout(() => {
      const query = this.inputTarget.value;

      // If we are not on the search page, submit the form normally to go to the search page.
      if (!this.hasListTarget) {
        this.inputTarget.closest('form').submit();
        return;
      }

      fetch(`/movies/search.json?keyword=${encodeURIComponent(query)}`)
        .then(response => {
          if (!response.ok) throw new Error("Network response was not ok");
          return response.json();
        })
        .then(movies => {
          this.listTarget.innerHTML = ""; // Clear existing

          if (movies.length > 0) {
            movies.forEach(movie => {
              this.listTarget.appendChild(this.buildMovieElement(movie));
            });
          } else {
            const noResults = document.createElement("p");
            noResults.className = "grid-page__empty";
            noResults.textContent = "該当する映画がありません";
            this.listTarget.appendChild(noResults);
          }
        })
        .catch(error => {
          console.error("Search failed:", error);
          alert("検索に失敗しました");
        });
    }, 300);
  }

  // 検索ページの静的表示(search.html.erb)と同じ .grid-card 構造で生成する。
  // 以前は .content 系を生成していたが対応するCSSが無く、ライブ検索時にレイアウトが崩れていた。
  buildMovieElement(movie) {
    const link = document.createElement("a");
    link.className = "grid-card";
    link.href = `/movies/${movie.id}`;

    const img = document.createElement("img");
    img.src = movie.image;
    img.alt = movie.title;
    img.className = "grid-card__image";
    link.appendChild(img);

    const overlay = document.createElement("div");
    overlay.className = "grid-card__overlay";

    const title = document.createElement("div");
    title.className = "grid-card__title";
    title.textContent = movie.title;
    overlay.appendChild(title);

    const meta = document.createElement("div");
    meta.className = "grid-card__meta";

    const likes = document.createElement("span");
    likes.className = "likes";
    const heart = document.createElement("i");
    heart.className = "fa fa-heart";
    heart.setAttribute("aria-hidden", "true");
    likes.appendChild(heart);
    likes.appendChild(document.createTextNode(` ${movie.count}`));
    meta.appendChild(likes);

    if (movie.category) {
      const category = document.createElement("span");
      category.className = "category";
      category.textContent = movie.category;
      meta.appendChild(category);
    }

    overlay.appendChild(meta);
    link.appendChild(overlay);

    return link;
  }
}
