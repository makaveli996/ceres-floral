(function () {
  var reindexSlides = function (container) {
    var slideItems = container.querySelectorAll('[data-tc-slide-item]');
    slideItems.forEach(function (item, index) {
      var buttonUrl = item.querySelector('[data-tc-name="button_url"]');
      var currentImage = item.querySelector('[data-tc-name="current_image"]');
      var fileInput = item.querySelector('[data-tc-file-input]');
      var header = item.querySelector('.tc-home-promo-admin__item-header strong');

      if (buttonUrl) buttonUrl.name = 'slides[' + index + '][button_url]';
      if (currentImage) currentImage.name = 'slides[' + index + '][current_image]';
      if (fileInput) fileInput.name = 'slides_image[' + index + ']';
      if (header) header.textContent = 'Slajd ' + (index + 1);
    });
  };

  var setupSlides = function () {
    var repeater = document.querySelector('[data-tc-slides-repeater]');
    if (!repeater) return;

    var list = repeater.querySelector('[data-tc-repeater-items]');
    var addButton = repeater.querySelector('[data-tc-add-slide]');
    var template = document.querySelector('#tc-home-promo-slide-template');
    if (!list || !addButton || !template) return;

    list.addEventListener('click', function (event) {
      var target = event.target;
      if (!(target instanceof HTMLElement)) return;
      var removeButton = target.closest('[data-tc-remove-item]');
      if (!removeButton) return;
      var item = removeButton.closest('[data-tc-slide-item]');
      if (!item) return;
      item.remove();
      reindexSlides(list);
    });

    addButton.addEventListener('click', function () {
      list.appendChild(template.content.cloneNode(true));
      reindexSlides(list);
    });

    reindexSlides(list);
  };

  var setupListItems = function () {
    var repeater = document.querySelector('[data-tc-list-repeater]');
    if (!repeater) return;

    var list = repeater.querySelector('[data-tc-list-items]');
    var addButton = repeater.querySelector('[data-tc-add-list-item]');
    var template = document.querySelector('#tc-home-promo-list-item-template');
    if (!list || !addButton || !template) return;

    repeater.addEventListener('click', function (event) {
      var target = event.target;
      if (!(target instanceof HTMLElement)) return;
      var removeButton = target.closest('[data-tc-remove-list-item]');
      if (!removeButton) return;
      var item = removeButton.closest('[data-tc-list-item]');
      if (item) item.remove();
    });

    addButton.addEventListener('click', function () {
      list.appendChild(template.content.cloneNode(true));
    });
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () {
      setupSlides();
      setupListItems();
    });
  } else {
    setupSlides();
    setupListItems();
  }
})();
