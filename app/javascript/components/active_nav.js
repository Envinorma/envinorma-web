window.addEventListener('DOMContentLoaded', () => {

  if (document.querySelector(".sidebar-sticky") != null) {

    let mainNavLinks = document.querySelectorAll(".sidebar-sticky .nav a");
    let mainSections = document.querySelectorAll(".container section");
    let mainSummary = document.querySelectorAll(".summary .display-summary");
    let mainSummaryLinks = document.querySelectorAll(".summary a");
    let mainSummaryAnchors = document.querySelectorAll(".anchor-summary");

    let lastId;
    let cur = [];

    if (mainSummary.length !== 0) {
      mainSummary[0].classList.add("active");
    }

    mainNavLinks[0].classList.replace("btn-light", "btn-primary");

    // This should probably be throttled.
    // Especially because it triggers during smooth scrolling.
    // https://lodash.com/docs/4.17.10#throttle
    // You could do like...
    // window.addEventListener("scroll", () => {
    //    _.throttle(doThatStuff, 100);
    // });
    // Only not doing it here to keep this Pen dependency-free.

    window.addEventListener("scroll", event => {
      var navHeight = 150;
      let fromTop = window.scrollY + navHeight;

      mainNavLinks.forEach(link => {
        // let section = document.querySelector(link.hash);
        let section = document.querySelector(`section${link.hash}`);
        let summary = document.querySelector(`div${link.hash}_summary`);

        if (
          section.offsetTop <= fromTop &&
          section.offsetTop + section.offsetHeight > fromTop
        ) {
          link.classList.replace("btn-light", "btn-primary");
          if ( summary != null) {

            summary.classList.add("current");
          }
        } else {
          link.classList.replace("btn-primary", "btn-light");
          if ( summary != null) {
            summary.classList.remove("current");
          }
        }
      });

      // mainSummaryLinks.forEach(summary_link => {
      //   // let section = document.querySelector(link.hash);
      //   let summary_anchor = document.querySelector(summary_link.hash);

      //   if (
      //     summary_anchor.offsetTop <= fromTop &&
      //     summary_anchor.offsetTop + summary_anchor.offsetHeight > fromTop
      //   ) {
      //     summary_link.classList.add("current");

      //   } else {
      //     summary_link.classList.remove("current");
      //   }
      // });
    });

  }
});
