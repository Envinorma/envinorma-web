const deactivateAllButtons = () => {
  document.querySelectorAll(".topic-button").forEach((topicButton) => {
    topicButton.classList.replace("btn-primary", "btn-light");
  });
};

const activateButton = (button) => {
  button.classList.replace("btn-light", "btn-primary");
};

const hideAllElements = () => {
  document.querySelectorAll(".filterable").forEach((element) => {
    element.classList.add("d-none");
  });

  document.querySelectorAll(".empty-illu").forEach((element) => {
    element.classList.add("d-none");
  });
};

const showAllElements = () => {
  document.querySelectorAll(".filterable").forEach((element) => {
    element.classList.remove("d-none");
  });
};

const showElements = (topic) => {
  document.querySelectorAll(".topic_" + topic).forEach((element) => {
    element.classList.remove("d-none");
  });

  document.querySelectorAll(".am-content").forEach((content) => {
    if (content.querySelectorAll(".filterable.d-none").length == content.querySelectorAll(".filterable").length) {
      content.querySelector(".empty-illu").classList.remove("d-none")
    }
  });

};

const filterSummary = (event) => {
  document.querySelector(".spinner").classList.add("fade-in");
  document.querySelector(".spinner").classList.add("active");
  setTimeout(() => {

    if (event.target.classList.contains("btn-primary")) {
      resetFilter()
      return
    }

    deactivateAllButtons();
    activateButton(event.target);
    hideAllElements();
    showElements(event.target.dataset.topic);
    document.querySelector(".spinner").classList.remove("active");
  }, 500);
};

const resetFilter = () => {
  deactivateAllButtons();
  showAllElements();
  document.querySelector(".spinner").classList.remove("active");
}

window.addEventListener("load", () => {
  const topicButtons = document.querySelectorAll(".topic-button");
  topicButtons.forEach((topicButton) => {
    topicButton.addEventListener("click", filterSummary);
  });
});
