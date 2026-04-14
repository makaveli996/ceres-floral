{**
 * Global button component (link styled as button with optional icon).
 * Used by: product-slider, tc_cta, tc_collections, and any CTA/link that should look like a button.
 * Variables: $label; optional $url (omit or empty → <button>), $btn_class, $icon_type, $target.
 * Optional $label_mobile: with $label shows short text on small viewports, full from $label on desktop (see .button__responsive-label in _button.scss). aria-label uses full $label.
 * For submit button: no url, button_type='submit', button_name='fieldName'.
 * When no url: use <button> by default. If inside <a>, pass no_url_as_span=1 (button inside link is invalid HTML).
 * Example: {include file='_partials/button.tpl' url=$url label=$label icon_type='arrow-right'}
 * Example (no link): {include file='_partials/button.tpl' label=$label btn_class='my-button'}
 * Example (submit): {include file='_partials/button.tpl' label=$label button_type='submit' button_name='submitTcContactForm' btn_class='tc-contact__submit'}
 *}
{assign var="_has_url" value=false}
{if isset($url) && $url != ''}
  {assign var="_has_url" value=true}
{/if}
{assign var="_button_type" value='button'}
{if isset($button_type) && $button_type == 'submit'}
  {assign var="_button_type" value='submit'}
{/if}
{assign var="_responsive_label" value=false}
{if isset($label_mobile) && $label_mobile != ''}
  {assign var="_responsive_label" value=true}
{/if}
{if $_has_url}
<a href="{$url|escape:'html':'UTF-8'}" class="{if $btn_class}{$btn_class|escape:'html':'UTF-8'} {/if}button"{if isset($target) && $target} target="_blank" rel="noopener noreferrer"{/if}{if $_responsive_label} aria-label="{$label|escape:'html':'UTF-8'}"{/if}>
{else}
{if isset($no_url_as_span) && $no_url_as_span}
<span class="{if $btn_class}{$btn_class|escape:'html':'UTF-8'} {/if}button"{if $_responsive_label} aria-label="{$label|escape:'html':'UTF-8'}"{/if}>
{else}
<button type="{$_button_type|escape:'html':'UTF-8'}" class="{if $btn_class}{$btn_class|escape:'html':'UTF-8'} {/if}button"{if isset($button_name) && $button_name != ''} name="{$button_name|escape:'html':'UTF-8'}"{/if}{if $_responsive_label} aria-label="{$label|escape:'html':'UTF-8'}"{/if}>
{/if}
{/if}
  {if $_responsive_label}
    <span class="button__text">
      <span class="button__responsive-label button__responsive-label--mobile">{$label_mobile|escape:'html':'UTF-8'}</span>
      <span class="button__responsive-label button__responsive-label--desktop">{$label|escape:'html':'UTF-8'}</span>
    </span>
  {else}
    <span class="button__text">{$label|escape:'html':'UTF-8'}</span>
  {/if}
  {assign var="_icon_type" value='arrow-right'}
  {if isset($icon_type) && $icon_type != ''}
    {assign var="_icon_type" value=$icon_type}
  {/if}
  {if $_icon_type != 'none'}
  <span class="button__icon button__icon--{$_icon_type|escape:'html':'UTF-8'}" aria-hidden="true">
    {if $_icon_type == 'arrow-left'}
    <svg width="8" height="11" viewBox="0 0 8 11" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M0.84666 5.89397C0.30284 5.49437 0.30284 4.6819 0.84666 4.2823L6.40786 0.195874C7.06828 -0.289406 8 0.18217 8 1.00171V9.17456C8 9.9941 7.06828 10.4657 6.40786 9.9804L0.84666 5.89397Z" fill="currentColor"/></svg>
    {elseif $_icon_type == 'pdf'}
    <svg width="16" height="20" viewBox="0 0 16 20" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M14.3592 4.4288L11.572 1.64C10.5136 0.5824 9.1072 0 7.612 0H4C1.7944 0 0 1.7944 0 4V15.2C0 17.4056 1.7944 19.2 4 19.2H12C14.2056 19.2 16 17.4056 16 15.2V8.388C16 6.8912 15.4168 5.4864 14.3592 4.4288ZM13.228 5.5608C13.4824 5.8144 13.6976 6.0968 13.872 6.4008H10.3992C9.9576 6.4008 9.5992 6.0416 9.5992 5.6008V2.1272C9.9032 2.3016 10.1856 2.5168 10.44 2.7712L13.2272 5.56L13.228 5.5608ZM14.4 15.2008C14.4 16.524 13.3232 17.6008 12 17.6008H4C2.6768 17.6008 1.6 16.524 1.6 15.2008V4C1.6 2.6768 2.6768 1.6 4 1.6H7.612C7.7424 1.6 7.872 1.6064 8 1.6184V5.6C8 6.9232 9.0768 8 10.4 8H14.3816C14.3936 8.128 14.4 8.2576 14.4 8.388V15.2008ZM10.9656 12.8848C11.2784 13.1968 11.2784 13.7032 10.9656 14.016L9.6752 15.3072C9.2136 15.7688 8.6064 16 8 16C7.3936 16 6.7864 15.7688 6.3248 15.3072L5.0344 14.016C4.7216 13.7032 4.7216 13.1968 5.0344 12.8848C5.3472 12.572 5.8528 12.572 6.1656 12.8848L7.2 13.9192V10.4008C7.2 9.9592 7.5576 9.6008 8 9.6008C8.4424 9.6008 8.8 9.9592 8.8 10.4008V13.9192L9.8344 12.8848C10.1472 12.572 10.6528 12.572 10.9656 12.8848Z" fill="#1E1E1E"/>
    </svg>
    {elseif $_icon_type == 'download'}
    <svg width="16" height="20" viewBox="0 0 16 20" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M14.3592 4.4288L11.572 1.64C10.5136 0.5824 9.1072 0 7.612 0H4C1.7944 0 0 1.7944 0 4V15.2C0 17.4056 1.7944 19.2 4 19.2H12C14.2056 19.2 16 17.4056 16 15.2V8.388C16 6.8912 15.4168 5.4864 14.3592 4.4288ZM13.228 5.5608C13.4824 5.8144 13.6976 6.0968 13.872 6.4008H10.3992C9.9576 6.4008 9.5992 6.0416 9.5992 5.6008V2.1272C9.9032 2.3016 10.1856 2.5168 10.44 2.7712L13.2272 5.56L13.228 5.5608ZM14.4 15.2008C14.4 16.524 13.3232 17.6008 12 17.6008H4C2.6768 17.6008 1.6 16.524 1.6 15.2008V4C1.6 2.6768 2.6768 1.6 4 1.6H7.612C7.7424 1.6 7.872 1.6064 8 1.6184V5.6C8 6.9232 9.0768 8 10.4 8H14.3816C14.3936 8.128 14.4 8.2576 14.4 8.388V15.2008ZM10.9656 12.8848C11.2784 13.1968 11.2784 13.7032 10.9656 14.016L9.6752 15.3072C9.2136 15.7688 8.6064 16 8 16C7.3936 16 6.7864 15.7688 6.3248 15.3072L5.0344 14.016C4.7216 13.7032 4.7216 13.1968 5.0344 12.8848C5.3472 12.572 5.8528 12.572 6.1656 12.8848L7.2 13.9192V10.4008C7.2 9.9592 7.5576 9.6008 8 9.6008C8.4424 9.6008 8.8 9.9592 8.8 10.4008V13.9192L9.8344 12.8848C10.1472 12.572 10.6528 12.572 10.9656 12.8848Z" fill="#1E1E1E"/>
    </svg>      
    {else}
    <svg width="8" height="11" viewBox="0 0 8 11" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M7.15334 4.2823C7.69716 4.6819 7.69716 5.49437 7.15334 5.89397L1.59214 9.9804C0.931721 10.4657 4.33248e-07 9.9941 4.69071e-07 9.17456L8.26318e-07 1.00171C8.62141e-07 0.18217 0.931721 -0.289406 1.59214 0.195874L7.15334 4.2823Z" fill="currentColor"/></svg>
    {/if}
  </span>
  {/if}
{if $_has_url}
</a>
{else}
{if isset($no_url_as_span) && $no_url_as_span}
</span>
{else}
</button>
{/if}
{/if}
