{**
 * Theme override for ps_searchbar in desktop header actions.
 * Keeps module logic (form/input/autocomplete) but separates trigger icon
 * from input so the field can expand to the left of the icon.
 *}
<div id="search_widget" class="search-widgets" data-search-controller-url="{$search_controller_url}">
  <form method="get" action="{$search_controller_url}">
    <input type="hidden" name="controller" value="search">
    <button type="button" class="search-widgets__trigger" aria-label="{l s='Search' d='Shop.Theme.Catalog'}" onclick="this.nextElementSibling.focus();">
      <span class="search-widgets__icon" aria-hidden="true"></span>
    </button>
    <input
      class="search-widgets__input ui-autocomplete-input"
      type="text"
      name="s"
      value="{$search_string}"
      placeholder="{l s='Search our catalog' d='Shop.Theme.Catalog'}"
      aria-label="{l s='Search' d='Shop.Theme.Catalog'}"
      autocomplete="off"
    >
    <i class="material-icons clear" aria-hidden="true">clear</i>
  </form>
</div>
