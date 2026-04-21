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
<div id="_desktop_contact_link">
  {assign var=tc_shop_phone value=Configuration::get('PS_SHOP_PHONE')}
  {if !$tc_shop_phone && isset($contact_infos.phone)}
    {assign var=tc_shop_phone value=$contact_infos.phone}
  {/if}

  {assign var=tc_header_email value=''}
  {assign var=tc_contacts value=Contact::getContacts($language.id)}
  {foreach from=$tc_contacts item=tc_contact}
    {if !$tc_header_email && $tc_contact.id_contact == 3 && $tc_contact.email}
      {assign var=tc_header_email value=$tc_contact.email}
    {/if}
  {/foreach}
  {if !$tc_header_email}
    {foreach from=$tc_contacts item=tc_contact}
      {if !$tc_header_email && $tc_contact.id_contact >= 3 && $tc_contact.id_contact <= 5 && $tc_contact.email}
        {assign var=tc_header_email value=$tc_contact.email}
      {/if}
    {/foreach}
  {/if}
  {if !$tc_header_email && isset($contact_infos.email)}
    {assign var=tc_header_email value=$contact_infos.email}
  {/if}
  {assign var=tc_opening_hours value='Pon - Pt: 10:00-17:00'}
  {if isset($contact_infos.hours) && $contact_infos.hours}
    {assign var=tc_opening_hours value=$contact_infos.hours}
  {/if}

  <div id="contact-link">
    <p class="header-bar__hours">{$tc_opening_hours|escape:'htmlall':'UTF-8'}</p>

    <div class="header-bar__contact-items">
    {if $tc_shop_phone}
      <div class="header-bar__row header-bar__row--phone">
        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M8.65471 0.66882C8.65471 0.491721 8.72506 0.321875 8.85029 0.196647C8.97552 0.0714188 9.14536 0.00106638 9.32246 0.00106638C11.0929 0.00301061 12.7902 0.707159 14.042 1.95902C15.2939 3.21088 15.9981 4.90821 16 6.67861C16 6.85571 15.9296 7.02555 15.8044 7.15078C15.6792 7.27601 15.5093 7.34636 15.3322 7.34636C15.1551 7.34636 14.9853 7.27601 14.8601 7.15078C14.7348 7.02555 14.6645 6.85571 14.6645 6.67861C14.6629 5.2623 14.0996 3.90446 13.0981 2.90298C12.0966 1.9015 10.7388 1.33816 9.32246 1.33657C9.14536 1.33657 8.97552 1.26622 8.85029 1.14099C8.72506 1.01577 8.65471 0.84592 8.65471 0.66882ZM9.32246 4.00759C10.0309 4.00759 10.7102 4.289 11.2112 4.78991C11.7121 5.29082 11.9935 5.97021 11.9935 6.67861C11.9935 6.85571 12.0638 7.02555 12.1891 7.15078C12.3143 7.27601 12.4841 7.34636 12.6612 7.34636C12.8383 7.34636 13.0082 7.27601 13.1334 7.15078C13.2586 7.02555 13.329 6.85571 13.329 6.67861C13.3279 5.61634 12.9055 4.59788 12.1543 3.84674C11.4032 3.0956 10.3847 2.67314 9.32246 2.67208C9.14536 2.67208 8.97552 2.74243 8.85029 2.86766C8.72506 2.99289 8.65471 3.16274 8.65471 3.33984C8.65471 3.51694 8.72506 3.68678 8.85029 3.81201C8.97552 3.93724 9.14536 4.00759 9.32246 4.00759ZM15.3943 11.1786C15.7813 11.5666 15.9986 12.0923 15.9986 12.6403C15.9986 13.1883 15.7813 13.714 15.3943 14.102L14.7867 14.8025C9.31779 20.0384 -3.99055 6.73336 1.16451 1.2471L1.93243 0.579341C2.32091 0.20318 2.84186 -0.00491063 3.38259 8.80163e-05C3.92332 0.00508666 4.44034 0.222773 4.8218 0.606051C4.8425 0.626752 6.07985 2.23404 6.07985 2.23404C6.447 2.61975 6.65138 3.13212 6.65051 3.66463C6.64964 4.19715 6.44358 4.70885 6.07517 5.09336L5.30192 6.06561C5.72984 7.10538 6.35901 8.05034 7.15327 8.8462C7.94753 9.64206 8.89122 10.2731 9.93012 10.7032L10.9084 9.92523C11.2929 9.5571 11.8045 9.35129 12.3369 9.35054C12.8693 9.3498 13.3814 9.55417 13.767 9.92122C13.767 9.92122 15.3736 11.1579 15.3943 11.1786ZM14.4755 12.1495C14.4755 12.1495 12.8776 10.9202 12.8569 10.8995C12.7193 10.7631 12.5334 10.6865 12.3397 10.6865C12.146 10.6865 11.9601 10.7631 11.8225 10.8995C11.8045 10.9182 10.4576 11.9913 10.4576 11.9913C10.3669 12.0635 10.2589 12.1109 10.1442 12.1287C10.0296 12.1465 9.91231 12.1341 9.80391 12.0928C8.45803 11.5917 7.23555 10.8072 6.2193 9.79239C5.20304 8.77764 4.41674 7.55632 3.91365 6.21118C3.86905 6.1013 3.8545 5.98153 3.87152 5.86417C3.88854 5.74681 3.9365 5.63611 4.01048 5.54342C4.01048 5.54342 5.08356 4.1959 5.10159 4.17853C5.23799 4.04097 5.31452 3.85509 5.31452 3.66136C5.31452 3.46763 5.23799 3.28175 5.10159 3.14418C5.08089 3.12415 3.85155 1.52488 3.85155 1.52488C3.71193 1.39968 3.5297 1.33263 3.34222 1.33747C3.15475 1.34232 2.97622 1.41868 2.84325 1.55092L2.07533 2.21868C-1.69214 6.74872 9.84064 17.6418 13.8104 13.8903L14.4188 13.1892C14.5613 13.0572 14.6469 12.8749 14.6575 12.6808C14.6681 12.4868 14.6028 12.2963 14.4755 12.1495Z" fill="#F8F3DD"/>
        </svg>      
        <a href="tel:{$tc_shop_phone|replace:' ':''|escape:'htmlall':'UTF-8'}">{$tc_shop_phone|escape:'htmlall':'UTF-8'}</a>
      </div>
    {/if}

    {if $tc_header_email}
      <div class="header-bar__row header-bar__row--email">
        <svg width="14" height="13" viewBox="0 0 14 13" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M10.7952 0H2.84084C2.08768 0.000902168 1.36562 0.300493 0.833058 0.833058C0.300493 1.36562 0.000902168 2.08768 0 2.84084L0 9.65884C0.000902168 10.412 0.300493 11.1341 0.833058 11.6666C1.36562 12.1992 2.08768 12.4988 2.84084 12.4997H10.7952C11.5483 12.4988 12.2704 12.1992 12.803 11.6666C13.3355 11.1341 13.6351 10.412 13.636 9.65884V2.84084C13.6351 2.08768 13.3355 1.36562 12.803 0.833058C12.2704 0.300493 11.5483 0.000902168 10.7952 0ZM2.84084 1.13633H10.7952C11.1354 1.137 11.4676 1.23946 11.7491 1.43053C12.0306 1.6216 12.2485 1.89253 12.3747 2.20847L8.02365 6.56006C7.70345 6.87898 7.26993 7.05804 6.818 7.05804C6.36608 7.05804 5.93256 6.87898 5.61235 6.56006L1.26133 2.20847C1.38755 1.89253 1.60542 1.6216 1.88691 1.43053C2.1684 1.23946 2.50063 1.137 2.84084 1.13633ZM10.7952 11.3633H2.84084C2.38877 11.3633 1.95523 11.1838 1.63557 10.8641C1.31591 10.5444 1.13633 10.1109 1.13633 9.65884V3.69309L4.80897 7.36345C5.34226 7.89539 6.06476 8.19413 6.818 8.19413C7.57125 8.19413 8.29375 7.89539 8.82704 7.36345L12.4997 3.69309V9.65884C12.4997 10.1109 12.3201 10.5444 12.0004 10.8641C11.6808 11.1838 11.2472 11.3633 10.7952 11.3633Z" fill="#F8F3DD"/>
        </svg>      
        <a href="mailto:{$tc_header_email|escape:'htmlall':'UTF-8'}">{$tc_header_email|escape:'htmlall':'UTF-8'}</a>
      </div>
    {/if}
    </div>
  </div>
</div>
