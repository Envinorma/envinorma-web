let positionElementsWithDynamicHeight = () => {
  if (document.querySelector(".sidebar-sticky") != null) {
    let navHeight = computeNavHeight();
    let viewport = window.innerHeight;

    positionSummary(navHeight, viewport);
    positionAnchors(navHeight, viewport);
  };
};

let computeNavHeight = () => {
  let headerHeight = document.querySelector(".header").offsetHeight;
  let topicsNavHeight = document.querySelector(".topics_nav").offsetHeight;
  return headerHeight + topicsNavHeight
}

let positionSummary = (navHeight, viewport) => {
  document.querySelectorAll(".summary").forEach((summary) => {
    summary.style.top = navHeight + 'px';
    summary.style.height = (viewport - navHeight) + 'px';
  });
}

let positionAnchors = (navHeight, viewport) => {
  document.querySelectorAll("section.anchor, div.anchor").forEach((section) => {
    section.style.marginTop = '-' + navHeight + 'px';
    section.style.paddingTop = navHeight + 'px';
  });
}

window.addEventListener("load", () => {
  positionElementsWithDynamicHeight()
  window.addEventListener('resize', positionElementsWithDynamicHeight);
});
