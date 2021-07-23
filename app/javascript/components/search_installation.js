window.addEventListener('DOMContentLoaded', () => {
  var $input = $('*[data-behavior="autocomplete-installation"]');

  var options = {
    url: function (phrase) {
      return '/installations/search.json?q=' + phrase;
    },
    getValue: 'name',
    template: {
      type: 'links',
      fields: {
        link: 'link',
      },
    },
    list: {
      maxNumberOfElements: 10,
      onChooseEvent: function () {
        var link_value = $input.getSelectedItemData().link;
        location.replace(link_value);
      },
    },
  };

  $input.easyAutocomplete(options);
});
