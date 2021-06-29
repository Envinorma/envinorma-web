const fireModalGeneration = () => {
  Rails.fire(document.querySelector("#recap-opener"), "submit");
};

const clickRecapOpener = () => {
  document.querySelector("#recap-grouping").value = document.querySelector(
    "#recap-grouping-checbox"
  ).checked;
  fireModalGeneration();
};

window.addEventListener("load", () => {
  document
    .querySelector("#recap-opener")
    .addEventListener("click", fireModalGeneration);
  document
    .querySelector("#recap-grouping-checbox")
    .addEventListener("click", clickRecapOpener);
});
