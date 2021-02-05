window.addEventListener('DOMContentLoaded', () => {
  const form = document.querySelector('#generate_doc_with_prescriptions_form')
  if (form != null) {
    form.onsubmit = () => {
      setTimeout(() => {
        document.location.reload(true);
      }, 1000)
    };
  }
});
