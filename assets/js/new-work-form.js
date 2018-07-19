// import Vue from 'vue'
// import NewWF from "../components/new-work-form.vue"
//
// // Create the main component
// Vue.component('new-work-form', NewWF)
//
// // And create the top-level view model:
// new Vue({
//   el: '#new_work',
//   render(createElement) {
//     return createElement(NewWF, {})
//   }
// });

export var NewWorkForm = {
  init: () => {
    if ($("form#new_work").length === 0) return;

    let hours = $('input#work_hours')
    let total = $('input#work_total')

    let rate = () => {
      let v = $('select#work_project_id option[selected]').data('rate')
      return parseInt(v)
    }

    let updateTotal = () => {
      let hr = parseFloat(hours.val())
      let to = hr * rate()
      total.val(isNaN(to) ? "" : to)
    }

    hours.on("change", updateTotal).on('keyup', updateTotal)

    $('input#work_task').focus()
  }
}
