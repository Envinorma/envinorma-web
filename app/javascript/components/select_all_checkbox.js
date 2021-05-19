const updateCheckboxes = (event) => {
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
  document.querySelectorAll(".select_all").forEach((checkbox_select_all) => {
    checkbox_select_all.addEventListener("change", updateCheckboxes);
  });
});
