window.addEventListener('DOMContentLoaded', () => {
  let mainNavLinks = document.querySelectorAll(".am_nav a");
  let mainSections = document.querySelectorAll(".container section");
  let mainNavSommaire = document.querySelectorAll(".sommaire .display-sommaire");

  let lastId;
  let cur = [];

  mainNavLinks[0].classList.add("current");
  mainNavSommaire[0].classList.add("current");
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
      let sommaire = document.querySelector(`div${link.hash}-sommaire`);

      if (
        section.offsetTop <= fromTop &&
        section.offsetTop + section.offsetHeight > fromTop
      ) {
        link.classList.add("current");
        sommaire.classList.add("current");
      } else {
        link.classList.remove("current");
        sommaire.classList.remove("current");
      }
    });
  });
});
