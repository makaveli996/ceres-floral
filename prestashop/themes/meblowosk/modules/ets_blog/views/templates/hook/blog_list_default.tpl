{*
 * Default blog list template — used for the main blog page, search, latest, year/month, author views.
 * Copied from ets_blog/views/templates/hook/blog_list.tpl for use as a fallback in the dispatcher.
 * Used by: blog_list.tpl (dispatcher) else branch.
 * Inputs: $blog_posts, $blog_category, $blog_search, $blog_latest, $author, $month, $year, $is_main_page
 *}
<div class="container-lg">
    <div class="ets_blog_layout_{$blog_layout|escape:'html':'UTF-8'} ets-blog-wrapper ets-blog-wrapper-blog-list{if isset($ets_blog_config.ETS_BLOG_AUTO_LOAD) &&$ets_blog_config.ETS_BLOG_AUTO_LOAD} loadmore{/if} {if $blog_latest}ets-page-latest{elseif $blog_category}ets-page-category{elseif $blog_search}ets-page-search{elseif $author}ets-page-author{else}ets-page-home{/if}">
        {if $blog_category}
            {if isset($blog_category.enabled) && $blog_category.enabled}
                <div class="blog-category {if $blog_category.image}has-blog-image{/if}">
                    {if $blog_category.image}
                        <div class="ets_item_img">
                            <img src="{$link->getMediaLink("`$smarty.const._PS_ETS_BLOG_IMG_`category/`$blog_category.image|escape:'htmlall':'UTF-8'`")}" alt="{$blog_category.title|escape:'html':'UTF-8'}" title="{$blog_category.title|escape:'html':'UTF-8'}" width="1920px" height="750px" />  
                        </div>
                    {/if}
                    <h1 class="page-heading product-listing">{$blog_category.title|escape:'html':'UTF-8'}</h1>            
                    {if $blog_category.description}
                        <div class="blog-category-desc">
                            {$blog_category.description|escape nofilter}
                        </div>
                    {/if}
                </div>
            {else}
                <p class="alert alert-warning">{l s='This category is not available' mod='ets_blog'}</p>
            {/if}
        {elseif $blog_latest}
        <h1 class="page-heading product-listing">{l s='Latest posts' mod='ets_blog'}</h1>
        {elseif $blog_search}
            <h1 class="page-heading product-listing">{l s='Search: ' mod='ets_blog'}"{ucfirst(str_replace('+',' ',$blog_search))|escape:'html':'UTF-8'}"</h1>
        {elseif $author}
            {if isset($author.disabled) && $author.disabled}
                <p class="alert alert-warning">{l s='This author is not available' mod='ets_blog'}</p>
            {else}
                {if isset($ets_blog_config.ETS_BLOG_AUTHOR_INFORMATION)&& $ets_blog_config.ETS_BLOG_AUTHOR_INFORMATION}
                    {if isset($author.description)&&$author.description}
                        <div class="ets-block-author ets-block-author-avata">
                            {if $author.avata}
                                <div class="avata_img">
                                    <img class="avata" src="{$link->getMediaLink("`$smarty.const._PS_ETS_BLOG_IMG_`avata/`$author.avata|escape:'html':'UTF-8'`")}"/>
                                </div>
                            {/if}
                            <div class="ets-des-and-author">
                                <div class="ets-author-name">
                                    <h1 class="page-heading product-listing">
                                        <a href="{$author.author_link|escape:'html':'UTF-8'}">
                                            {l s='Author' mod='ets_blog'}: {$author.name|escape:'html':'UTF-8'}
                                        </a>
                                    </h1>
                                </div>
                                {if isset($author.description)&&$author.description}
                                    <div class="ets-author-description">
                                        {$author.description nofilter}
                                    </div>
                                {/if}
                            </div>
                        </div>
                    {else}
                        <div class="ets-author-name">
                            <h1 class="page-heading product-listing">
                                {l s='Author: ' mod='ets_blog'}"{$author.name|escape:'html':'UTF-8'}"
                            </h1>
                        </div>
                    {/if}
                {else}
                <h1 class="page-heading product-listing">{l s='Author: ' mod='ets_blog'}"{$author.name|escape:'html':'UTF-8'}"</h1>
                {/if}
            {/if}
        {elseif $month}
            <h1 class="page-heading product-listing">{l s='Posted in: ' mod='ets_blog'}"{$month|escape:'html':'UTF-8'}"</h1>
        {elseif $year}
            <h1 class="page-heading product-listing">{l s='Posted in: ' mod='ets_blog'}"{$year|escape:'html':'UTF-8'}"</h1>
        {/if}
        {if !($blog_category && (!isset($blog_category.enabled) || isset($blog_category.enabled) && !$blog_category.enabled)) && ($blog_category || $blog_search || $author || $is_main_page || $blog_latest || $month || $year) && (!$author || ($author && !isset($author.disabled)))}
            {if isset($blog_posts) && $blog_posts}
                <ul class="ets-blog-list row {if $is_main_page}blog-main-page{/if}">
                    {assign var='first_post' value=true}
                    {foreach from=$blog_posts item='post'}            
                        <li>                         
                            <div class="post-wrapper">
                                {if $is_main_page && $first_post && ($blog_layout == 'large_list' || $blog_layout == 'large_grid')}
                                    {if $post.image}
                                        <a class="ets_item_img{if isset($ets_blog_config.ETS_BLOG_LAZY_LOAD)&& $ets_blog_config.ETS_BLOG_LAZY_LOAD} ets_item_img_ladyload{/if}" href="{$post.link|escape:'html':'UTF-8'}">
                                            <img title="{$post.title|escape:'html':'UTF-8'}" src="{if isset($ets_blog_config.ETS_BLOG_LAZY_LOAD) && $ets_blog_config.ETS_BLOG_LAZY_LOAD}{$link->getMediaLink("`$smarty.const._MODULE_DIR_`ets_blog/views/img/bg-grey.png")|escape:'html':'UTF-8'}{else}{$post.image|escape:'html':'UTF-8'}{/if}" alt="{$post.title|escape:'html':'UTF-8'}" {if isset($ets_blog_config.ETS_BLOG_LAZY_LOAD)&& $ets_blog_config.ETS_BLOG_LAZY_LOAD} data-original="{$post.image|escape:'html':'UTF-8'}" class="lazyload"{/if} />
                                        </a>                              
                                    {elseif $post.thumb}
                                        <a class="ets_item_img{if isset($ets_blog_config.ETS_BLOG_LAZY_LOAD)&& $ets_blog_config.ETS_BLOG_LAZY_LOAD} ets_item_img_ladyload{/if}" href="{$post.link|escape:'html':'UTF-8'}">
                                            <img title="{$post.title|escape:'html':'UTF-8'}" src="{if isset($ets_blog_config.ETS_BLOG_LAZY_LOAD) && $ets_blog_config.ETS_BLOG_LAZY_LOAD}{$link->getMediaLink("`$smarty.const._MODULE_DIR_`ets_blog/views/img/bg-grey.png")|escape:'html':'UTF-8'}{else}{$post.thumb|escape:'html':'UTF-8'}{/if}" alt="{$post.title|escape:'html':'UTF-8'}" {if isset($ets_blog_config.ETS_BLOG_LAZY_LOAD)&& $ets_blog_config.ETS_BLOG_LAZY_LOAD} data-original="{$post.thumb|escape:'html':'UTF-8'}" class="lazyload"{/if} />
                                        </a>
                                    {/if}
                                    {assign var='first_post' value=false}
                                {elseif $post.thumb}
                                    <a class="ets_item_img{if isset($ets_blog_config.ETS_BLOG_LAZY_LOAD)&& $ets_blog_config.ETS_BLOG_LAZY_LOAD} ets_item_img_ladyload{/if}" href="{$post.link|escape:'html':'UTF-8'}">
                                        <img title="{$post.title|escape:'html':'UTF-8'}" src="{if isset($ets_blog_config.ETS_BLOG_LAZY_LOAD) && $ets_blog_config.ETS_BLOG_LAZY_LOAD}{$link->getMediaLink("`$smarty.const._MODULE_DIR_`ets_blog/views/img/bg-grey.png")|escape:'html':'UTF-8'}{else}{$post.thumb|escape:'html':'UTF-8'}{/if}" alt="{$post.title|escape:'html':'UTF-8'}" {if isset($ets_blog_config.ETS_BLOG_LAZY_LOAD)&& $ets_blog_config.ETS_BLOG_LAZY_LOAD} data-original="{$post.thumb|escape:'html':'UTF-8'}" class="lazyload"{/if} />
                                    </a>
                                {/if}
                                <div class="ets-blog-wrapper-content">
                                <div class="ets-blog-wrapper-content-main">
                                    <a class="ets_title_block" href="{$post.link|escape:'html':'UTF-8'}">{$post.title|escape:'html':'UTF-8'}</a>
                                    {if $show_categories && $post.categories}
                                        <div class="ets-blog-sidear-post-meta"> 
                                            {if !$date_format}{assign var='date_format' value='F jS Y'}{/if}
                                            {if $show_categories && $post.categories}
                                                <div class="ets-blog-categories">
                                                    {assign var='ik' value=0}
                                                    {assign var='totalCat' value=count($post.categories)}
                                                    <span class="be-label">{l s='Posted in' mod='ets_blog'}: </span>
                                                    {foreach from=$post.categories item='cat'}
                                                        {assign var='ik' value=$ik+1}                                        
                                                        <a href="{$cat.link|escape:'html':'UTF-8'}">{ucfirst($cat.title)|escape:'html':'UTF-8'}</a>{if $ik < $totalCat}, {/if}
                                                    {/foreach}
                                                </div>
                                            {/if}
                                        </div> 
                                    {/if}
                                    <div class="blog_description">
                                        {if $post.short_description}
                                            <p>{$post.short_description|strip_tags:'UTF-8'|truncate:500:'...'|escape:'html':'UTF-8'}</p>
                                        {elseif $post.description}
                                            <p>{$post.description|strip_tags:'UTF-8'|truncate:500:'...'|escape:'html':'UTF-8'}</p>
                                        {/if}                                  
                                    </div>
                                    <a class="read_more" href="{$post.link|escape:'html':'UTF-8'}">{if $ets_blog_config.ETS_BLOG_TEXT_READMORE}{$ets_blog_config.ETS_BLOG_TEXT_READMORE|escape:'html':'UTF-8'}{else}{l s='Read More' mod='ets_blog'}{/if}</a>
                                </div>
                                </div>
                            </div>
                        </li>
                    {/foreach}
                </ul>
                {if $blog_paggination}
                    {include file='_partials/blog-pagination.tpl' pagination_html=$blog_paggination}
                {/if}
            {else}
                <p>{l s='No posts found' mod='ets_blog'}</p>
            {/if}
        {/if}
    </div>
</div>