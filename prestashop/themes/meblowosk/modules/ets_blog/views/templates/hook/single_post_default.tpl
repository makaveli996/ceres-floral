{*
 * Default single post layout — fallback for posts not assigned to porady or inspiracje.
 * Used by: single_post.tpl (dispatcher) else branch.
 * Derived from the original ets_blog/views/templates/hook/single_post.tpl.
 *}
<script type="text/javascript">
    ets_blog_report_url = '{$report_url nofilter}';
    ets_blog_report_warning = "{l s='Do you want to report this comment?' mod='ets_blog'}";
    ets_blog_error = "{l s='There was a problem while submitting your report. Try again later' mod='ets_blog'}";
</script>

{if !$date_format}{assign var='date_format' value='d.m.Y'}{/if}
<div class="container-lg">
    <div class="ets_blog_layout_{$blog_layout|escape:'html':'UTF-8'} ets-blog-wrapper-detail" itemscope itemType="http://schema.org/newsarticle">
        {if $blog_post.image}
            <div class="ets_blog_img_wrapper" itemprop="image" itemscope itemtype="http://schema.org/ImageObject">
                <div class="ets_image-single">                            
                    <img title="{$blog_post.title|escape:'html':'UTF-8'}" src="{$blog_post.image|escape:'html':'UTF-8'}" alt="{$blog_post.title|escape:'html':'UTF-8'}" itemprop="url"/>
                </div>
            </div>
        {/if}
        <div class="ets-blog-wrapper-content">
        {if $blog_post}
            <h1 class="page-heading product-listing" itemprop="mainEntityOfPage"><span class="title_cat" itemprop="headline">{$blog_post.title|escape:'html':'UTF-8'}</span></h1>
            <div class="post-details">
                <div class="blog-extra">
                    <div class="ets-blog-latest-toolbar">
                        {if $show_date}
                            {if !$date_format}{assign var='date_format' value='F jS Y'}{/if}
                            <span class="post-date">
                                <span class="be-label">{l s='Posted on' mod='ets_blog'}: </span>
                                <span>{date($date_format,strtotime($blog_post.date_add))|escape:'html':'UTF-8'}</span>
                                <meta itemprop="datePublished" content="{date('Y-m-d',strtotime($blog_post.date_add))|escape:'html':'UTF-8'}" />
                                <meta itemprop="dateModified" content="{date('Y-m-d',strtotime($blog_post.date_upd))|escape:'html':'UTF-8'}" />
                            </span>
                        {/if}
                        {if $show_author && isset($blog_post.employee) && $blog_post.employee}
                            <div class="author-block" itemprop="author" itemscope itemtype="http://schema.org/Person">
                                <span class="post-author-label">{l s='By ' mod='ets_blog'}</span>
                                <a itemprop="url" href="{$blog_post.author_link|escape:'html':'UTF-8'}">
                                    <span class="post-author-name" itemprop="name">
                                        {if isset($blog_post.employee.name) && $blog_post.employee.name}
                                            {ucfirst($blog_post.employee.name)|escape:'html':'UTF-8'}
                                        {else}
                                            {ucfirst($blog_post.employee.firstname)|escape:'html':'UTF-8'} {ucfirst($blog_post.employee.lastname)|escape:'html':'UTF-8'}
                                        {/if}
                                    </span>
                                </a>
                            </div>
                        {/if}
                    </div>
                </div>
            </div>
            <div class="blog_description">
                {if $blog_post.description}
                    {$blog_post.description nofilter}
                {else}
                    {$blog_post.short_description nofilter}
                {/if}
            </div>
            {if ($show_tags && $blog_post.tags) || ($show_categories && $blog_post.categories)}
            <div class="extra_tag_cat">
                {if $show_tags && $blog_post.tags}
                    <div class="ets-blog-tags">
                        {assign var='ik' value=0}
                        {assign var='totalTag' value=count($blog_post.tags)}
                        {foreach from=$blog_post.tags item='tag'}
                            {assign var='ik' value=$ik+1}
                            <a href="{$tag.link|escape:'html':'UTF-8'}">{ucfirst($tag.tag)|escape:'html':'UTF-8'}</a>{if $ik < $totalTag}, {/if}
                        {/foreach}
                    </div>
                {/if}
                {if $show_categories && $blog_post.categories}
                    <div class="ets-blog-categories">
                        {assign var='ik' value=0}
                        {assign var='totalCat' value=count($blog_post.categories)}
                        <div class="be-categories">
                            <span class="be-label">{l s='Posted in' mod='ets_blog'}: </span>
                            {foreach from=$blog_post.categories item='cat'}
                                {assign var='ik' value=$ik+1}
                                <a href="{$cat.link|escape:'html':'UTF-8'}">{ucfirst($cat.title)|escape:'html':'UTF-8'}</a>{if $ik < $totalCat}, {/if}
                            {/foreach}
                        </div>
                    </div>
                {/if}
            </div>
            {/if}
            <div class="ets-blog-wrapper-comment">
                {if $allowComments}
                    <div class="ets_comment_form_blog">
                        <h4 class="title_blog">{l s='Leave a comment' mod='ets_blog'}</h4>
                        <div class="ets-blog-form-comment" id="ets-blog-form-comment">
                            {if $hasLoggedIn || $allowGuestsComments}
                                <form action="#ets-blog-form-comment" method="post">
                                    {if isset($comment_edit->id) && $comment_edit->id && !$justAdded}
                                        <input type="hidden" value="{$comment_edit->id|intval}" name="id_comment" />
                                    {/if}
                                    {if !$hasLoggedIn}
                                        <div class="blog-comment-row blog-name">
                                            <label for="bc-name">{l s='Name' mod='ets_blog'}</label>
                                            <input class="form-control" name="name_customer" id="bc-name" type="text" value="{if isset($name_customer)}{$name_customer|escape:'html':'UTF-8'}{/if}" />
                                        </div>
                                        <div class="blog-comment-row blog-email">
                                            <label for="bc-email">{l s='Email' mod='ets_blog'}</label>
                                            <input class="form-control" name="email_customer" id="bc-email" type="text" value="{if isset($email_customer)}{$email_customer|escape:'html':'UTF-8'}{/if}" />
                                        </div>
                                    {/if}
                                    <div class="blog-comment-row blog-title">
                                        <label for="bc-subject">{l s='Subject ' mod='ets_blog'}</label>
                                        <input class="form-control" name="subject" id="bc-subject" type="text" value="{if isset($subject)}{$subject|escape:'html':'UTF-8'}{/if}" />
                                    </div>
                                    <div class="blog-comment-row blog-content-comment">
                                        <label for="bc-comment">{l s='Comment ' mod='ets_blog'}</label>
                                        <textarea class="form-control" name="comment" id="bc-comment">{if isset($comment)}{$comment|escape:'html':'UTF-8'}{/if}</textarea>
                                    </div>
                                    <div class="blog-comment-row">
                                        <div class="blog-submit">
                                            <input class="button" type="submit" value="{l s='Submit Comment' mod='ets_blog'}" name="bcsubmit" />
                                        </div>
                                    </div>
                                    {if isset($blog_errors) && is_array($blog_errors) && $blog_errors}
                                        <div class="alert alert-danger ets_alert-danger">
                                            <ul>
                                                {foreach from=$blog_errors item='error'}
                                                    <li>{$error|escape:'html':'UTF-8'}</li>
                                                {/foreach}
                                            </ul>
                                        </div>
                                    {/if}
                                    {if isset($blog_success) && $blog_success}
                                        <p class="alert alert-success ets_alert-success">{$blog_success|escape:'html':'UTF-8'}</p>
                                    {/if}
                                </form>
                            {else}
                                <p class="alert alert-warning">{l s='Log in to post comments' mod='ets_blog'}</p>
                            {/if}
                        </div>
                    </div>
                    {if count($comments)}
                        <div class="ets_blog-comments-list">
                            <h4 class="title_blog">{l s='Comments' mod='ets_blog'}</h4>
                            <ul id="blog-comments-list" class="blog-comments-list">
                                {foreach from=$comments item='comment'}
                                    <li id="blog_comment_line_{$comment.id_comment|intval}" class="blog-comment-line">
                                        <div class="ets-blog-detail-comment">
                                            <h5 class="comment-subject">{$comment.subject|escape:'html':'UTF-8'}</h5>
                                            {if $comment.name}<span class="comment-by">{l s='By: ' mod='ets_blog'}<b>{ucfirst($comment.name)|escape:'html':'UTF-8'}</b></span>{/if}
                                            <span class="comment-time">{date($date_format,strtotime($comment.date_add))|escape:'html':'UTF-8'}</span>
                                            {if $comment.comment}<p class="comment-content">{$comment.comment nofilter}</p>{/if}
                                        </div>
                                    </li>
                                {/foreach}
                            </ul>
                            {if isset($link_view_all_comment)}
                                <div class="blog_view_all_button">
                                    <a href="{$link_view_all_comment|escape:'html':'UTF-8'}" class="view_all_link">{l s='View all comments' mod='ets_blog'}</a>
                                </div>
                            {/if}
                        </div>
                    {/if}
                {/if}
            </div>
        {else}
            <p class="warning">{l s='No posts found' mod='ets_blog'}</p>
        {/if}
        </div>
    </div>
</div>

{if $blog_post.related_posts}
    <div class="ets-blog-related-posts">
        <h4 class="title_blog">{l s='Worth reading' mod='ets_blog'}</h4>
        <ul class="ets-blog-related-posts-list">
            {foreach from=$blog_post.related_posts item='rpost'}
                <li class="ets-blog-related-posts-list-li">
                    {if $rpost.thumb}
                        <a class="ets_item_img" href="{$rpost.link|escape:'html':'UTF-8'}">
                            <img src="{$rpost.thumb|escape:'html':'UTF-8'}" alt="{$rpost.title|escape:'html':'UTF-8'}" />
                        </a>
                    {/if}
                    <a class="ets_title_block" href="{$rpost.link|escape:'html':'UTF-8'}">{$rpost.title|escape:'html':'UTF-8'}</a>
                    <span class="post-date">{date($date_format,strtotime($rpost.date_add))|escape:'html':'UTF-8'}</span>
                </li>
            {/foreach}
        </ul>
    </div>
{/if}
