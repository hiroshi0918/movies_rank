import { Controller } from "@hotwired/stimulus"

// select等の変更でフォームを自動送信する(カタログの絞り込み/並び替え用)。
// JS無効でも submit ボタンで動作するため、これは利便性向上のための上乗せ。
export default class extends Controller {
  submit() {
    this.element.requestSubmit();
  }
}
