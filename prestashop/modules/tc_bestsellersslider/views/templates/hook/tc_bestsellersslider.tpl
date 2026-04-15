{**
 * Bestsellers slider — "Najczęściej kupowane". Figma node 240:2772.
 * Delegates rendering to the global _partials/product-slider.tpl component.
 * SCSS: _dev/css/custom/sections/_bestsellers-slider.scss (tc-bestsellers-slider block).
 * Inputs: $tc_bestsellersslider_products, $tc_bestsellersslider_title, $tc_bestsellersslider_subtitle.
 *}
{include file='_partials/product-slider.tpl'
  title=$tc_bestsellersslider_title
  subtitle=$tc_bestsellersslider_subtitle
  products=$tc_bestsellersslider_products
  section_class='tc-bestsellers-slider'
  container='container-md'
  show_pagination=true
}
