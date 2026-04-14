{**
 * Override: search widget in header. Placeholder and structure for Figma.
 * Source: module ps_searchbar. Only placeholder changed from core.
 *}
<div id="search_widget" class="search-widgets" data-search-controller-url="{$search_controller_url}">
  <form method="get" action="{$search_controller_url}">
    <input type="hidden" name="controller" value="search">
    <button class="search-icon">
      <svg width="18" height="17" viewBox="0 0 18 17" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M16.8241 15.6699L13.4143 12.2795C14.3297 11.0695 14.8173 9.42783 14.8553 7.37375C14.7739 2.64937 12.1369 0.031005 7.42336 0C2.65325 0.0302298 0 2.79975 0 7.37298C0 12.1749 2.65557 14.746 7.43266 14.7739C9.47046 14.7615 11.106 14.2886 12.3183 13.3748L15.7311 16.769C16.1327 17.1504 16.6078 16.9946 16.8272 16.7659C17.124 16.4574 17.1279 15.9714 16.8241 15.6699ZM1.55025 7.38693C1.62543 3.48418 3.54929 1.57428 7.42259 1.55025C11.2587 1.57505 13.2383 3.54309 13.305 7.37298C13.2321 11.3416 11.3633 13.2004 7.43266 13.2236C3.49736 13.2004 1.62776 11.3463 1.55025 7.38693Z" fill="white"/>
      </svg>
    </button>
    <input type="text" name="s" value="{$search_string}" placeholder="{l s='Jakiego mebla szukasz?' d='Shop.Theme.Catalog'}" aria-label="{l s='Search' d='Shop.Theme.Catalog'}">
    <i class="material-icons clear" aria-hidden="true">clear</i>
  </form>
</div>
