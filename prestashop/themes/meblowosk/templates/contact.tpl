{**
 * Contact page: same layout as CMS (no side columns), page title at top, content via displayContactContent.
 * Used by: ContactController. Modules hook into displayContactContent for front content.
 *}
{extends file='page.tpl'}

{block name='page_title'}
  {$page.meta.title}
{/block}

{block name='page_content_container'}
  <section id="content" class="page-cms page-contact">
    <header class="page-header">
      <div class="container-lg">
        <h1 class="h1">{$page.meta.title}</h1>
      </div>
    </header>
    {hook h='displayContactContent'}
  </section>
{/block}
