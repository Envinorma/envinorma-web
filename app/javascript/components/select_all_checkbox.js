window.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".select_all").forEach((checkbox_select_all) => {
    const updateCheckboxes = () => {
      var checkboxes = document.querySelectorAll("." + checkbox_select_all.id);

      checkboxes.forEach((checkbox) => {
        if (checkbox.checked !== checkbox_select_all.checked) {
          checkbox.checked = checkbox_select_all.checked;
          checkbox.dispatchEvent(new Event("change"));
        }
      });
    };
    checkbox_select_all.addEventListener("change", updateCheckboxes);
  });
});
