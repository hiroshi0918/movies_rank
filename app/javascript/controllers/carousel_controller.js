import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  scrollRight() {
    const scrollAmount = this.containerTarget.clientWidth * 0.8;
    this.containerTarget.scrollBy({ left: scrollAmount, behavior: "smooth" });
  }

  scrollLeft() {
    const scrollAmount = this.containerTarget.clientWidth * 0.8;
    this.containerTarget.scrollBy({ left: -scrollAmount, behavior: "smooth" });
  }
}
