// Import Rails UJS
import { Turbo } from "@hotwired/turbo-rails"
import Rails from "@rails/ujs"
import "popper"
import "bootstrap"
import "leaflet"
import "leaflet-draw"

// Start Rails UJS
Rails.start()
Turbo.start()
import "maps"
