window.addEventListener('load', () => {
  document.querySelector(".spinner").classList.remove("active");
});

window.addEventListener('DOMContentLoaded', () => {
  const links = document.querySelectorAll('.js_loader__link');
  for (const link of links) {
    link.addEventListener('click', function() {
      document.querySelector(".spinner").classList.add("active");
    });
  }
});
