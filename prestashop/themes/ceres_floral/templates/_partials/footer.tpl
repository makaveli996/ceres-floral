{**
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
 *}
<div class="footer-container tc-footer">
  <div class="container-md">
    {block name='hook_footer_before'}
      <div class="tc-footer__before">
        {hook h='displayFooterBefore'}
      </div>
    {/block}

    <div class="tc-footer__logo-row">
      <span class="tc-footer__line" aria-hidden="true"></span>
      <a href="{$urls.pages.index}" class="tc-footer__logo-link">
        {if $shop.logo_details}
          <img
            class="tc-footer__logo"
            src="{$shop.logo_details.src}"
            alt="{$shop.name}"
            width="{$shop.logo_details.width}"
            height="{$shop.logo_details.height}"
            loading="lazy"
          >
        {else}
          <span class="tc-footer__logo-text">{$shop.name}</span>
        {/if}
      </a>
      <span class="tc-footer__line" aria-hidden="true"></span>
    </div>

    <div class="tc-footer__main">
      <div class="tc-footer__contact">
        <div class="tc-footer__contact-main-item">
          <h3 class="tc-footer__heading">{l s='BIURO OBSŁUGI KLIENTA' d='Shop.Theme.Global'}</h3>
          {assign var=tc_shop_registration value=Configuration::get('PS_SHOP_DETAILS')}
          {assign var=tc_shop_phone value=Configuration::get('PS_SHOP_PHONE')}
          <p class="tc-footer__text">
            {if $tc_shop_registration}
              {$tc_shop_registration|escape:'htmlall':'UTF-8'}<br>
            {/if}
            {if $tc_shop_phone}
              {l s='tel:' d='Shop.Theme.Global'} <a class="tc-footer__link" href="tel:{$tc_shop_phone|replace:' ':''|escape:'htmlall':'UTF-8'}">{$tc_shop_phone|escape:'htmlall':'UTF-8'}</a>
            {/if}
          </p>
        </div>

        {assign var=tc_contacts value=Contact::getContacts($language.id)}
        {foreach from=$tc_contacts item=tc_contact}
          {if $tc_contact.id_contact >= 3 && $tc_contact.id_contact <= 5 && $tc_contact.email}
            <div class="tc-footer__contact-item">
              <p class="tc-footer__label">{$tc_contact.name|escape:'htmlall':'UTF-8'}:</p>
              <a href="mailto:{$tc_contact.email|escape:'htmlall':'UTF-8'}" class="tc-footer__mail">
                {$tc_contact.email|escape:'htmlall':'UTF-8'}
              </a>
            </div>
          {/if}
        {/foreach}
      </div>

      {block name='hook_footer'}
        <div class="tc-footer__links">
          {hook h='displayFooter'}
        </div>
      {/block}
    </div>

    <div class="tc-footer__divider tc-footer__divider--top" aria-hidden="true"></div>

    {widget name='tc_footerlogos'}

    <div class="tc-footer__divider" aria-hidden="true"></div>

    {block name='hook_footer_after'}
      <div class="tc-footer__after">
        {hook h='displayFooterAfter'}
      </div>
    {/block}

    <div class="tc-footer__bottom">
      <p class="tc-footer__copyright">
        {block name='copyright_link'}
          {l s='%copyright% %year% Ceres Floral. Wszystkie prawa zastrzeżone.' sprintf=['%year%' => 'Y'|date, '%copyright%' => '©'] d='Shop.Theme.Global'}
        {/block}
      </p>
      <p class="tc-footer__made-by">
        {l s='Made by' d='Shop.Theme.Global'}
        <a href="https://two-colours.com" target="_blank" rel="noopener noreferrer nofollow" class="tc-footer__link">
          <img
            src="{$urls.img_url}logo-two-colours.svg"
            alt="Two Colours" 
            class="tc-footer__made-by-logo"
            loading="lazy"
          >
        </a>
      </p>
    </div>
  </div>
</div>
