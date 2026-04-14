{**
 * Blog post tile (.post-card): thumb, optional category badge, date, title, hover arrow.
 * Used by: modules/tc_seealso_blog/.../tc_seealso_blog.tpl, modules/ets_blog/.../blog_list_tips.tpl.
 * Required: $post_card_url, $post_card_title.
 * Optional: $post_card_image (thumb URL), $post_card_category (badge text),
 *            $post_card_date (visible date string), $post_card_datetime (machine-readable for <time datetime="">).
 * Styled by: _dev/css/custom/parts/_post-card.scss
 *}
<li class="post-card">
  <a href="{$post_card_url|escape:'html':'UTF-8'}" class="post-card__link">
    {if isset($post_card_image) && $post_card_image}
      <div class="post-card__img-wrap">
        <img
          src="{$post_card_image|escape:'html':'UTF-8'}"
          alt="{$post_card_title|escape:'html':'UTF-8'}"
          class="post-card__img"
          loading="lazy"
        />
        {if isset($post_card_category) && $post_card_category|trim != ''}
          <span class="post-card__cat">{$post_card_category|trim|escape:'html':'UTF-8'}</span>
        {/if}
      </div>
    {/if}
    <div class="post-card__body">
      {if isset($post_card_date) && $post_card_date|trim != ''}
        <time class="post-card__date"{if isset($post_card_datetime) && $post_card_datetime|trim != ''} datetime="{$post_card_datetime|trim|escape:'html':'UTF-8'}"{/if}>{$post_card_date|trim|escape:'html':'UTF-8'}</time>
      {/if}
      <h3 class="post-card__title">{$post_card_title|escape:'html':'UTF-8'}</h3>
      <div class="post-card__arrow" aria-hidden="true">
        <svg class="post-card__arrow-icon" width="21" height="21" viewBox="0 0 21 21" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M0 10.5C0 4.70101 4.70101 0 10.5 0C16.299 0 21 4.70101 21 10.5C21 16.299 16.299 21 10.5 21C4.70101 21 0 16.299 0 10.5Z" fill="#F7A626"/>
          <path d="M12.8117 10.0769C13.0972 10.2867 13.0972 10.7133 12.8117 10.9231L9.89207 13.0684C9.54535 13.3232 9.0562 13.0756 9.0562 12.6454L9.0562 8.35464C9.0562 7.92438 9.54536 7.6768 9.89207 7.93158L12.8117 10.0769Z" fill="#1E1E1E"/>
        </svg>
      </div>
    </div>
  </a>
</li>
