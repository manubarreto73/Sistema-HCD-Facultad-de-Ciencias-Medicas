import { Controller } from "@hotwired/stimulus"

// Controlador que oculta el mensaje de error después de unos segundos
export default class extends Controller {
  connect() {
    // tiempo en milisegundos (ej: 3 segundos)
    this.timeout = setTimeout(() => {
      this.fadeOut()
    }, 2000)
  }

  fadeOut() {
    this.element.classList.add("opacity-0", "transition", "duration-700")
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}