const _ = require("underscore");

const renderPrescription = ({ content }) => {
  return "<p>" + content + "</p>";
};

const renderSectionsPrescription = (prescriptions, reference) => {
  const prescriptionGroup = _.map(prescriptions, renderPrescription).join("");
  return "<h5>" + reference + "</h5>" + prescriptionGroup;
};

const renderAMPrescriptions = (prescriptions) => {
  const amRef = _.first(prescriptions).amRef;
  groups = _.groupBy(prescriptions, (prescription) => {
    return prescription.reference;
  });
  const prescriptionGroups = _.map(groups, (group, reference) => {
    return renderSectionsPrescription(group, reference);
  }).join("");
  return "<h4>" + amRef + "</h4>" + prescriptionGroups;
};

const renderRecap = (prescriptions) => {
  groups = _.groupBy(prescriptions, (prescription) => {
    return prescription.amId;
  });
  return _.map(groups, renderAMPrescriptions).join("");
};

const writeRecap = (newPrescriptions) => {
  document.querySelector("#prescriptions_recap").innerHTML = renderRecap(
    newPrescriptions
  );
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
