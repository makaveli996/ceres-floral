{**
 * Fragment returned in AJAX `product_cover_thumbnails` (quantity / combination refresh).
 * Must match the full PDP markup in product.tpl — otherwise core.js replaces `.images-container`
 * with Classic cover+thumbs and breaks Splide (see product-gallery-splide.tpl).
 * Used by: PrestaShop front product refresh JSON; same variables as product page.
 *}
{include file='catalog/_partials/product-gallery-splide.tpl'}
