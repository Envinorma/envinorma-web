const setStateSelectAllCheckbox = (checkboxSelectAll) => {
  const id = checkboxSelectAll.id;
  const checkboxes = document.querySelectorAll('.' + id);

  const checkboxesChecked = document.querySelectorAll(`.${id}:checked`);

  if (checkboxes.length === checkboxesChecked.length) {
    checkboxSelectAll.checked = true;
  } else {
    checkboxSelectAll.checked = false;
  }
};

const updateStateSelectAllCheckbox = (event) => {
  const checkbox = event.target;
  const allCheckboxClass = Array.from(checkbox.classList);
  const classNameSelectAll = allCheckboxClass.filter((className) => className.startsWith('select_all'));
  const idTarget = classNameSelectAll[0];
  const checkboxSelectAll = document.querySelector(`#${idTarget}`);

  if (checkboxSelectAll === null) return;

  if (checkbox.checked) {
    setStateSelectAllCheckbox(checkboxSelectAll);
  } else {
    checkboxSelectAll.checked = false;
  }
};

const updateStateChildCheckboxes = (event) => {
  const checkboxSelectAll = event.target;
  const checkboxes = document.querySelectorAll('.' + checkboxSelectAll.id);

  checkboxes.forEach((checkbox) => {
    if (checkbox.checked !== checkboxSelectAll.checked) {
      checkbox.checked = checkboxSelectAll.checked;
      checkbox.dispatchEvent(new Event('change'));
    }
  });
};

window.addEventListener('DOMContentLoaded', () => {
  // all checkbox .select_all
  document.querySelectorAll('.select_all').forEach((checkboxSelectAll) => {
    setStateSelectAllCheckbox(checkboxSelectAll);
    checkboxSelectAll.addEventListener('change', updateStateChildCheckboxes);
  });

  // all checkbox child of .select_all
  document.querySelectorAll('input[class*="select_all_"]').forEach((checkbox) => {
    checkbox.addEventListener('click', updateStateSelectAllCheckbox);
  });
});
