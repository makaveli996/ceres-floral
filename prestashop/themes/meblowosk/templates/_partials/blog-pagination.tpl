{**
 * Shared ets_blog list pagination shell (HTML from TcEtsBlogPaggination_class::render() via blog controller override).
 * Used by: blog_list_tips.tpl, blog_list_inspiration.tpl, blog_list_default.tpl (theme ets_blog hooks).
 * Required: $pagination_html — same as Smarty $blog_paggination (string, .results + .links markup).
 * Optional: $pagination_id (string) — DOM id for AJAX modules, e.g. blog-tips-pagination, blog-insp-pagination.
 *           $pagination_aria_label (string) — overrides default accessible name for <nav>.
 * Styled by: _dev/css/custom/parts/_blog-pagination.scss
 * Side effects: none.
 *}
{if isset($pagination_html) && $pagination_html}
  <nav
    class="blog-pagination"
    {if isset($pagination_id) && $pagination_id|trim ne ''}id="{$pagination_id|trim|escape:'html':'UTF-8'}"{/if}
    aria-label="{if isset($pagination_aria_label) && $pagination_aria_label|trim ne ''}{$pagination_aria_label|trim|escape:'html':'UTF-8'}{else}{l s='Paginacja' mod='ets_blog'}{/if}"
  >
    {$pagination_html nofilter}
  </nav>
{/if}
