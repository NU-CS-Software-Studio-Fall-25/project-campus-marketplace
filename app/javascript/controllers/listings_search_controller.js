import { Controller } from "@hotwired/stimulus"
import debounce from "helpers/debounce"

export default class extends Controller {
  static targets = ["form", "input", "results", "suggestions", "pagination", "summary", "category", "priceRange"]
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

  submit() {
    this.fetchUpdates()
    // Allow the normal form submission to proceed as a graceful fallback
  }

  fetchUpdates() {
    const query = this.inputTarget.value.trim()
    const categories = this.selectedCategories()
    const priceRanges = this.selectedPriceRanges()
    this.fetchResults(query, categories, priceRanges)
    this.fetchSuggestions(query, categories, priceRanges)
  }

  applySuggestion(event) {
    this.inputTarget.value = event.currentTarget.textContent.trim()
    this.hideSuggestions()
    this.fetchUpdates()
  }

  fetchResults(query, categories, priceRanges) {
    const url = this.buildUrl(this.resultsUrlValue, query, categories, priceRanges)

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

  fetchSuggestions(query, categories, priceRanges) {
    if (!query) {
      this.hideSuggestions()
      return
    }

    const url = this.buildUrl(this.suggestionsUrlValue, query, categories, priceRanges)

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
    if (!this.hasPaginationTarget) return

    const hasPagination = Boolean(pagination && pagination.trim().length)

    this.paginationTargets.forEach((target) => {
      target.innerHTML = pagination
      target.classList.toggle("hidden", !hasPagination)
    })
  }

  abortResultsRequest() {
    if (this.currentResultsRequest) {
      this.currentResultsRequest.abort()
      this.currentResultsRequest = null
    }
  }

  buildUrl(base, query, categories = [], priceRanges = []) {
    const url = new URL(base, window.location.origin)

    if (query) {
      url.searchParams.set("q", query)
    } else {
      url.searchParams.delete("q")
    }

    url.searchParams.delete("categories[]")
    if (categories.length) {
      categories.forEach((category) => url.searchParams.append("categories[]", category))
    }

    url.searchParams.delete("price_ranges[]")
    if (priceRanges.length) {
      priceRanges.forEach((range) => url.searchParams.append("price_ranges[]", range))
    }

    url.searchParams.delete("page")
    return url.toString()
  }

  selectedCategories() {
    if (!this.hasCategoryTarget) return []

    const checked = this.categoryTargets.filter((target) => target.checked)
    return checked.map((target) => target.value)
  }

  selectedPriceRanges() {
    if (!this.hasPriceRangeTarget) return []

    const checked = this.priceRangeTargets.filter((target) => target.checked)
    return checked.map((target) => target.value)
  }
}
