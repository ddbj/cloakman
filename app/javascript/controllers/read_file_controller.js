import { Controller } from '@hotwired/stimulus';

export default class ReadFileController extends Controller {
  static targets = [
    'destination'
  ];

  async read(e) {
    const file = e.target.files[0];

    this.destinationTarget.value = await file.text();
  }
}
