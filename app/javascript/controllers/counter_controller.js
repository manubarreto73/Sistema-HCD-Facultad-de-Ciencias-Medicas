import { Controller } from "@hotwired/stimulus"

// Controlador que oculta el mensaje de error después de unos segundos
export default class extends Controller {
  static values = { treated: Number, notTreated: Number }
  connect() {
    const treated_div = document.getElementById('resueltos');
    const no_treated_div = document.getElementById('no_resueltos');
    console.log(this.treatedValue)
    if (this.treatedValue == 0) {
      treated_div.textContent = 'Resueltos';
    } else {
      treated_div.textContent = 'Resueltos ('  + this.treatedValue + ')';
    }
     if (this.notTreatedValue == 0) {
     no_treated_div.textContent = 'Resueltos';
    } else {
      no_treated_div.textContent = 'No resueltos ('  + this.notTreatedValue + ')';
    }
  }
}