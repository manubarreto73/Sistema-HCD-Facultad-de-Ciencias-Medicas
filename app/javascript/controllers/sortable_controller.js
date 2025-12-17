import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "order", "submit", "dirtyBadge"]

  connect() {
    this.dragged = null
    this.dirty = false
  }

  dragstart(event) {
    this.dragged = event.currentTarget.closest("tr")
    this.dragged.classList.add("opacity-50", "scale-95")
    event.dataTransfer.effectAllowed = "move"
  }

  dragover(event) {
    event.preventDefault()
  }

  drop(event) {
    event.preventDefault()

    const targetRow = event.currentTarget.closest("tr")
    if (!this.dragged || targetRow === this.dragged) return

    const rect = targetRow.getBoundingClientRect()
    const next = event.clientY > rect.top + rect.height / 2

    targetRow.parentNode.insertBefore(
      this.dragged,
      next ? targetRow.nextSibling : targetRow
    )

    this.markDirty()
    this.updatePositions()
  }

  dragend() {
    if (this.dragged) {
      this.dragged.classList.remove("opacity-50", "scale-95")
    }
    this.dragged = null
  }

  markDirty() {
    if (this.dirty) return
    this.dirty = true

    this.submitTarget.disabled = false
    this.submitTarget.classList.remove("opacity-50", "cursor-not-allowed")
    this.dirtyBadgeTarget.classList.remove("hidden")
  }

  updatePositions() {
    [...this.listTarget.children].forEach((row, index) => {
      const positionCell = row.querySelectorAll("td")[1]
      if (positionCell) positionCell.textContent = index + 1
    })
  }

  submit() {
    const ids = [...this.listTarget.children].map(row =>
      row.dataset.sortableIdValue
    )
    this.orderTarget.value = ids.join(",")
  }
}
