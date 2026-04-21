{**
 * Optional CSS class for layout-full-width #content-wrapper: "container-lg" only on native FO
 * checkout / cart / customer-account / sitemap — not blog, CMS listings, product, home.
 * Included from layouts/layout-full-width.tpl; outputs " container-lg tc-system-page" or empty (leading space).
 * Vertical spacing: see _layout.scss (#content-wrapper.tc-system-page).
 * Page names: getPageName() — OrderController sets page_name "checkout" (php_self remains "order").
 *}
{strip}
{if $page.page_name == 'cart'
  || $page.page_name == 'checkout'
  || $page.page_name == 'order'
  || strpos($page.page_name, 'module-blockwishlist-') === 0
  || strpos($smarty.server.REQUEST_URI|default:'', '/module/blockwishlist/') !== false
  || strpos($page.page_name, 'module-psgdpr-') === 0
  || strpos($smarty.server.REQUEST_URI|default:'', '/module/psgdpr/') !== false
  || $page.page_name == 'authentication'
  || $page.page_name == 'registration'
  || $page.page_name == 'password'
  || $page.page_name == 'guest-tracking'
  || $page.page_name == 'my-account'
  || $page.page_name == 'addresses'
  || $page.page_name == 'address'
  || $page.page_name == 'identity'
  || $page.page_name == 'history'
  || $page.page_name == 'order-detail'
  || $page.page_name == 'order-follow'
  || $page.page_name == 'order-slip'
  || $page.page_name == 'order-return'
  || $page.page_name == 'order-confirmation'
  || $page.page_name == 'discount'
  || $page.page_name == 'search'
  || $page.page_name == 'sitemap'
} container-lg tc-system-page{/if}
{/strip}
