const submitForm = (event) => {
  const formId = event.target.dataset.formId;
  const formIdPrefix = '#alinea_checkbox_form_';
  const form = $(formIdPrefix + formId)[0];
  Rails.fire(form, 'submit');
};

window.addEventListener('load', () => {
  const checkboxes = document.querySelectorAll('.alineas_checkbox');
  checkboxes.forEach((checkbox) => {
    checkbox.addEventListener('click', submitForm);
  });
});

// Listen event from select_all_checkbox.js
// To let time after clicking on select_all checkbox
// for all checkbox to be checked before submitting form
window.addEventListener('selectAllCheckboxAndChildrenUpdated', (evt) => submitForm(evt.detail), false);
