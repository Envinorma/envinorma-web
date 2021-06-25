const deactivateAllButtons = () => {
  document.querySelectorAll(".topic-button").forEach((topicButton) => {
    topicButton.classList.replace("btn-success", "btn-light");
  });
};

const activateButton = (button) => {
  button.classList.replace("btn-light", "btn-success");
};

const hideAllElements = () => {
  document.querySelectorAll(".summary_element").forEach((element) => {
    element.classList.add("d-none");
  });
};
const showElements = (topic) => {
  document.querySelectorAll(".topic_" + topic).forEach((element) => {
    element.classList.remove("d-none");
  });
};

const filterSummary = (event) => {
  deactivateAllButtons();
  activateButton(event.target);
  hideAllElements();
  showElements(event.target.dataset.topic);
};

window.addEventListener("load", () => {
  const topicButtons = document.querySelectorAll(".topic-button");
  topicButtons.forEach((topicButton) => {
    topicButton.addEventListener("click", filterSummary);
  });
});
