window.addEventListener('DOMContentLoaded', () => {
  let mainNavLinks = document.querySelectorAll(".am_nav a");
  let mainSections = document.querySelectorAll(".container section");

  let mainSummary = document.querySelectorAll(".summary .display-summary");
  let mainSummaryLinks = document.querySelectorAll(".summary a");
  let mainSummaryAnchors = document.querySelectorAll(".anchor-summary");

  let lastId;
  let cur = [];

  mainNavLinks[0].classList.add("current");
  mainSummary[0].classList.add("current");
  // This should probably be throttled.
  // Especially because it triggers during smooth scrolling.
  // https://lodash.com/docs/4.17.10#throttle
  // You could do like...
  // window.addEventListener("scroll", () => {
  //    _.throttle(doThatStuff, 100);
  // });
  // Only not doing it here to keep this Pen dependency-free.

  window.addEventListener("scroll", event => {
    let fromTop = window.scrollY;

    mainNavLinks.forEach(link => {
      // let section = document.querySelector(link.hash);
      let section = document.querySelector(`section${link.hash}`);
      let summary = document.querySelector(`div${link.hash}-summary`);

      if (
        section.offsetTop <= fromTop &&
        section.offsetTop + section.offsetHeight > fromTop
      ) {
        link.classList.add("current");
        summary.classList.add("current");
      } else {
        link.classList.remove("current");
        summary.classList.remove("current");
      }
    });

    mainSummaryLinks.forEach(summary_link => {
      // let section = document.querySelector(link.hash);
      let summary_anchor = document.querySelector(summary_link.hash);

      if (
        summary_anchor.offsetTop <= fromTop &&
        summary_anchor.offsetTop + summary_anchor.offsetHeight > fromTop
      ) {
        summary_link.classList.add("current");

      } else {
        summary_link.classList.remove("current");
      }
    });
  });
});
