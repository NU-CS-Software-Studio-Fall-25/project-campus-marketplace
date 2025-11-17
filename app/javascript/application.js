// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

let stimulusPromise

const loadStimulusIfNeeded = () => {
  if (stimulusPromise || !document.querySelector("[data-controller]")) return stimulusPromise

  stimulusPromise = import("controllers")
  return stimulusPromise
}

loadStimulusIfNeeded()
document.addEventListener("turbo:load", loadStimulusIfNeeded)

if ("serviceWorker" in navigator) {
  const isLocalhost = ["localhost", "127.0.0.1"].includes(window.location.hostname)

  if (window.isSecureContext || isLocalhost) {
    window.addEventListener("load", () => {
      const serviceWorkerMeta = document.querySelector('meta[name="service-worker-url"]')
      const serviceWorkerUrl = serviceWorkerMeta?.content || "/service-worker.js"

      navigator.serviceWorker.register(serviceWorkerUrl).catch((error) => {
        console.error("Service worker registration failed:", error)
      })
    })
  }
}
