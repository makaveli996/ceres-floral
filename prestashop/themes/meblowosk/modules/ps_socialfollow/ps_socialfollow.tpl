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

{block name='block_social'}
  <div class="block-social ps-social-follow footer-social">
    <p class="footer-social__label">{l s='Obserwuj nas w social media' d='Shop.Theme.Global'}</p>
    <ul class="footer-social__list">
      {foreach from=$social_links item='social_link'}
        <li class="footer-social__item {$social_link.class}">
          <a href="{$social_link.url}" target="_blank" rel="noopener noreferrer" class="footer-social__link" aria-label="{$social_link.label}">
            {if $social_link.class == 'facebook'}
              <svg class="footer-social__icon" width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
                <path d="M12.7903 21.6751V13.1317H15.6568L16.0869 9.80125H12.7903V7.67522C12.7903 6.71127 13.0569 6.05435 14.4408 6.05435L16.2029 6.05363V3.07473C15.8982 3.03513 14.8521 2.94434 13.6346 2.94434C11.0923 2.94434 9.35181 4.49614 9.35181 7.34537V9.80125H6.47662V13.1317H9.35181V21.6751H12.7903Z" fill="currentColor"/>
              </svg>
            {elseif $social_link.class == 'instagram'}
              <svg class="footer-social__icon" width="28" height="28" viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M14.0025 8.60615C11.0233 8.60615 8.60619 11.0232 8.60619 14.0025C8.60619 16.9818 11.0233 19.3988 14.0025 19.3988C16.9819 19.3988 19.3989 16.9818 19.3989 14.0025C19.3989 11.0232 16.9819 8.60615 14.0025 8.60615ZM14.0025 17.503C12.0698 17.503 10.5021 15.9354 10.5021 14.0025C10.5021 12.0696 12.0698 10.502 14.0025 10.502C15.9354 10.502 17.503 12.0696 17.503 14.0025C17.503 15.9354 15.9354 17.503 14.0025 17.503Z" fill="currentColor"/>
                <path d="M19.6123 9.65259C20.3082 9.65259 20.8723 9.0885 20.8723 8.3928C20.8723 7.69693 20.3082 7.133 19.6123 7.133C18.9166 7.133 18.3526 7.69693 18.3526 8.3928C18.3526 9.0885 18.9166 9.65259 19.6123 9.65259Z" fill="currentColor"/>
                <path fill-rule="evenodd" clip-rule="evenodd" d="M24.4466 9.67311C24.3974 8.55694 24.2169 7.78958 23.9583 7.12466C23.6916 6.41886 23.2812 5.78696 22.7436 5.26165C22.2183 4.72817 21.5822 4.31364 20.8846 4.05107C20.2158 3.7925 19.4525 3.61201 18.3363 3.56279C17.2118 3.50941 16.8548 3.49707 14.0027 3.49707C11.1507 3.49707 10.7937 3.50941 9.67335 3.55863C8.55718 3.60784 7.78983 3.7885 7.12506 4.0469C6.4191 4.31364 5.7872 4.72401 5.2619 5.26165C4.72842 5.78696 4.31404 6.42303 4.05131 7.12065C3.79275 7.78958 3.61225 8.55277 3.56304 9.66894C3.50966 10.7934 3.49731 11.1504 3.49731 14.0025C3.49731 16.8546 3.50966 17.2115 3.55887 18.3319C3.60808 19.448 3.78874 20.2154 4.0473 20.8803C4.31404 21.5861 4.72842 22.218 5.2619 22.7433C5.7872 23.2768 6.42327 23.6913 7.1209 23.9539C7.78983 24.2125 8.55302 24.393 9.66935 24.4422C10.7895 24.4916 11.1467 24.5037 13.9987 24.5037C16.8508 24.5037 17.2078 24.4916 18.3281 24.4422C19.4443 24.393 20.2116 24.2125 20.8764 23.9539C22.2882 23.4081 23.4043 22.2919 23.9502 20.8803C24.2086 20.2114 24.3892 19.448 24.4384 18.3319C24.4876 17.2115 24.5 16.8546 24.5 14.0025C24.5 11.1504 24.4958 10.7934 24.4466 9.67311ZM22.5549 18.2498C22.5097 19.2757 22.3374 19.8297 22.1937 20.1991C21.8408 21.1142 21.1144 21.8405 20.1993 22.1935C19.83 22.3371 19.272 22.5095 18.25 22.5545C17.1421 22.6039 16.8097 22.6161 14.0069 22.6161C11.2041 22.6161 10.8676 22.6039 9.7636 22.5545C8.73768 22.5095 8.18368 22.3371 7.81435 22.1935C7.35894 22.0252 6.94441 21.7584 6.60794 21.4096C6.25912 21.069 5.99238 20.6586 5.82407 20.2032C5.68044 19.8339 5.50812 19.2757 5.46307 18.254C5.4137 17.146 5.40152 16.8135 5.40152 14.0107C5.40152 11.2078 5.4137 10.8714 5.46307 9.76753C5.50812 8.74161 5.68044 8.18761 5.82407 7.81828C5.99238 7.36271 6.25912 6.94833 6.6121 6.6117C6.95258 6.26289 7.36295 5.99615 7.81852 5.82799C8.18785 5.68436 8.74602 5.51204 9.76777 5.46684C10.8758 5.41762 11.2082 5.40528 14.0109 5.40528C16.8179 5.40528 17.1502 5.41762 18.2542 5.46684C19.2801 5.51204 19.8341 5.68436 20.2035 5.82799C20.6589 5.99615 21.0734 6.26289 21.4099 6.6117C21.7587 6.95234 22.0254 7.36271 22.1937 7.81828C22.3374 8.18761 22.5097 8.74561 22.5549 9.76753C22.6041 10.8755 22.6165 11.2078 22.6165 14.0107C22.6165 16.8135 22.6041 17.1418 22.5549 18.2498Z" fill="currentColor"/>
              </svg>
            {else}
              <span class="footer-social__label-inline">{$social_link.label}</span>
            {/if}
          </a>
        </li>
      {/foreach}
    </ul>
  </div>
{/block}
