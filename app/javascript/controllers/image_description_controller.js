import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["imageInput", "descriptionField", "generateButton", "statusMessage"]
  static values = {
    generateUrl: String
  }

  connect() {
    console.log("Image description controller connected")
    console.log("Image input target:", this.hasImageInputTarget ? "found" : "not found")
    console.log("Description field target:", this.hasDescriptionFieldTarget ? "found" : "not found")
    
    if (this.hasImageInputTarget) {
      // Listen for file selection
      this.imageInputTarget.addEventListener('change', (e) => {
        console.log("File input changed, file:", e.target.files[0])
        if (e.target.files.length > 0) {
          this.handleFileSelect(e.target.files[0])
        }
      })
    }
  }

  async handleFileSelect(file) {
    console.log("Handling file selection:", file.name)
    
    // Show loading state
    this.showStatus("📤 Uploading image...", "loading")
    
    const uploadUrl = this.imageInputTarget.dataset.directUploadUrl || '/rails/active_storage/direct_uploads'
    console.log("Upload URL:", uploadUrl)
    
    const upload = new DirectUpload(file, uploadUrl)
    
    upload.create((error, blob) => {
      if (error) {
        console.error("Upload error:", error)
        this.showStatus("Upload failed. Please try again.", "error")
      } else {
        console.log("Upload successful, blob:", blob)
        
        // Create hidden input for the form
        const hiddenField = document.createElement('input')
        hiddenField.type = 'hidden'
        hiddenField.name = this.imageInputTarget.name
        hiddenField.value = blob.signed_id
        this.element.appendChild(hiddenField)
        
        // Generate description
        this.generateDescriptionFromSignedId(blob.signed_id)
      }
    })
  }

  checkForSignedId() {
    // Look for the hidden field that Rails' direct upload creates
    const hiddenInput = this.element.querySelector('input[type="hidden"][name*="[image]"]')
    
    console.log("Checking for signed ID...", hiddenInput)
    
    if (hiddenInput && hiddenInput.value) {
      console.log("Found signed ID:", hiddenInput.value)
      this.generateDescriptionFromSignedId(hiddenInput.value)
    } else {
      console.log("No signed ID found yet, will retry...")
      // Retry after another delay
      setTimeout(() => {
        const retryInput = this.element.querySelector('input[type="hidden"][name*="[image]"]')
        if (retryInput && retryInput.value) {
          console.log("Found signed ID on retry:", retryInput.value)
          this.generateDescriptionFromSignedId(retryInput.value)
        } else {
          console.error("Could not find signed blob ID")
          this.showStatus("Image uploaded. Please enter a description manually.", "error")
        }
      }, 500)
    }
  }

  async generateDescriptionFromSignedId(signedId) {
    if (!signedId) return

    // Show loading state
    this.showStatus("🤖 Analyzing image with AI...", "loading")
    this.descriptionFieldTarget.disabled = true

    try {
      await this.generateDescription(signedId)
    } catch (error) {
      console.error("Error generating description:", error)
      this.showStatus("Could not generate description automatically. Please enter manually.", "error")
      this.descriptionFieldTarget.disabled = false
    }
  }

  async generateDescription(signedId) {
    console.log("Generating description for:", signedId)
    
    try {
      const response = await fetch(this.generateUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ signed_id: signedId })
      })

      console.log("Response status:", response.status)
      const data = await response.json()
      console.log("Response data:", data)

      if (response.ok && data.description) {
        this.descriptionFieldTarget.value = data.description
        this.showStatus("✓ AI description generated! Feel free to edit.", "success")
        this.descriptionFieldTarget.disabled = false
        this.descriptionFieldTarget.focus()
        
        // Show regenerate button
        if (this.hasGenerateButtonTarget) {
          this.generateButtonTarget.classList.remove("hidden")
        }
      } else {
        throw new Error(data.error || "Failed to generate description")
      }
    } catch (error) {
      console.error("Error generating description:", error)
      this.showStatus(error.message || "Could not generate description. Please enter manually.", "error")
      this.descriptionFieldTarget.disabled = false
    }
  }

  async regenerate(event) {
    event.preventDefault()
    
    // Look for the hidden field that contains the signed blob ID
    const hiddenInput = this.element.querySelector('input[type="hidden"][name*="[image]"]')
    const signedId = hiddenInput ? hiddenInput.value : null
    
    if (!signedId) {
      this.showStatus("Please upload an image first", "error")
      return
    }

    this.showStatus("🤖 Regenerating description...", "loading")
    this.descriptionFieldTarget.disabled = true
    
    await this.generateDescription(signedId)
  }

  showStatus(message, type) {
    if (!this.hasStatusMessageTarget) return

    const statusEl = this.statusMessageTarget
    statusEl.textContent = message
    statusEl.classList.remove("text-blue-600", "text-green-600", "text-red-600", "text-gray-600", "hidden")

    switch (type) {
      case "loading":
        statusEl.classList.add("text-blue-600")
        break
      case "success":
        statusEl.classList.add("text-green-600")
        break
      case "error":
        statusEl.classList.add("text-red-600")
        break
      default:
        statusEl.classList.add("text-gray-600")
    }
  }
}
