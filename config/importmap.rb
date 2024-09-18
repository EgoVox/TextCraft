# Pin npm packages by running ./bin/importmap

pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@rails/ujs", to: "https://cdn.jsdelivr.net/npm/@rails/ujs@7.0.4/lib/assets/compiled/rails-ujs.js"

pin "application"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"

pin "burger_menu", to: "burger_menu.js"
pin "category_menu_dropdown", to: "category_menu_dropdown.js"
pin "index_carousel", to: "index_carousel.js"
pin "user_menu_dropdown", to: "user_menu_dropdown.js"
pin "switch_mode", to: "switch_mode.js"
pin "color_picker", to: "color_picker.js"
pin "color_utils", to: "color_utils.js"

pin_all_from "app/javascript", under: "javascript"
