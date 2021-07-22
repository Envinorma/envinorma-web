window.addEventListener('DOMContentLoaded', () => {
  var $input = $('*[data-behavior="autocomplete-classements"]');

  const options = {
    url: function (query) {
      return '/classement_references/search.json?q=' + query;
    },
    getValue: 'name',
    list: {
      maxNumberOfElements: 10,
      onChooseEvent: function () {
        const element = $('#classement_reference_id')[0];
        element.value = $input.getSelectedItemData().id;
      },
    },
  };

  $input.easyAutocomplete(options);
});
