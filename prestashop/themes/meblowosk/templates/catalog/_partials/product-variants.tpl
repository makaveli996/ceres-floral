{**
 * Copyright since 2007 PrestaShop SA and Contributors
 * PrestaShop is an International Registered Trademark & Property of PrestaShop SA
 *
 * NOTICE OF LICENSE
 *
 * This source file is subject to the Academic Free License 3.0 (AFL-3.0)
 * that is bundled with this package in the file LICENSE.md.
 * It is also available through the world-wide-web at this URL:
 * https://opensource.org/licenses/AFL-3.0
 * If you did not receive a copy of the license and are unable to
 * obtain it through the world-wide-web, please send an email
 * to license@prestashop.com so we can send you a copy immediately.
 *
 * DISCLAIMER
 *
 * Do not edit or add to this file if you wish to upgrade PrestaShop to newer
 * versions in the future. If you wish to customize PrestaShop for your
 * needs please refer to https://devdocs.prestashop.com/ for more information.
 *
 * @author    PrestaShop SA and Contributors <contact@prestashop.com>
 * @copyright Since 2007 PrestaShop SA and Contributors
 * @license   https://opensource.org/licenses/AFL-3.0 Academic Free License 3.0 (AFL-3.0)
 *}
<div class="pdp-variants product-variants js-product-variants">
  {foreach from=$groups key=id_attribute_group item=group}
    {if !empty($group.attributes)}
    <div class="pdp-variants__item product-variants-item">
      <span class="pdp-variants__label control-label">{$group.name}</span>
      {if $group.group_type == 'select'}
        <select
          class="pdp-variants__select"
          id="group_{$id_attribute_group}"
          aria-label="{$group.name}"
          data-product-attribute="{$id_attribute_group}"
          name="group[{$id_attribute_group}]">
          {foreach from=$group.attributes key=id_attribute item=group_attribute}
            <option value="{$id_attribute}" title="{$group_attribute.name}"{if $group_attribute.selected} selected="selected"{/if}>{$group_attribute.name}</option>
          {/foreach}
        </select>
      {elseif $group.group_type == 'color'}
        <ul class="pdp-variants__list pdp-variants__list--color" id="group_{$id_attribute_group}" data-pdp-color-list>
          {foreach from=$group.attributes key=id_attribute item=group_attribute name=color_attrs}
            <li class="pdp-variants__list-item input-container{if $smarty.foreach.color_attrs.iteration > 8} pdp-variants__list-item--overflow{/if}"{if $smarty.foreach.color_attrs.iteration > 8} data-overflow-color="true"{/if}{if !empty($group_attribute.tc_attribute_photo_url)} data-tc-attribute-photo-url="{$group_attribute.tc_attribute_photo_url|escape:'html':'UTF-8'}"{/if}>
              <label aria-label="{$group_attribute.name}">
                <input class="pdp-variants__input input-color" type="radio" data-product-attribute="{$id_attribute_group}" name="group[{$id_attribute_group}]" value="{$id_attribute}" title="{$group_attribute.name}"{if $group_attribute.selected} checked="checked"{/if}>
                <span
                  {if $group_attribute.texture}
                    class="pdp-variants__swatch color texture" style="background-image: url({$group_attribute.texture})"
                  {elseif $group_attribute.html_color_code}
                    class="pdp-variants__swatch color" style="background-color: {$group_attribute.html_color_code}"
                  {/if}
                ><span class="attribute-name sr-only">{$group_attribute.name}</span></span>
              </label>
            </li>
          {/foreach}
          {if $group.attributes|@count > 8}
            <li class="pdp-variants__list-item pdp-variants__list-item--more">
              <button
                type="button"
                class="pdp-variants__more-btn"
                data-pdp-color-toggle
                data-expand-label="{l s='Show more colors' d='Shop.Theme.Catalog'}"
                data-collapse-label="{l s='Show fewer colors' d='Shop.Theme.Catalog'}"
                aria-expanded="false"
                aria-controls="group_{$id_attribute_group}"
                aria-label="{l s='Show more colors' d='Shop.Theme.Catalog'}"
              >
                <span class="pdp-variants__more-icon" aria-hidden="true">+</span>
              </button>
            </li>
          {/if}
        </ul>
      {elseif $group.group_type == 'radio'}
        <ul class="pdp-variants__list pdp-variants__list--radio" id="group_{$id_attribute_group}">
          {foreach from=$group.attributes key=id_attribute item=group_attribute}
            <li class="pdp-variants__list-item input-container"{if !empty($group_attribute.tc_attribute_photo_url)} data-tc-attribute-photo-url="{$group_attribute.tc_attribute_photo_url|escape:'html':'UTF-8'}"{/if}>
              <label>
                <input class="pdp-variants__input input-radio" type="radio" data-product-attribute="{$id_attribute_group}" name="group[{$id_attribute_group}]" value="{$id_attribute}" title="{$group_attribute.name}"{if $group_attribute.selected} checked="checked"{/if}>
                <span class="pdp-variants__radio-label radio-label">{$group_attribute.name}</span>
              </label>
            </li>
          {/foreach}
        </ul>
      {/if}
    </div>
    {/if}
  {/foreach}
</div>
