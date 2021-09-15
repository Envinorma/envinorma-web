const setStateSelectAllCheckbox = (checkbox_select_all) => {
  const checkboxes = document.querySelectorAll("." + checkbox_select_all.id);
  var id = checkbox_select_all.id

  const checkboxes_checked = document.querySelectorAll(`.${id}:checked`)

  if (checkboxes.length === checkboxes_checked.length) {
      checkbox_select_all.checked = true
  } else {
      checkbox_select_all.checked = false
  }
}

const updateStateSelectAllCheckbox = (event) => {
  const checkbox = event.target
  const all_checkbox_class = Array.from(checkbox.classList)
  const class_name_select_all = all_checkbox_class.filter((class_name) => class_name.startsWith("select_all"));
  const id_target = class_name_select_all[0]
  const checkbox_select_all = document.querySelector(`#${id_target}`)

  if (checkbox_select_all == null) return;

  if (checkbox.checked) {
    setStateSelectAllCheckbox(checkbox_select_all)
  }
  else {
    checkbox_select_all.checked = false
  }
}

const updateStateChildCheckboxes = (event) => {
  const checkbox_select_all = event.target;
  const checkboxes = document.querySelectorAll("." + checkbox_select_all.id);

  checkboxes.forEach((checkbox) => {
    if (checkbox.checked !== checkbox_select_all.checked) {
      checkbox.checked = checkbox_select_all.checked;
      checkbox.dispatchEvent(new Event("change"));
    }
  });
};

window.addEventListener("DOMContentLoaded", () => {
  // all checkbox .select_all
  document.querySelectorAll(".select_all").forEach((checkbox_select_all) => {
    setStateSelectAllCheckbox(checkbox_select_all)
    checkbox_select_all.addEventListener("change", updateStateChildCheckboxes);
  });

  // all checkbox child of .select_all
  document.querySelectorAll('input[class*="select_all_"]').forEach((checkbox) => {
    checkbox.addEventListener("click", updateStateSelectAllCheckbox);
  })
});
