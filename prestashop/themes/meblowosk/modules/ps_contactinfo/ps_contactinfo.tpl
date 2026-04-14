{**
 * Contact info for footer — dwa osobne bloki bez wrappera, żeby grid mógł je rozmieścić (Figma).
 * Górny rząd: email + telefon. Środkowy rząd, 1. kolumna: adres + godziny.
 * Używane przez: ps_contactinfo na displayFooter. Dane z BO: Shop Parameters > Contact + PS_SHOP_DETAILS (godziny).
 *}
{* Górny rząd stopki: email i telefon z ikonami *}
<div id="block_contact_infos" class="footer-contact-top">
  {if $contact_infos.email && $display_email}
    <div class="footer-contact-top__item">
      <span class="footer-contact-top__icon footer-contact-top__icon--email" aria-hidden="true">
        <svg width="20" height="18" viewBox="0 0 20 18" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M15.8333 0H4.16667C3.062 0.00129916 2.00296 0.432722 1.22185 1.19963C0.440735 1.96655 0.00132321 3.00633 0 4.09091L0 13.9091C0.00132321 14.9937 0.440735 16.0335 1.22185 16.8004C2.00296 17.5673 3.062 17.9987 4.16667 18H15.8333C16.938 17.9987 17.997 17.5673 18.7782 16.8004C19.5593 16.0335 19.9987 14.9937 20 13.9091V4.09091C19.9987 3.00633 19.5593 1.96655 18.7782 1.19963C17.997 0.432722 16.938 0.00129916 15.8333 0ZM4.16667 1.63636H15.8333C16.3323 1.63733 16.8196 1.78488 17.2325 2.06002C17.6453 2.33517 17.9649 2.72532 18.15 3.18027L11.7683 9.44673C11.2987 9.90598 10.6628 10.1638 10 10.1638C9.33715 10.1638 8.70131 9.90598 8.23167 9.44673L1.85 3.18027C2.03512 2.72532 2.35468 2.33517 2.76754 2.06002C3.1804 1.78488 3.66768 1.63733 4.16667 1.63636ZM15.8333 16.3636H4.16667C3.50363 16.3636 2.86774 16.105 2.3989 15.6447C1.93006 15.1844 1.66667 14.5601 1.66667 13.9091V5.31818L7.05333 10.6036C7.83552 11.3697 8.89521 11.7998 10 11.7998C11.1048 11.7998 12.1645 11.3697 12.9467 10.6036L18.3333 5.31818V13.9091C18.3333 14.5601 18.0699 15.1844 17.6011 15.6447C17.1323 16.105 16.4964 16.3636 15.8333 16.3636Z" fill="#1E1E1E"/>
        </svg>
      </span>
      <a href="mailto:{$contact_infos.email}" class="footer-contact-top__text">{$contact_infos.email}</a>
    </div>
  {/if}
  {if $contact_infos.phone}
    <div class="footer-contact-top__item">
      <span class="footer-contact-top__icon footer-contact-top__icon--phone" aria-hidden="true">
        <svg width="16" height="24" viewBox="0 0 16 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M11.045 0.000750008C11.018 -0.000250003 4.982 -0.000250003 4.955 0.000750008C2.219 0.0247503 0 2.25877 0 4.9998V18.9999C0 21.757 2.243 24 5 24H11C13.757 24 16 21.757 16 18.9999V5.0008C16 2.25877 13.781 0.0257503 11.045 0.000750008ZM14 18.9999C14 20.654 12.654 22 11 22H5C3.346 22 2 20.654 2 18.9999V5.0008C2 3.54779 3.038 2.33377 4.411 2.05877L5.105 3.44779C5.274 3.78679 5.621 4.00079 6 4.00079H10C10.379 4.00079 10.725 3.78679 10.895 3.44779L11.589 2.05877C12.962 2.33277 14 3.54779 14 5.0008V18.9999ZM9 20H7C6.448 20 6 19.552 6 18.9999C6 18.4479 6.448 17.9999 7 17.9999H9C9.552 17.9999 10 18.4479 10 18.9999C10 19.552 9.552 20 9 20Z" fill="#1E1E1E"/>
        </svg>
      </span>
      <a href="tel:{$contact_infos.phone|replace:' ':''}" class="footer-contact-top__text">{$contact_infos.phone}</a>
    </div>
  {/if}
</div>
{* Środkowy rząd stopki, 1. kolumna: adres firmy (bez kraju) + godziny otwarcia (Figma) *}
<div class="footer-contact-main">
  <div class="footer-contact-main__address">
    {if $contact_infos.company}{$contact_infos.company}<br>{/if}
    {$contact_infos.address.address1}
    {if $contact_infos.address.address2}<br>{$contact_infos.address.address2}{/if}
    {if $contact_infos.address.postcode || $contact_infos.address.city}<br>{$contact_infos.address.postcode} {$contact_infos.address.city|trim}{/if}
    {if $contact_infos.address.state}<br>{$contact_infos.address.state}{/if}
  </div>
  {if $contact_infos.details}
    <div class="footer-contact-main__hours">
      {$contact_infos.details|nl2br nofilter}
    </div>
  {/if}
</div>
