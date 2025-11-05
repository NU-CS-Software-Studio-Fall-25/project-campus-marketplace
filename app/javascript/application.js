// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"

// Service Worker Registration with better error handling and reload handling
if ("serviceWorker" in navigator) {
  window.addEventListener("load", async () => {
    try {
      const registration = await navigator.serviceWorker.register("/service-worker.js", {
        scope: "/"
      })
      
      // Handle service worker updates
      registration.addEventListener("updatefound", () => {
        const newWorker = registration.installing
        newWorker.addEventListener("statechange", () => {
          if (newWorker.state === "installed" && navigator.serviceWorker.controller) {
            // New content is available, prompt user to reload
            if (confirm("New version available! Click OK to update.")) {
              window.location.reload()
            }
          }
        })
      })
    } catch (error) {
      console.warn("PWA registration failed:", error)
    }
  })
}
