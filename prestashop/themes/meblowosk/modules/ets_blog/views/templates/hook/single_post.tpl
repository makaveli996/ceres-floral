{*
 * Single post dispatcher — theme override for ets_blog/views/templates/hook/single_post.tpl.
 * Detects the post's primary category via url_alias and routes to a category-specific sub-template.
 * Used by: Ets_blogBlogModuleFrontController::_initContent() when id_post is set.
 * Inputs: $blog_post (array with .categories[].url_alias), all other single-post Smarty vars.
 * Side effects: none — rendering only.
 *}
{assign var='_post_type' value='default'}
{if $blog_post && $blog_post.categories}
  {foreach from=$blog_post.categories item='_cat'}
    {if $_cat.url_alias == 'porady'}
      {assign var='_post_type' value='porady'}
      {break}
    {/if}
    {if $_cat.url_alias == 'inspiracje'}
      {assign var='_post_type' value='inspiracje'}
      {break}
    {/if}
  {/foreach}
{/if}

{if $_post_type == 'porady'}
  {include file='module:ets_blog/views/templates/hook/single_post_tips.tpl'}
{elseif $_post_type == 'inspiracje'}
  {include file='module:ets_blog/views/templates/hook/single_post_inspiration.tpl'}
{else}
  {include file='module:ets_blog/views/templates/hook/single_post_default.tpl'}
{/if}
