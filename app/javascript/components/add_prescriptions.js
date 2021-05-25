const submitForm = (event) => {
  const alineaId = event.target.dataset.alineaId;
  const formIdPrefix = "#alinea_checkbox_form_"
  const form = $(formIdPrefix + alineaId)[0];
  Rails.fire(form, "submit");
};

window.addEventListener("load", () => {
  const checkboxes = document.querySelectorAll(".alineas_checkbox");
  checkboxes.forEach((checkbox) => {
    checkbox.addEventListener("change", submitForm);
  });
});
