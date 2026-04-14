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
{extends file='page.tpl'}

{block name='page_title'}
  {$cms.meta_title}
{/block}

{block name='page_content_container'}
  <section id="content" class="page-cms page-cms-{$cms.id}">

    {block name='hook_cms_page_specific'}
      {if isset($id_cms_about_us) && $cms.id == $id_cms_about_us}
        {hook h='displayAboutUs'}
      {/if}
      {if isset($id_cms_catalogue) && $cms.id == $id_cms_catalogue}
        {hook h='displayCatalogue'}
      {/if}
      {if isset($id_cms_designer_zone) && $cms.id == $id_cms_designer_zone}
        {hook h='displayDesignerZone'}
      {/if}
      {if isset($id_cms_colours) && $cms.id == $id_cms_colours}
        {hook h='displayColours'}
      {/if}
      {if isset($id_cms_catalogues) && $cms.id == $id_cms_catalogues}
        {hook h='displayCatalogues'}
      {/if}
      {if isset($id_cms_configurator) && $cms.id == $id_cms_configurator}
        {hook h='displayConfigurator'}
        <div class="container-lg">
          <div class="page-cms__2-cols">
            <div class="page-cms__col-left">
              <div class="page-cms__col-left-inner">
                {hook h='displayConfiguratorLeft'}
              </div>
            </div>
            <div class="page-cms__col-right">
              {hook h='displayConfiguratorRight'}
            </div>
          </div>
        </div>
        {hook h='displayConfiguratorAfter'}
      {/if}
    {/block}

    {block name='hook_cms_dispute_information'}
      {hook h='displayCMSDisputeInformation'}
    {/block}

    {block name='hook_cms_print_button'}
      {hook h='displayCMSPrintButton'}
    {/block}

  </section>
{/block}
