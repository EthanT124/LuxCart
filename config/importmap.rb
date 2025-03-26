# Pin npm packages by running ./bin/importmap

pin "application"
pin "@rails/ujs", to: "rails-ujs.js"
# config/importmap.rb
pin "embla-carousel", to: "https://cdn.jsdelivr.net/npm/embla-carousel@latest/embla-carousel.umd.js"
