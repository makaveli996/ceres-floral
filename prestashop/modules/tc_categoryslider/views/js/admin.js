/**
 * Admin JS for tc_categoryslider repeater.
 * Handles add / remove / move-up / move-down actions and reindexes field names.
 * Called from tc_categoryslider::getContent() via addJS().
 */
(function () {
  'use strict';

  document.addEventListener('DOMContentLoaded', function () {
    var repeater = document.querySelector('[data-tc-cs-repeater]');
    if (!repeater) return;

    var container = repeater.querySelector('[data-tc-cs-items]');
    var addBtn    = repeater.querySelector('[data-tc-cs-add]');
    var template  = document.getElementById('tc-cs-segment-template');

    /** Update all field name attributes so indices match DOM order. */
    function reindex() {
      var items = container.querySelectorAll('[data-tc-cs-item]');
      items.forEach(function (item, i) {
        // Named select / inputs
        item.querySelectorAll('[data-tc-cs-name]').forEach(function (el) {
          var fieldName = el.getAttribute('data-tc-cs-name');
          el.setAttribute('name', 'segments[' + i + '][' + fieldName + ']');
        });
        // File input
        var fileInput = item.querySelector('[data-tc-cs-file]');
        if (fileInput) {
          fileInput.setAttribute('name', 'segments_image[' + i + ']');
        }
        // Update heading number
        var heading = item.querySelector('.panel-heading strong');
        if (heading && !heading.textContent.includes('Nowy')) {
          heading.textContent = heading.textContent.replace(/\d+/, String(i + 1));
        }
      });
    }

    /** Add new segment row from template. */
    if (addBtn && template) {
      addBtn.addEventListener('click', function () {
        var clone = template.content.cloneNode(true);
        container.appendChild(clone);
        reindex();
      });
    }

    /** Delegate remove / move-up / move-down inside container. */
    container.addEventListener('click', function (e) {
      var btn  = e.target.closest('[data-tc-cs-remove],[data-tc-cs-move-up],[data-tc-cs-move-down]');
      if (!btn) return;

      var item = btn.closest('[data-tc-cs-item]');
      if (!item) return;

      if (btn.hasAttribute('data-tc-cs-remove')) {
        if (confirm('Usunąć ten segment?')) {
          item.remove();
          reindex();
        }
      } else if (btn.hasAttribute('data-tc-cs-move-up')) {
        var prev = item.previousElementSibling;
        if (prev) {
          container.insertBefore(item, prev);
          reindex();
        }
      } else if (btn.hasAttribute('data-tc-cs-move-down')) {
        var next = item.nextElementSibling;
        if (next) {
          container.insertBefore(next, item);
          reindex();
        }
      }
    });

    // Initial reindex to fix any template placeholders
    reindex();
  });
}());
