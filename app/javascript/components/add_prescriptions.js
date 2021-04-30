const submitForm = (event) => {
  const checked = event.srcElement.checked;
  const alineaId = event.srcElement.dataset.alineaId;
  const formIdPrefix = checked
    ? "#alinea_checkbox_form_"
    : "#delete_prescription_";
  const form = $(formIdPrefix + alineaId)[0];
  Rails.fire(form, checked ? "submit" : "click");
};

window.addEventListener("load", () => {
  const checkboxes = document.querySelectorAll(".alineas_checkbox");
  checkboxes.forEach((checkbox) => {
    checkbox.addEventListener("change", submitForm);
  });
});
