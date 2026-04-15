{*
 * Purpose: Render alternating content+image rows on the homepage.
 * Used from: tc_contentrows::renderWidget() via hookDisplayHome.
 * Inputs: $rows (array with title, description, button_label, button_url, image).
 * Outputs: Section HTML with --clr-gray background inside container-md.
 * Side effects: None.
 *}
<section class="tc-content-rows">
  <div class="container-md">
    <div class="tc-content-rows__rows">
      {foreach from=$rows item=row name=rowsLoop}
        <div class="tc-content-rows__row{if $smarty.foreach.rowsLoop.index % 2 !== 0} tc-content-rows__row--reversed{/if}">

          <div class="tc-content-rows__content">
            {if $row.title}
              <h2 class="tc-content-rows__title">{$row.title|escape:'htmlall':'UTF-8'}</h2>
            {/if}
            {if $row.description}
              <div class="tc-content-rows__description">{$row.description|nl2br nofilter}</div>
            {/if}
            {if $row.button_label && $row.button_url}
              <div class="tc-content-rows__cta">
                {include file='_partials/button.tpl'
                  url=$row.button_url
                  label=$row.button_label
                  btn_class='tc-content-rows__button'
                  icon_type='arrow-right'}
              </div>
            {/if}
          </div>

          <div class="tc-content-rows__media">
            {if $row.image}
              <img
                class="tc-content-rows__image"
                src="{$row.image|escape:'htmlall':'UTF-8'}"
                alt="{$row.title|escape:'htmlall':'UTF-8'}"
                loading="lazy">
            {/if}
          </div>

        </div>
      {/foreach}
    </div>
  </div>
</section>
