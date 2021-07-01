const updateGroupButtons = (event) => {
  const btn_arrete = document.querySelector(".js_group_by_arrete")
  const btn_topic = document.querySelector(".js_group_by_topic")

  btn_arrete.classList.remove('btn-secondary')
  btn_arrete.classList.add('btn-light')
  btn_topic.classList.remove('btn-secondary')
  btn_topic.classList.add('btn-light')

  event.target.classList.remove('btn-light')
  event.target.classList.add('btn-secondary')
}

window.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.js_btn_group_by a').forEach((btn) => {
    btn.addEventListener("click", updateGroupButtons);
  });
});
