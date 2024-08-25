# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@rails/ujs", to: "https://cdn.skypack.dev/@rails/ujs", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "popper", to: 'popper.js', preload: true
pin "bootstrap", to: 'bootstrap.min.js', preload: true
