/**
 * Copyright since 2007 PrestaShop SA and Contributors
 * PrestaShop is an International Registered Trademark & Property of PrestaShop SA
 *
 * NOTICE OF LICENSE
 *
 * This source file is subject to the Academic Free License 3.0 (AFL-3.0)
 * that is bundled with this package in the file LICENSE.md.
 * It is also available through the world-wide-web at this URL:
 * https://opensource.org/licenses/AFL-3.0
 * If you did not receive a copy of the license and are unable to
 * obtain it through the world-wide-web, please send an email
 * to license@prestashop.com so we can send you a copy immediately.
 *
 * DISCLAIMER
 *
 * Do not edit or add to this file if you wish to upgrade PrestaShop to newer
 * versions in the future. If you wish to customize PrestaShop for your
 * needs please refer to https://devdocs.prestashop.com/ for more information.
 *
 * @author    PrestaShop SA and Contributors <contact@prestashop.com>
 * @copyright Since 2007 PrestaShop SA and Contributors
 * @license   https://opensource.org/licenses/AFL-3.0 Academic Free License 3.0 (AFL-3.0)
 */
import $ from 'jquery';
import prestashop from 'prestashop';
import DropDown from './drop-down';

export default class TopMenu extends DropDown {
  init() {
    let elmtClass;
    const self = this;
    this.el.find('li').on('mouseenter mouseleave', (e) => {
      if (this.el.parent().hasClass('mobile')) {
        return;
      }
      const currentTargetClass = $(e.currentTarget).attr('class');

      if (elmtClass !== currentTargetClass) {
        const classesSelected = Array.prototype.slice
          .call(e.currentTarget.classList)
          .map((elem) => (typeof elem === 'string' ? `.${elem}` : false));

        elmtClass = classesSelected.join('');

        if (elmtClass && $(e.target).data('depth') === 0) {
          $(`${elmtClass} .js-sub-menu`).css({
            top: $(`${elmtClass}`).height(),
          });
        }
      }
    });
    $('#menu-icon').on('click', () => {
      $('#mobile_top_menu_wrapper').toggle();
      self.toggleMobileMenu();
      self.updateMenuIcon();
    });

    this.el.on('click', (e) => {
      if (this.el.parent().hasClass('mobile')) {
        return;
      }
      e.stopPropagation();
    });

    prestashop.on('responsive update', () => {
      $('.js-sub-menu').removeAttr('style');
      self.toggleMobileMenu();
      self.updateMenuIcon();
    });
    super.init();
  }

  toggleMobileMenu() {
    $('#header').toggleClass('is-open');
    // Drawer overlays content; do not hide #wrapper or #footer
  }

  updateMenuIcon() {
    const $icon = $('#menu-icon .material-icons');
    if (!$icon.length) return;
    const isOpen = $('#mobile_top_menu_wrapper').is(':visible');
    $icon.text(isOpen ? 'close' : 'menu');
  }
}
