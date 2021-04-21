const _ = require("underscore");

const uncheckCheckbox = (prescriptionId) => {
  const event = new Event("change");
  const checkbox = document.querySelector(
    `#prescriptions_${prescriptionId}_checkbox`
  );
  checkbox.checked = false;
  checkbox.dispatchEvent(event);
};

const buildElement = (tag, ...children) => {
  var element = document.createElement(tag);
  element.append(...children);
  return element;
};

const deleteButton = (prescriptionId) => {
  var button = buildElement("a", "supprimer");
  button.href = "javascript:void(0)";
  button.addEventListener("click", () => {
    uncheckCheckbox(prescriptionId);
  });
  return button;
};

const renderPrescription = ({ content, id }) => {
  return buildElement("div", buildElement("p", content), buildElement("p", deleteButton(id)));
};

const renderSectionsPrescription = (prescriptions, reference) => {
  const prescription_nodes = _.map(prescriptions, renderPrescription);
  return buildElement(
    "div",
    buildElement("strong", reference),
    ...prescription_nodes
  );
};

const renderAMPrescriptions = (prescriptions) => {
  const amRef = _.first(prescriptions).amRef;
  groups = _.groupBy(prescriptions, (prescription) => {
    return prescription.reference;
  });
  const prescriptionGroups = _.map(groups, (group, reference) => {
    return renderSectionsPrescription(group, reference);
  });
  return buildElement("div", buildElement("h6", amRef), ...prescriptionGroups);
};

const renderRecap = (prescriptions) => {
  groups = _.groupBy(prescriptions, (prescription) => {
    return prescription.amId;
  });
  return buildElement("div", ..._.map(groups, renderAMPrescriptions));
};

const writeRecap = (newPrescriptions) => {
  var recap = document.querySelector("#prescriptions_recap");
  recap.innerHTML = "";
  recap.append(renderRecap(newPrescriptions));
};

const updatePrescriptionRecap = () => {
  const alineaCheckboxes = document.querySelectorAll(".alineas_checkbox");
  const checkedPrescriptions = _.filter(alineaCheckboxes, (checkbox) => {
    return checkbox.checked;
  });
  writeRecap(_.pluck(checkedPrescriptions, "dataset"));
};

const persistCheckboxChange = ({ checked, dataset }) => {
  $.ajax({
    type: checked ? "POST" : "DELETE",
    url: "/prescriptions",
    data: dataset,
    dataType: "json",
    encode: true,
  });
};

const persistSelectAllCheckboxChanges = (selectAllCheckbox) => {
  _.map(document.querySelectorAll("." + selectAllCheckbox.id), (checkbox) => {
    persistCheckboxChange({
      checked: selectAllCheckbox.checked,
      dataset: checkbox.dataset,
    });
  });
};

window.addEventListener("load", () => {
  updatePrescriptionRecap();

  const checkboxes = document.querySelectorAll(".alineas_checkbox");
  _.map(checkboxes, (checkbox) => {
    checkbox.addEventListener("change", updatePrescriptionRecap);
    checkbox.addEventListener("change", () => {
      persistCheckboxChange(checkbox);
    });
  });

  const selectAllCheckboxes = document.querySelectorAll(".select_all");
  _.map(selectAllCheckboxes, (selectAllCheckbox) => {
    selectAllCheckbox.addEventListener("change", updatePrescriptionRecap);
    selectAllCheckbox.addEventListener("change", () =>
      persistSelectAllCheckboxChanges(selectAllCheckbox)
    );
  });
});
