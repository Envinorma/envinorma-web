const updateGroupByButtonClass = (event) => {
  resetGroupByButtonClass();
  event.target.classList.replace('btn-light', 'btn-secondary')
}

const resetGroupByButtonClass = () => {
  const btn_arrete = document.querySelector(".js_group_by_arrete")
  const btn_topic = document.querySelector(".js_group_by_topic")

  btn_arrete.classList.replace('btn-secondary', 'btn-light')
  btn_topic.classList.replace('btn-secondary', 'btn-light')
}

window.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.js_btn_group_by a').forEach((btn) => {
    btn.addEventListener("click", updateGroupByButtonClass);
  });
});
