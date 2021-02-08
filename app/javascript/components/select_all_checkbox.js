window.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.select_all').forEach((checkbox_select_all) => {
    const updateCheckboxes = () => {
      var checkboxes = document.querySelectorAll("."+checkbox_select_all.id)

      if (checkbox_select_all.checked == true) {
        checkboxes.forEach((checkbox) => {
          checkbox.checked = true
        })
      }
      else {
        checkboxes.forEach((checkbox) => {
          checkbox.checked = false
        })
      }
    }
    checkbox_select_all.addEventListener('change', updateCheckboxes)
  })
});
