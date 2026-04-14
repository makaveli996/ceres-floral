{*
 * Blog front wrapper — theme override for ets_blog/views/templates/front/blog.tpl.
 * Removes the module's built-in left sidebar column; blog_content fills full width.
 * Used by: Ets_blogBlogModuleFrontController::initContent() (PS 1.7+).
 * Inputs: $blog_content (rendered HTML string from _initContent()).
 * Side effects: none — rendering only.
 *}
{extends file="page.tpl"}
{block name="content"}
    {$blog_content nofilter}
{/block}
