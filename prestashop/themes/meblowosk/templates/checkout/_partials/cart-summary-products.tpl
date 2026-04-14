{**
 * Checkout sidebar: product list always visible (no collapse). Theme override.
 * Variables: $cart (products, summary_string).
 *}
<div class="cart-summary-products js-cart-summary-products">
  <p class="cart-summary-products__count">{$cart.summary_string}</p>

  {block name='cart_summary_product_list'}
    <div class="cart-summary-products__list" id="cart-summary-product-list">
      <ul class="cart-summary-products__items">
        {foreach from=$cart.products item=product}
          <li class="cart-summary-products__item">
            {include file='checkout/_partials/cart-summary-product-line.tpl' product=$product}
          </li>
        {/foreach}
      </ul>
    </div>
  {/block}
</div>
