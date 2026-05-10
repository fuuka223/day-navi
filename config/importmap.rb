# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "schedule_timeline"
pin "schedule_form"
pin "top_count_down"
pin "top_timeline_scroller"
pin "task_form_handler"
pin "task_list_handler"