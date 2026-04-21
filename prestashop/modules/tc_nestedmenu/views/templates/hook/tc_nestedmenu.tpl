{*
 * Front office nested menu (tc_nestedmenu). Same structure/classes as ps_mainmenu for theme CSS/JS.
 * Variables: $menu (root with children). Used by Tc_Nestedmenu::renderWidget on displayTop.
 *}
{assign var=_counter value=0}
{function name="tc_nestedmenu_branch" nodes=[] depth=0 parent=null}
    {if $nodes|count}
      <ul class="top-menu" {if $depth == 0}id="top-menu"{/if} data-depth="{$depth}">
        {foreach from=$nodes item=node name=tc_top_nodes}
            <li class="{$node.type}{if $node.current} current {/if}" id="{$node.page_identifier}">
            {assign var=_counter value=$_counter+1}
              <a
                class="{if $depth >= 0}dropdown-item{/if}{if $depth === 1} dropdown-submenu{/if}"
                href="{$node.url|escape:'html':'UTF-8'}" data-depth="{$depth}"
                {if $node.open_in_new_window} target="_blank" rel="noopener noreferrer" {/if}
              >
                {if $node.children|count}
                  {assign var=_expand_id value=10|mt_rand:100000}
                  <span class="float-xs-right hidden-lg-up">
                    <span data-target="#top_sub_menu_{$_expand_id}" data-toggle="collapse" class="navbar-toggler collapse-icons">
                      <i class="material-icons add">&#xE313;</i>
                      <i class="material-icons remove">&#xE316;</i>
                    </span>
                  </span>
                {/if}
                {$node.label|escape:'html':'UTF-8'}
              </a>
              {if $node.children|count}
              <div {if $depth === 0} class="popover sub-menu js-sub-menu collapse"{else} class="collapse"{/if} id="top_sub_menu_{$_expand_id}">
                {tc_nestedmenu_branch nodes=$node.children depth=$node.depth parent=$node}
              </div>
              {/if}
            </li>
            {if $depth == 0 && !$smarty.foreach.tc_top_nodes.last}
              <li class="menu-separator" aria-hidden="true"></li>
            {/if}
        {/foreach}
      </ul>
    {/if}
{/function}

<div class="menu js-top-menu position-static hidden-md-down" id="_desktop_top_menu">
    {tc_nestedmenu_branch nodes=$menu.children}
    <div class="clearfix"></div>
</div>
