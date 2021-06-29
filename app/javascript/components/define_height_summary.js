const defineSummaryHeight = () => {
  if (document.querySelector(".sidebar-sticky") != null) {
    var height_main_nav = document.querySelector(".header").offsetHeight;
    var height_topics_nav = document.querySelector(".topics_nav").offsetHeight;
    var height_both_nav = height_main_nav + height_topics_nav
    var viewport = window.innerHeight;

    document.querySelectorAll(".summary").forEach((summary) => {
      summary.style.top = height_both_nav + 'px';
      summary.style.height = (viewport - height_both_nav) + 'px';
    });

    document.querySelectorAll("section.anchor, div.anchor").forEach((section) => {
      section.style.marginTop = '-' + height_both_nav + 'px';
      section.style.paddingTop = height_both_nav + 'px';
    });
  };
};

window.addEventListener("load", () => {
  defineSummaryHeight()
  window.addEventListener('resize', defineSummaryHeight);
});


