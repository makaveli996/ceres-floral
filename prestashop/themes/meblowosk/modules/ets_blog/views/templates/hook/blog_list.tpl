{*
 * Blog list dispatcher — theme override for ets_blog/views/templates/hook/blog_list.tpl.
 * Routes to a category-specific sub-template based on $blog_category.url_alias.
 * Used by: Ets_blogBlogModuleFrontController::displayListPosts()
 * Inputs: $blog_category (array with url_alias), $blog_posts, $blog_paggination
 * Side effects: none — rendering only.
 *}
{if $blog_category && $blog_category.url_alias == 'porady'}
  {include file='module:ets_blog/views/templates/hook/blog_list_tips.tpl'}
{elseif $blog_category && $blog_category.url_alias == 'inspiracje'}
  {include file='module:ets_blog/views/templates/hook/blog_list_inspiration.tpl'}
{else}
  {include file='module:ets_blog/views/templates/hook/blog_list_default.tpl'}
{/if}
