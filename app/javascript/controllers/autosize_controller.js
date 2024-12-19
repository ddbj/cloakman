import { Controller } from "@hotwired/stimulus";

import autosize from "autosize";

export default class AutosizeController extends Controller {
  connect() {
    autosize(this.element);
  }
}
