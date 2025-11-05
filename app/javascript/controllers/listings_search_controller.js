import { Controller } from "@hotwired/stimulus"
import debounce from "helpers/debounce"

export default class extends Controller {
  static targets = ["form", "input", "results", "suggestions", "pagination", "summary"]
  static values = {
    resultsUrl: String,
    suggestionsUrl: String
  }

  connect() {
    this.debouncedFetch = debounce(this.fetchUpdates.bind(this), 200)
    this.currentResultsRequest = null
  }

  disconnect() {
    this.abortResultsRequest()
  }

  update() {
    this.debouncedFetch()
  }

  submit(event) {
    event.preventDefault()
    this.fetchUpdates()
  }

  fetchUpdates() {
    const query = this.inputTarget.value.trim()
    this.fetchResults(query)
    this.fetchSuggestions(query)
  }

  applySuggestion(event) {
    this.inputTarget.value = event.currentTarget.textContent.trim()
    this.hideSuggestions()
    this.fetchUpdates()
  }

  fetchResults(query) {
    const url = this.buildUrl(this.resultsUrlValue, query)

    this.abortResultsRequest()
    this.currentResultsRequest = new AbortController()

    fetch(url, {
      headers: { Accept: "application/json" },
      signal: this.currentResultsRequest.signal
    })
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`)
        return response.json()
      })
      .then(({ html, pagination, summary }) => {
        this.resultsTarget.innerHTML = html
        this.updatePagination(pagination)
        this.updateSummary(summary)
        this.currentResultsRequest = null
      })
      .catch((error) => {
        if (error.name !== "AbortError") {
          console.error("Failed to load listings", error)
        }
      })
  }

  updateSummary(summary) {
    if (!this.hasSummaryTarget) return

    this.summaryTarget.innerHTML = summary
    this.summaryTarget.classList.toggle("hidden", !summary)
  }

  fetchSuggestions(query) {
    if (!query) {
      this.hideSuggestions()
      return
    }

    const url = this.buildUrl(this.suggestionsUrlValue, query)

    fetch(url, { headers: { Accept: "application/json" } })
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`)
        return response.json()
      })
      .then(({ suggestions }) => {
        if (!suggestions.length) {
          this.hideSuggestions()
          return
        }

        this.suggestionsTarget.innerHTML = suggestions
          .map(
            (suggestion) =>
              `<button type="button" class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100" data-action="click->listings-search#applySuggestion">${suggestion}</button>`
          )
          .join("")

        this.suggestionsTarget.classList.remove("hidden")
      })
      .catch((error) => {
        console.error("Failed to load suggestions", error)
        this.hideSuggestions()
      })
  }

  hideSuggestions() {
    this.suggestionsTarget.innerHTML = ""
    this.suggestionsTarget.classList.add("hidden")
  }

  updatePagination(pagination) {
    this.paginationTarget.innerHTML = pagination
    this.paginationTarget.classList.toggle("hidden", !pagination.trim())
  }

  abortResultsRequest() {
    if (this.currentResultsRequest) {
      this.currentResultsRequest.abort()
      this.currentResultsRequest = null
    }
  }

  buildUrl(base, query) {
    const url = new URL(base, window.location.origin)

    if (query) {
      url.searchParams.set("q", query)
    } else {
      url.searchParams.delete("q")
    }

    url.searchParams.delete("page")
    return url.toString()
  }
}
