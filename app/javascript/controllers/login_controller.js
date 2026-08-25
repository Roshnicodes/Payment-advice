import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["password", "toggle"]

  togglePassword() {
    const isHidden = this.passwordTarget.type === "password"

    this.passwordTarget.type = isHidden ? "text" : "password"
    this.toggleTarget.textContent = isHidden ? "🙈" : "👁"
    this.toggleTarget.setAttribute("aria-label", isHidden ? "Hide password" : "Show password")
  }
}
