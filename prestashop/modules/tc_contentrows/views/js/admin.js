/**
 * Admin JS for tc_contentrows repeater.
 * Handles add / remove / move-up / move-down, reindexes field names, and initialises TinyMCE.
 * Called from tc_contentrows::getContent() via addJS().
 */
(function () {
  'use strict';

  document.addEventListener('DOMContentLoaded', function () {
    var repeater  = document.querySelector('[data-tc-cr-repeater]');
    if (!repeater) return;

    var container = repeater.querySelector('[data-tc-cr-items]');
    var addBtn    = repeater.querySelector('[data-tc-cr-add]');
    var template  = document.getElementById('tc-cr-row-template');
    var form      = document.querySelector('[data-tc-cr-form]');

    /** Update all field name attributes so indices match DOM order. */
    function reindex() {
      var items = container.querySelectorAll('[data-tc-cr-item]');
      items.forEach(function (item, i) {
        item.querySelectorAll('[data-tc-cr-name]').forEach(function (el) {
          var fieldName = el.getAttribute('data-tc-cr-name');
          el.setAttribute('name', 'rows[' + i + '][' + fieldName + ']');
        });
        var fileInput = item.querySelector('[data-tc-cr-file]');
        if (fileInput) {
          fileInput.setAttribute('name', 'rows_image[' + i + ']');
        }
        var heading = item.querySelector('.panel-heading strong');
        if (heading) {
          heading.textContent = 'Wiersz ' + (i + 1);
        }
      });
    }

    /** Initialise TinyMCE on any un-processed autoload_rte textareas. */
    function initTinyMCE() {
      if (typeof tinySetup === 'function') {
        tinySetup({ editor_selector: 'autoload_rte' });
      }
    }

    /** Add new row from template. */
    if (addBtn && template) {
      addBtn.addEventListener('click', function () {
        var clone = template.content.cloneNode(true);
        container.appendChild(clone);
        reindex();
        initTinyMCE();
      });
    }

    /** Delegate remove / move-up / move-down inside container. */
    container.addEventListener('click', function (e) {
      var btn = e.target.closest('[data-tc-cr-remove],[data-tc-cr-move-up],[data-tc-cr-move-down]');
      if (!btn) return;

      var item = btn.closest('[data-tc-cr-item]');
      if (!item) return;

      if (btn.hasAttribute('data-tc-cr-remove')) {
        if (confirm('Usunąć ten wiersz?')) {
          item.remove();
          reindex();
        }
      } else if (btn.hasAttribute('data-tc-cr-move-up')) {
        var prev = item.previousElementSibling;
        if (prev) {
          container.insertBefore(item, prev);
          reindex();
        }
      } else if (btn.hasAttribute('data-tc-cr-move-down')) {
        var next = item.nextElementSibling;
        if (next) {
          container.insertBefore(next, item);
          reindex();
        }
      }
    });

    /** Flush TinyMCE editors to their textareas before form submit. */
    if (form) {
      form.addEventListener('submit', function () {
        if (typeof tinyMCE !== 'undefined') {
          tinyMCE.triggerSave();
        }
      });
    }

    initTinyMCE();
    reindex();
  });
}());
