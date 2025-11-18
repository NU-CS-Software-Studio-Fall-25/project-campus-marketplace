import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["imageInput", "descriptionField", "generateButton", "statusMessage", "categoryField"]
  static values = {
    generateUrl: String
  }

  connect() {
    // Ensure the description field is editable by default
    if (this.hasDescriptionFieldTarget) {
      this.descriptionFieldTarget.disabled = false
    }

    if (this.hasImageInputTarget) {
      this.imageInputTarget.addEventListener("change", (event) => {
        if (event.target.files.length > 0) {
          this.handleFileSelect(event.target.files[0])
        }
      })
    }
  }

  async handleFileSelect(file) {
    this.showStatus("📤 Uploading image...", "loading")

    const uploadUrl = this.imageInputTarget.dataset.directUploadUrl || "/rails/active_storage/direct_uploads"
    const upload = new DirectUpload(file, uploadUrl)

    upload.create((error, blob) => {
      if (error) {
        this.showStatus("Upload failed. Please try again.", "error")
        return
      }

      const hiddenField = document.createElement("input")
      hiddenField.type = "hidden"
      hiddenField.name = this.imageInputTarget.name
      hiddenField.value = blob.signed_id
      this.element.appendChild(hiddenField)

      this.generateDescriptionFromSignedId(blob.signed_id)
    })
  }

  async generateDescriptionFromSignedId(signedId) {
    if (!signedId) return

    this.showStatus("🤖 Analyzing image with AI...", "loading")
    this.descriptionFieldTarget.disabled = true

    try {
      await this.generateDescription(signedId)
    } catch (error) {
      this.showStatus("Could not generate description automatically. Please enter manually.", "error")
      this.descriptionFieldTarget.disabled = false
    }
  }

  async generateDescription(signedId) {
    const response = await fetch(this.generateUrlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ signed_id: signedId })
    })

    const data = await response.json()

    if (response.ok && data.description) {
      this.descriptionFieldTarget.value = data.description
      this.applyCategory(data.category)
      this.showStatus("✨ AI description generated! Feel free to edit.", "success")
      this.descriptionFieldTarget.disabled = false
      this.descriptionFieldTarget.focus()

      if (this.hasGenerateButtonTarget) {
        this.generateButtonTarget.classList.remove("hidden")
      }
    } else {
      throw new Error(data.error || "Failed to generate description")
    }
  }

  async regenerate(event) {
    event.preventDefault()

    const hiddenInput = this.element.querySelector('input[type="hidden"][name*="[image]"]')
    const signedId = hiddenInput ? hiddenInput.value : null

    if (!signedId) {
      this.showStatus("Please upload an image first", "error")
      return
    }

    this.showStatus("🔄 Regenerating description...", "loading")
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

  applyCategory(category) {
    if (!category || !this.hasCategoryFieldTarget) return

    const normalized = category.toString().toLowerCase()
    const select = this.categoryFieldTarget
    const optionExists = Array.from(select.options).some((option) => option.value === normalized)

    if (optionExists) {
      select.value = normalized
    }
  }
}
