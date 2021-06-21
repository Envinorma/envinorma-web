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

const checkedApdIds = () => {
  const checked = _.filter(
    $(".js_ap_checkbox"),
    (checkbox) => checkbox.checked
  );
  return _.map(checked, (checkbox) => {
    return checkbox.dataset.apId;
  });
};

const changeArretesLinkButtonHref = (button) => {
  const arrete_ids = checkedArretedIds()
  const ap_ids = checkedApdIds()

  const hrefBase = button.href.split("?")[0];
  var arrete_ids_url = ""
  var ap_ids_url = ""

  if (arrete_ids.length != 0) {
    arrete_ids_url = "arrete_ids[]=" + arrete_ids.join("&arrete_ids[]=")
  }

  if (ap_ids.length != 0) {
    ap_ids_url = "ap_ids[]=" + ap_ids.join("&ap_ids[]=")
  }

  if (arrete_ids_url != "" && ap_ids_url != "") {
    button.href = hrefBase + "?" + arrete_ids_url + "&" + ap_ids_url
  }
  else if (arrete_ids_url == "" && ap_ids_url == "") {
    button.href = hrefBase;
  }
  else {
    button.href = hrefBase + "?" + (arrete_ids_url || ap_ids_url)
  }
};

window.addEventListener("DOMContentLoaded", () => {
  const button = $("#arretes_link_button")[0];
  if (!button) {
    return;
  }

  changeArretesLinkButtonHref(button); // Execute at page load

  const checkboxes = document.querySelectorAll(".js_checkbox");
  checkboxes.forEach((checkbox) => {
    checkbox.addEventListener("change", () =>
      changeArretesLinkButtonHref(button)
    );
  });
});
