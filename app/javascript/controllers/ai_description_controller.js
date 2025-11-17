import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "output", "tone", "status", "button"]
  static values = {
    url: String
  }

  generate(event) {
    event.preventDefault()

    if (!this.urlValue) {
      this.showStatus("Missing AI endpoint.", true)
      return
    }

    const title = this.titleTarget?.value?.trim()
    if (!title) {
      this.showStatus("Enter a title first.", true)
      return
    }

    const notes = this.outputTarget?.value?.trim() || ""
    this.setLoading(true)

    fetch(this.urlValue, {
      method: "POST",
      headers: this.headers(),
      body: JSON.stringify({
        title: title,
        notes: notes,
        tone: this.toneTarget?.value || "friendly"
      })
    })
      .then(async (response) => {
        const data = await response.json()
        if (!response.ok) throw new Error(data.error || `HTTP ${response.status}`)
        return data
      })
      .then(({ description }) => {
        if (description) {
          this.outputTarget.value = description
          this.showStatus("Description updated.", false)
        } else {
          this.showStatus("No description returned.", true)
        }
      })
      .catch((error) => {
        console.error("Gemini request failed", error)
        this.showStatus(error.message || "AI request failed", true)
      })
      .finally(() => this.setLoading(false))
  }

  headers() {
    const headers = {
      "Content-Type": "application/json",
      Accept: "application/json"
    }
    const token = document.querySelector("meta[name='csrf-token']")?.content
    if (token) headers["X-CSRF-Token"] = token
    return headers
  }

  showStatus(message, isError) {
    if (!this.hasStatusTarget) return
    this.statusTarget.textContent = message
    this.statusTarget.classList.toggle("text-red-600", isError)
    this.statusTarget.classList.toggle("text-gray-500", !isError)
  }

  setLoading(isLoading) {
    if (!this.hasButtonTarget) return
    this.buttonTarget.disabled = isLoading
    this.buttonTarget.classList.toggle("opacity-60", isLoading)
    this.buttonTarget.textContent = isLoading ? "Generating..." : "Suggest with AI"
  }
}
