/**
 * Admin repeater logic for tc_footerlogos.
 * Handles add/remove and field reindexing for payment and delivery groups.
 */
(function () {
  'use strict';

  function initGroup(group) {
    var repeater = document.querySelector('[data-tc-fl-repeater="' + group + '"]');
    if (!repeater) return;

    var container = repeater.querySelector('[data-tc-fl-items="' + group + '"]');
    var addBtn = repeater.querySelector('[data-tc-fl-add="' + group + '"]');
    var template = document.getElementById('tc-fl-item-template');

    function reindex() {
      var items = container.querySelectorAll('[data-tc-fl-item]');
      items.forEach(function (item, i) {
        var fileInput = item.querySelector('[data-tc-fl-file]');
        if (fileInput) {
          fileInput.setAttribute('name', group + '_logo[' + i + ']');
          fileInput.setAttribute('data-tc-fl-file', group);
        }

        item.querySelectorAll('[data-tc-fl-name]').forEach(function (field) {
          var key = field.getAttribute('data-tc-fl-name');
          field.setAttribute('name', group + '_logos[' + i + '][' + key + ']');
        });
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
      var removeBtn = e.target.closest('[data-tc-fl-remove]');
      if (!removeBtn) return;
      var item = removeBtn.closest('[data-tc-fl-item]');
      if (!item) return;

      if (confirm('Usunąć to logo?')) {
        item.remove();
        reindex();
      }
    });

    reindex();
  }

  document.addEventListener('DOMContentLoaded', function () {
    initGroup('payment');
    initGroup('delivery');
  });
}());
