window.addEventListener('DOMContentLoaded', () => {
  const select = document.querySelector('#ap_select')
  if (select != null) {
    var pathArray = window.location.pathname.split('/');
    var ap_id = pathArray.pop();
    var option = document.querySelector(`option[value="${ap_id}"]`);
    option.selected = 'selected';
  }
});
