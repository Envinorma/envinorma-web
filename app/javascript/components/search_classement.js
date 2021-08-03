window.addEventListener('DOMContentLoaded', () => {
  var $input = $('*[data-behavior="autocomplete-classements"]');

  const options = {
    url: function (query) {
      return '/classement_references/search.json?q=' + query;
    },
    getValue: 'name',
    list: {
      maxNumberOfElements: 15,
      onChooseEvent: () => setSelectedValueInHiddenInput($input.getSelectedItemData().id),
    },
  };

  $input.easyAutocomplete(options);
});

const setSelectedValueInHiddenInput = (id) => {
  $('#classement_reference_id')[0].value = id;
};
