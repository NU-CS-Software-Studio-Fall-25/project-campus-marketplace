import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "lengthItem", "lowercaseItem", "uppercaseItem", "numberItem", "specialItem"]
  static values = { minLength: { type: Number, default: 8 } }

  connect() {
    this.update()
  }

  update() {
    const password = this.inputTarget?.value || ""

    this.toggleItem(this.lengthItemTarget, password.length >= this.minLengthValue)
    this.toggleItem(this.lowercaseItemTarget, /[a-z]/.test(password))
    this.toggleItem(this.uppercaseItemTarget, /[A-Z]/.test(password))
    this.toggleItem(this.numberItemTarget, /\d/.test(password))
    this.toggleItem(this.specialItemTarget, /[^A-Za-z0-9]/.test(password))
  }

  toggleItem(element, isValid) {
    const icon = element.querySelector("[data-icon]")

    if (icon) {
      icon.textContent = isValid ? "✓" : "✕"
      icon.className = isValid ? "text-green-600 font-semibold leading-none" : "text-red-500 font-semibold leading-none"
    }

    element.classList.toggle("text-gray-900", isValid)
    element.classList.toggle("text-gray-600", !isValid)
  }
}
