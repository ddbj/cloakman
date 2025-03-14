import { Controller } from '@hotwired/stimulus';

export default class ReformController extends Controller {
  static values = {
    visitOptions: Object
  };

  static targets = [
    'form'
  ];

  visit() {
    const form = this.hasFormTarget ? this.formTarget : this.element;
    const data = new FormData(form);
    const url  = new URL(location.href);

    url.search = new URLSearchParams(data).toString();

    Turbo.visit(url.toString(), this.visitOptionsValue);
  }
}
