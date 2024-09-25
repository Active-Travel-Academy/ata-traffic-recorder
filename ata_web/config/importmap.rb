# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@rails/ujs", to: "https://cdn.skypack.dev/@rails/ujs", preload: true
pin "leaflet", to: "https://unpkg.com/leaflet@#{Leaflet::VERSION}/dist/leaflet.js", preload: true
pin "leaflet-draw", to: "https://unpkg.com/leaflet-draw@#{Leaflet::DRAW_VERSION}/dist/leaflet.draw.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "popper", to: 'popper.js', preload: true
pin "bootstrap", to: 'bootstrap.min.js', preload: true
pin "maps", to: "maps.js"
