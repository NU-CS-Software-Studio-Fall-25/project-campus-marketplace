import { Controller } from "@hotwired/stimulus"
import debounce from "helpers/debounce"

export default class extends Controller {
  static targets = ["input", "suggestions", "form", "pagination"]

  connect() {
    this.update = debounce(this.update.bind(this), 200)
    this.currentRequest = null
  }

  disconnect() {
    if (this.currentRequest) this.currentRequest.abort()
  }

  update() {
    const query = this.inputTarget.value.trim()
    this.fetchSuggestions(query)
    this.fetchResults(query)
  }

  fetchSuggestions(query) {
    if (!query) {
      this.suggestionsTarget.innerHTML = ""
      this.suggestionsTarget.classList.add("hidden")
      return
    }

    fetch(`/listings/suggestions?q=${encodeURIComponent(query)}`)
      .then((response) => response.json())
      .then(({ suggestions }) => {
        if (suggestions.length === 0) {
          this.suggestionsTarget.innerHTML = ""
          this.suggestionsTarget.classList.add("hidden")
          return
        }

        this.suggestionsTarget.innerHTML = suggestions
          .map((suggestion) => `<button type="button" data-action="click->listings-search#applySuggestion" class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">${suggestion}</button>`)
          .join("")
        this.suggestionsTarget.classList.remove("hidden")
      })
      .catch(() => {})
  }

  applySuggestion(event) {
    this.inputTarget.value = event.currentTarget.textContent
    this.suggestionsTarget.innerHTML = ""
    this.suggestionsTarget.classList.add("hidden")
    this.fetchResults(this.inputTarget.value)
  }

  fetchResults(query) {
    const url = new URL(this.formTarget.action)
    if (query) {
      url.searchParams.set("q", query)
    } else {
      url.searchParams.delete("q")
    }

    // Reset to first page when typing a new query
    url.searchParams.delete("page")

    if (this.currentRequest) this.currentRequest.abort()
    this.currentRequest = new AbortController()

    fetch(url.toString(), { headers: { Accept: "application/json" }, signal: this.currentRequest.signal })
      .then((response) => response.json())
      .then(({ html, pagination }) => {
        document.getElementById("listings").outerHTML = html
        this.paginationTarget.innerHTML = pagination
        this.paginationTarget.dataset.page = url.searchParams.get("page") || "1"
        this.currentRequest = null
      })
      .catch((error) => {
        if (error.name !== "AbortError") {
          console.error("Error fetching listings", error)
        }
      })
  }
}
