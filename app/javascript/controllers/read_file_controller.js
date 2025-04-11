import { Controller } from '@hotwired/stimulus';

export default class ReadFileController extends Controller {
  static targets = [
    'destination'
  ];

  async read({ target }) {
    const file = target.files[0];

    this.destinationTarget.value = await file.text();
    target.value = null;
  }
}
