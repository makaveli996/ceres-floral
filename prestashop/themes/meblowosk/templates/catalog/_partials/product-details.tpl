<div class="pdp__tab-panel tab-pane pdp-details js-product-details{if !$product.description} active js-product-tab-active{/if}"
     id="product-details"
     data-product="{$product.embedded_attributes|json_encode}"
     role="tabpanel"
  >
  {block name='product_reference'}
    {if isset($product_manufacturer->id)}
      <div class="pdp-details__manufacturer product-manufacturer">
        {if isset($manufacturer_image_url)}
          <a href="{$product_brand_url}">
            <img src="{$manufacturer_image_url}" class="img img-fluid manufacturer-logo" alt="{$product_manufacturer->name}" loading="lazy">
          </a>
        {else}
          <label class="pdp-details__meta-label label">{l s='Brand' d='Shop.Theme.Catalog'}</label>
          <span>
            <a href="{$product_brand_url}">{$product_manufacturer->name}</a>
          </span>
        {/if}
      </div>
    {/if}
    {if isset($product.reference_to_display) && $product.reference_to_display neq ''}
      <div class="pdp-details__reference product-reference">
        <label class="pdp-details__meta-label label">{l s='Reference' d='Shop.Theme.Catalog'} </label>
        <span>{$product.reference_to_display}</span>
      </div>
    {/if}
  {/block}

  {block name='product_quantities'}
    {if $product.show_quantities}
      <div class="pdp-details__quantities product-quantities">
        <label class="pdp-details__meta-label label">{l s='In stock' d='Shop.Theme.Catalog'}</label>
        <span data-stock="{$product.quantity}" data-allow-oosp="{$product.allow_oosp}">{$product.quantity} {$product.quantity_label}</span>
      </div>
    {/if}
  {/block}

  {block name='product_availability_date'}
    {if $product.availability_date}
      <div class="pdp-details__availability-date product-availability-date">
        <label>{l s='Availability date:' d='Shop.Theme.Catalog'} </label>
        <span>{$product.availability_date}</span>
      </div>
    {/if}
  {/block}

  {block name='product_out_of_stock'}
    <div class="pdp-details__out-of-stock product-out-of-stock">
      {hook h='actionProductOutOfStock' product=$product}
    </div>
  {/block}

  {block name='product_features'}
    {if $product.grouped_features}
      <section class="pdp-details__features product-features">
        <p class="pdp-details__section-title">{l s='Data sheet' d='Shop.Theme.Catalog'}</p>
        <dl class="pdp-details__data-sheet data-sheet">
          {foreach from=$product.grouped_features item=feature}
            <dt class="name">{$feature.name}</dt>
            <dd class="value">{$feature.value|escape:'htmlall'|nl2br nofilter}</dd>
          {/foreach}
        </dl>
      </section>
    {/if}
  {/block}

  {* if product have specific references, a table will be added to product details section *}
  {block name='product_specific_references'}
    {if !empty($product.specific_references)}
      <section class="pdp-details__features product-features">
        <p class="pdp-details__section-title">{l s='Specific References' d='Shop.Theme.Catalog'}</p>
          <dl class="pdp-details__data-sheet data-sheet">
            {foreach from=$product.specific_references item=reference key=key}
              <dt class="name">{$key}</dt>
              <dd class="value">{$reference}</dd>
            {/foreach}
          </dl>
      </section>
    {/if}
  {/block}

  {block name='product_condition'}
    {if $product.condition}
      <div class="pdp-details__condition product-condition">
        <label class="pdp-details__meta-label label">{l s='Condition' d='Shop.Theme.Catalog'} </label>
        <link href="{$product.condition.schema_url}"/>
        <span>{$product.condition.label}</span>
      </div>
    {/if}
  {/block}
</div>
