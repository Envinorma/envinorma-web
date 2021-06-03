const _ = require("underscore");

const checkedArretedIds = () => {
  const checked = _.filter(
    $(".js_arrete_checkbox"),
    (checkbox) => checkbox.checked
  );
  return _.map(checked, (checkbox) => {
    return checkbox.dataset.arreteId;
  });
};

const changeArretesLinkButtonHref = (button) => {
  const ids = checkedArretedIds();
  const hrefBase = button.href.split("?")[0];
  if (ids.length == 0) {
    button.href = hrefBase;
    return;
  }
  button.href = hrefBase + "?arrete_ids[]=" + ids.join("&arrete_ids[]=");
};

window.addEventListener("DOMContentLoaded", () => {
  const button = $("#arretes_link_button")[0];
  if (!button) {
    return;
  }

  const checkboxes = document.querySelectorAll(".js_arrete_checkbox");
  checkboxes.forEach((checkbox) => {
    checkbox.addEventListener("change", () =>
      changeArretesLinkButtonHref(button)
    );
  });
});
