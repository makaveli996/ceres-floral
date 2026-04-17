{*
 * Purpose: Render image+CTA content section on the homepage.
 * Used from: tc_imagecta::renderWidget() via hookDisplayHome.
 * Inputs: $title, $description, $btn_label, $btn_url,
 *         $img_left_big, $img_left_small, $img_left_med,
 *         $img_right_big, $img_right_small, $img_right_med.
 * Outputs: Section HTML with --clr-gray-2 background inside container-md.
 * Side effects: None.
 *}
<section class="tc-imagecta">
  <div class="container-md">
    <div class="tc-imagecta__layout">

      {* ── LEFT IMAGE GROUP ── *}
      <div class="tc-imagecta__col tc-imagecta__col--left">
        <div class="tc-imagecta__img-big">
          {if $img_left_big}
            <img
              class="tc-imagecta__img-big__photo"
              src="{$img_left_big|escape:'htmlall':'UTF-8'}"
              alt=""
              loading="lazy">
          {/if}
          {* Small images absolutely positioned relative to big *}
          {if $img_left_small}
            <div class="tc-imagecta__img-small tc-imagecta__img-small--top">
              <img
                src="{$img_left_small|escape:'htmlall':'UTF-8'}"
                alt=""
                loading="lazy">
            </div>
          {/if}
          {if $img_left_med}
            <div class="tc-imagecta__img-medium tc-imagecta__img-medium--right">
              <img
                src="{$img_left_med|escape:'htmlall':'UTF-8'}"
                alt=""
                loading="lazy">
            </div>
          {/if}
        </div>
      </div>

      {* ── CENTER CONTENT ── *}
      <div class="tc-imagecta__center">
        {if $title}
          <h2 class="tc-imagecta__title">{$title|escape:'htmlall':'UTF-8'}</h2>
        {/if}
        {if $description}
          <p class="tc-imagecta__description">{$description|escape:'htmlall':'UTF-8'}</p>
        {/if}
        {if $btn_label && $btn_url}
          <div class="tc-imagecta__cta">
            {include file='_partials/button.tpl'
              url=$btn_url
              label=$btn_label
              btn_class='tc-imagecta__button button--green'
              icon_type='arrow-right'}
          </div>
        {/if}
      </div>

      {* ── RIGHT IMAGE GROUP ── *}
      <div class="tc-imagecta__col tc-imagecta__col--right">
        <div class="tc-imagecta__img-big">
          {if $img_right_big}
            <img
              class="tc-imagecta__img-big__photo"
              src="{$img_right_big|escape:'htmlall':'UTF-8'}"
              alt=""
              loading="lazy">
          {/if}
          {* Small images absolutely positioned relative to big *}
          {if $img_right_small}
            <div class="tc-imagecta__img-small tc-imagecta__img-small--top">
              <img
                src="{$img_right_small|escape:'htmlall':'UTF-8'}"
                alt=""
                loading="lazy">
            </div>
          {/if}
          {if $img_right_med}
            <div class="tc-imagecta__img-medium tc-imagecta__img-medium--left">
              <img
                src="{$img_right_med|escape:'htmlall':'UTF-8'}"
                alt=""
                loading="lazy">
            </div>
          {/if}
        </div>
      </div>

    </div>
  </div>
</section>
