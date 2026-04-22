{**
 * Blockwishlist — pojedynczy wiersz listy (AJAX): kafelek + data-* dla JS „usuń z listy” (bez serca — produkt już na liście).
 * Wywołanie: BlockWishlistViewModuleFrontController (Smarty fetch).
 * Zmienne: $product, $id_wishlist
 *}
<div
  class="wishlist-smarty-tile"
  data-wishlist-id="{$id_wishlist|intval}"
  data-id-product="{$product.id_product|intval}"
  data-id-product-attribute="{if isset($product.wishlist_line_id_product_attribute)}{$product.wishlist_line_id_product_attribute|intval}{else}{$product.id_product_attribute|default:0|intval}{/if}"
  data-remove-from-wishlist-url="{$removeFromWishlistUrl|escape:'html':'UTF-8'}"
>
  {include file='_partials/product-tile.tpl' product=$product product_tile_hide_wishlist=true}
</div>
