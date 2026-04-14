{**
 * Footer partial — restyled to match Figma (STOPA).
 * Structure: top row (contact + logo + social), divider, main (address + menu columns + back-to-top), divider, bottom (copyright + made by).
 * Hooks: displayFooterBefore, displayFooter, displayFooterAfter.
 * Data: contact from ps_contactinfo, menus from ps_linklist, social from ps_socialfollow, logo from shop.
 *}
<div class="footer-container">
  <div class="container-lg footer-inner">
    <div class="footer-grid">
      {block name='hook_footer_before'}
        <div class="footer-before">
          {hook h='displayFooterBefore'}
        </div>
      {/block}
      {block name='footer_logo'}
        <div class="footer-logo">
          <a href="{$urls.pages.index}" class="footer-logo__link">
            {if $shop.logo_details}
              <img
                class="footer-logo__img"
                src="{$urls.img_url}logo-v2.svg"
                alt="{$shop.name}"
                width="{$shop.logo_details.width}"
                height="{$shop.logo_details.height}"
                loading="lazy">
            {/if}
          </a>
        </div>
      {/block}
      <div class="footer-divider footer-divider--1" aria-hidden="true"></div>
      {block name='hook_footer'}
        <div class="footer-main">
          {hook h='displayFooter'}
        </div>
      {/block}
      {block name='footer_back_to_top'}
        <div class="footer-back-to-top">
          <button type="button" class="footer-back-to-top__btn js-footer-back-to-top" aria-label="{l s='Back to top' d='Shop.Theme.Actions'}">
            <svg width="15" height="8" viewBox="0 0 15 8" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M-2.23566e-06 7.06594C-2.22848e-06 6.90166 0.0627875 6.73721 0.188207 6.61179L6.61175 0.18825C6.86275 -0.0627503 7.2692 -0.0627503 7.52004 0.18825L13.9436 6.61179C14.1946 6.86279 14.1946 7.26924 13.9436 7.52008C13.6926 7.77092 13.2861 7.77108 13.0353 7.52008L7.0659 1.55068L1.0965 7.52008C0.845497 7.77108 0.439047 7.77108 0.188207 7.52008C0.0627874 7.39466 -2.24284e-06 7.23022 -2.23566e-06 7.06594Z" fill="black"/>
            </svg>   
          </button>
        </div>
      {/block}
      <div class="footer-divider footer-divider--2" aria-hidden="true"></div>
      {block name='hook_footer_after'}
        <div class="footer-after">
          {hook h='displayFooterAfter'}
        </div>
      {/block}
    </div>
    <div class="footer-bottom">
      <p class="footer-copyright">
        {block name='copyright_link'}
          {l s='%copyright% %year% - %shop_name%. Wszelkie prawa zastrzeżone.' sprintf=['%shop_name%' => $shop.name, '%year%' => 'Y'|date, '%copyright%' => '©'] d='Shop.Theme.Global'}
        {/block}
      </p>
      <p class="footer-made-by">
        {l s='Made by' d='Shop.Theme.Global'}
        <a href="https://two-colours.com" target="_blank" rel="noopener noreferrer nofollow" class="footer-made-by__link">
          <img
            src="{$urls.img_url}logo-two-colours.svg"
            alt="Two Colours" 
            class="footer__made-by-logo"
            loading="lazy"
          >
        </a>
      </p>
    </div>
  </div>
</div>
