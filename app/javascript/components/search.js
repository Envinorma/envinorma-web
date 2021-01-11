window.addEventListener('DOMContentLoaded', () => {
  $input = $('*[data-behavior="autocomplete"]')

  var options = {
    url: function(phrase) {
      return "/installations/search.json?q=" + phrase;
    },
    getValue: "name",
    template: {
      type: "links",
      fields: {
          link: "link"
      }
    },
    list: {
        maxNumberOfElements: 10,
      }
  };

  $input.easyAutocomplete(options);
});
