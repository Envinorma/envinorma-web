const _ = require('underscore');

const checkedCheckboxes = (selector) => {
  return $(selector).filter(':checked');
};

const checkedAmIds = () => {
  return _.map(checkedCheckboxes('.js_am_checkbox'), (checkbox) => checkbox.dataset.amId);
};

const checkedApIds = () => {
  return _.map(checkedCheckboxes('.js_ap_checkbox'), (checkbox) => checkbox.dataset.apId);
};

const buildKeyArgumentString = (argumentName, values) => {
  const keyValues = _.map(values, (value) => `${argumentName}[]=${value}`);
  return keyValues.join('&');
};

export const buildUrlFromCheckedArretes = (hrefBase, amIds, apIds) => {
  const amString = buildKeyArgumentString('am_ids', amIds);
  const apString = buildKeyArgumentString('ap_ids', apIds);
  const nonEmptyStrings = _.filter([amString, apString], (string) => string !== '');
  return hrefBase + '?' + nonEmptyStrings.join('&');
};

const changeArretesLinkButtonHref = (button) => {
  const amIds = checkedAmIds();
  const apIds = checkedApIds();
  const hrefBase = button.href.split('?')[0];
  const url = buildUrlFromCheckedArretes(hrefBase, amIds, apIds);

  if (amIds.length === 0 && apIds.length === 0) {
    button.classList.add('d-none');
  } else {
    button.href = url;
    button.classList.remove('d-none');
  }
};

if (window.addEventListener) {
  console.log(window);
  console.log(window.addEventListener);
  window.addEventListener('DOMContentLoaded', () => {
    const button = $('#arretes_link_button')[0];
    if (!button) {
      return;
    }

    changeArretesLinkButtonHref(button); // Execute at page load

    const checkboxes = document.querySelectorAll('.js_checkbox');
    checkboxes.forEach((checkbox) => {
      checkbox.addEventListener('change', () => changeArretesLinkButtonHref(button));
    });
  });
}
