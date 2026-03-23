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
            const noResults = document.createElement("div");
            noResults.className = "name";
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

  buildMovieElement(movie) {
    const link = document.createElement("a");
    link.className = "content";
    link.href = `/movies/${movie.id}`;

    const img = document.createElement("img");
    img.src = movie.image;
    img.alt = "映画";
    img.className = "content__image";
    link.appendChild(img);

    const title = document.createElement("div");
    title.className = "content__title";
    title.textContent = movie.title;
    link.appendChild(title);

    const like = document.createElement("div");
    like.className = "content__like";
    like.textContent = `いいね:${movie.count}`;
    link.appendChild(like);

    return link;
  }
}
