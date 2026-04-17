/**
 * Admin JS for tc_location image repeater.
 * Handles add / remove / move-up / move-down and reindexes field names.
 * Called from tc_location::getContent() via addJS().
 */
(function () {
  'use strict';

  document.addEventListener('DOMContentLoaded', function () {
    var repeater  = document.querySelector('[data-tc-loc-repeater]');
    if (!repeater) return;

    var container = repeater.querySelector('[data-tc-loc-items]');
    var addBtn    = repeater.querySelector('[data-tc-loc-add]');
    var template  = document.getElementById('tc-loc-image-template');

    /** Update field name attributes so indices match DOM order. */
    function reindex() {
      var items = container.querySelectorAll('[data-tc-loc-item]');
      items.forEach(function (item, i) {
        item.querySelectorAll('[data-tc-loc-name]').forEach(function (el) {
          var fieldName = el.getAttribute('data-tc-loc-name');
          el.setAttribute('name', 'images[' + i + '][' + fieldName + ']');
        });
        var fileInput = item.querySelector('[data-tc-loc-file]');
        if (fileInput) {
          fileInput.setAttribute('name', 'images_file[' + i + ']');
        }
        var heading = item.querySelector('.panel-heading strong');
        if (heading && !heading.textContent.includes('Nowe')) {
          heading.textContent = heading.textContent.replace(/\d+/, String(i + 1));
        }
      });
    }

    if (addBtn && template) {
      addBtn.addEventListener('click', function () {
        var clone = template.content.cloneNode(true);
        container.appendChild(clone);
        reindex();
      });
    }

    container.addEventListener('click', function (e) {
      var btn = e.target.closest('[data-tc-loc-remove],[data-tc-loc-move-up],[data-tc-loc-move-down]');
      if (!btn) return;

      var item = btn.closest('[data-tc-loc-item]');
      if (!item) return;

      if (btn.hasAttribute('data-tc-loc-remove')) {
        if (confirm('Usunąć to zdjęcie?')) {
          item.remove();
          reindex();
        }
      } else if (btn.hasAttribute('data-tc-loc-move-up')) {
        var prev = item.previousElementSibling;
        if (prev) {
          container.insertBefore(item, prev);
          reindex();
        }
      } else if (btn.hasAttribute('data-tc-loc-move-down')) {
        var next = item.nextElementSibling;
        if (next) {
          container.insertBefore(next, item);
          reindex();
        }
      }
    });

    reindex();
  });
}());
