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
{* Resolve the ets_blog index URL once — used to filter out the "Blog" breadcrumb item
   that would otherwise link to /blog/ which is set to redirect to 404.
   ets_blog->getLink('blog') produces e.g. https://example.com/blog (no trailing slash),
   so we build the same URL via getBaseLink() + the module's friendly-URL alias "blog". *}
{assign var='ets_blog_idx' value=$link->getBaseLink()|rtrim:'/'|cat:'/blog'}

{* Rebuild links array without the blog-index entry *}
{assign var='visible_links' value=[]}
{foreach from=$breadcrumb.links item=path}
  {if $path.url|rtrim:'/' !== $ets_blog_idx}
    {append var='visible_links' value=$path}
  {/if}
{/foreach}

{* Cart: core CartControllerCore nie dopisuje poziomu — fallback gdy override/cache nie załaduje CartController. *}
{if isset($page.page_name) && $page.page_name == 'cart' && isset($visible_links) && $visible_links|count == 1}
  {capture name='bc_cart_title'}{l s='Shopping Cart' d='Shop.Theme.Checkout'}{/capture}
  {assign var='bc_cart_item' value=['title' => $smarty.capture.bc_cart_title, 'url' => $urls.pages.cart]}
  {append var='visible_links' value=$bc_cart_item}
{/if}

{* Kasa: OrderControllerCore nie ma getBreadcrumbLinks; $page.page_name to "checkout" (nie "order"). *}
{if isset($page.page_name) && $page.page_name == 'checkout' && isset($visible_links) && $visible_links|count == 1}
  {capture name='bc_checkout_title'}{l s='Checkout' d='Shop.Theme.Checkout'}{/capture}
  {assign var='bc_checkout_item' value=['title' => $smarty.capture.bc_checkout_title, 'url' => $urls.pages.order]}
  {append var='visible_links' value=$bc_checkout_item}
{/if}

<div class="breadcrumbs-wrapper">
  <div class="container-lg">
    <nav data-depth="{$visible_links|count}" class="breadcrumbs">
      <ol>
        {block name='breadcrumb'}
          {foreach from=$visible_links item=path name=breadcrumb}
            {block name='breadcrumb_item'}
              <li>
                {if not $smarty.foreach.breadcrumb.last}
                  <a href="{$path.url}"><span>{$path.title}</span></a>
                {else}
                  <span>{$path.title}</span>
                {/if}
              </li>
            {/block}
          {/foreach}
        {/block}
      </ol>
    </nav>
  </div>
</div>
