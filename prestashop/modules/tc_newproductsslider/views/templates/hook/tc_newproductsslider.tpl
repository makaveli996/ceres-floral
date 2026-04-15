{**
 * New Products slider — "Nowości".
 * Delegates rendering to the global _partials/product-slider.tpl component.
 * SCSS: _dev/css/custom/sections/_newproducts-slider.scss (tc-newproducts-slider block).
 * Inputs: $tc_newproductsslider_products, $tc_newproductsslider_title, $tc_newproductsslider_subtitle.
 *}
{include file='_partials/product-slider.tpl'
  title=$tc_newproductsslider_title
  subtitle=$tc_newproductsslider_subtitle
  products=$tc_newproductsslider_products
  section_class='tc-newproducts-slider'
  container='container-md'
  show_pagination=true
}
