const submitForm = (event) => {
  const checked = event.srcElement.checked;
  const sectionId = event.srcElement.dataset.sectionId;
  const formIdPrefix = checked
    ? "#select_all_checkbox_form_"
    : "#select_all_checkbox_delete_";
  const form = $(formIdPrefix + sectionId)[0];
  Rails.fire(form, "submit");
};

const updateCheckboxes = (event) => {
  const checkbox_select_all = event.srcElement;
  const checkboxes = document.querySelectorAll("." + checkbox_select_all.id);

  checkboxes.forEach((checkbox) => {
    if (checkbox.checked !== checkbox_select_all.checked) {
      checkbox.checked = checkbox_select_all.checked;
    }
  });
};

window.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".select_all").forEach((checkbox_select_all) => {
    checkbox_select_all.addEventListener("change", updateCheckboxes);
    checkbox_select_all.addEventListener("change", submitForm);
  });
});
