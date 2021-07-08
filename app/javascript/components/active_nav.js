window.addEventListener('DOMContentLoaded', () => {

  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      const id = entry.target.getAttribute('id');
      if (entry.intersectionRatio > 0) {
        document.querySelector(`nav li a[href="#${id}"]`).classList.replace("btn-light", "btn-primary");
      } else {
        document.querySelector(`nav li a[href="#${id}"]`).classList.replace("btn-primary", "btn-light");
      }
    });
  });

  const observerSummary = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      const id = entry.target.getAttribute('id');
      if (entry.intersectionRatio > 0) {
        console.log(id)
        console.log(entry.target)
        console.log(document.querySelector(`dd a[href="#${id}"]`))
        document.querySelector(`dd a[href="#${id}"]`).classList.add('btn-primary');
      } else {
        document.querySelector(`dd a[href="#${id}"]`).classList.remove('btn-primary');
      }
    });
  });

  // Track all sections that have an `id` applied
  document.querySelectorAll('section[id]').forEach((section) => {
    observer.observe(section);
  });

  // Track all anchors summary
  document.querySelectorAll('.anchor-summary').forEach((anchor) => {
    observerSummary.observe(anchor);
  });
});
