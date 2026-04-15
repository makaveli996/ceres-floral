<?php
/**
 * Global WebP image delivery for PrestaShop.
 *
 * Serves WebP when the browser sends Accept: image/webp by converting on-the-fly
 * (or from cache). Covers product/category images (img/) and module uploads
 * (e.g. ps_imageslider, ps_banner) when Apache is configured to rewrite requests.
 *
 * Used by: Apache rewrite rules (see config/htaccess-webp.conf), no hooks.
 * Side effects: writes WebP cache under var/cache/webp/, reads source images.
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

class Ps_Webp extends Module
{
    const CONFIG_QUALITY = 'PS_WEBP_QUALITY';
    const CONFIG_ENABLED = 'PS_WEBP_ENABLED';
    const CONFIG_CACHE_ENABLED = 'PS_WEBP_CACHE_ENABLED';

    public function __construct()
    {
        $this->name = 'ps_webp';
        $this->tab = 'administration';
        $this->version = '1.0.0';
        $this->author = 'Meblowosk';
        $this->need_instance = 0;
        $this->bootstrap = true;
        parent::__construct();

        $this->displayName = $this->trans('Global WebP delivery', [], 'Modules.Ps_webp.Admin');
        $this->description = $this->trans('Serves images as WebP when the browser supports it (product images, module uploads). Requires Apache rewrite configuration.', [], 'Modules.Ps_webp.Admin');
        $this->ps_versions_compliancy = ['min' => '1.7.7.0', 'max' => _PS_VERSION_];
    }

    public function install()
    {
        $ok = parent::install()
            && Configuration::updateValue(self::CONFIG_ENABLED, 1)
            && Configuration::updateValue(self::CONFIG_QUALITY, 82)
            && Configuration::updateValue(self::CONFIG_CACHE_ENABLED, 1);
        if ($ok) {
            $this->writeWebpConfig(82, true);
        }
        return $ok;
    }

    public function uninstall()
    {
        return Configuration::deleteByName(self::CONFIG_ENABLED)
            && Configuration::deleteByName(self::CONFIG_QUALITY)
            && Configuration::deleteByName(self::CONFIG_CACHE_ENABLED)
            && parent::uninstall();
    }

    public function getContent()
    {
        $output = '';
        if (Tools::isSubmit('submitPs_webp')) {
            $quality = (int) Tools::getValue(self::CONFIG_QUALITY);
            if ($quality < 1 || $quality > 100) {
                $quality = 82;
            }
            Configuration::updateValue(self::CONFIG_QUALITY, $quality);
            Configuration::updateValue(self::CONFIG_ENABLED, (bool) Tools::getValue(self::CONFIG_ENABLED));
            Configuration::updateValue(self::CONFIG_CACHE_ENABLED, (bool) Tools::getValue(self::CONFIG_CACHE_ENABLED));
            $this->writeWebpConfig($quality, (bool) Configuration::get(self::CONFIG_CACHE_ENABLED));
            $output .= $this->displayConfirmation($this->trans('Settings updated.', [], 'Admin.Notifications.Success'));
        }

        $output .= $this->renderForm();
        $output .= $this->renderHtaccessInstructions();

        return $output;
    }

    protected function renderForm()
    {
        $fields = [
            'form' => [
                'legend' => [
                    'title' => $this->trans('WebP delivery settings', [], 'Modules.Ps_webp.Admin'),
                    'icon' => 'icon-cog',
                ],
                'input' => [
                    [
                        'type' => 'switch',
                        'label' => $this->trans('Enable WebP delivery', [], 'Modules.Ps_webp.Admin'),
                        'name' => self::CONFIG_ENABLED,
                        'is_bool' => true,
                        'values' => [
                            ['id' => 'active_on', 'value' => 1, 'label' => $this->trans('Yes', [], 'Admin.Global')],
                            ['id' => 'active_off', 'value' => 0, 'label' => $this->trans('No', [], 'Admin.Global')],
                        ],
                    ],
                    [
                        'type' => 'text',
                        'label' => $this->trans('WebP quality (1–100)', [], 'Modules.Ps_webp.Admin'),
                        'name' => self::CONFIG_QUALITY,
                        'size' => 3,
                    ],
                    [
                        'type' => 'switch',
                        'label' => $this->trans('Cache converted WebP files', [], 'Modules.Ps_webp.Admin'),
                        'name' => self::CONFIG_CACHE_ENABLED,
                        'is_bool' => true,
                        'values' => [
                            ['id' => 'cache_on', 'value' => 1, 'label' => $this->trans('Yes', [], 'Admin.Global')],
                            ['id' => 'cache_off', 'value' => 0, 'label' => $this->trans('No', [], 'Admin.Global')],
                        ],
                    ],
                ],
                'submit' => [
                    'title' => $this->trans('Save', [], 'Admin.Actions'),
                    'name' => 'submitPs_webp',
                ],
            ],
        ];

        $helper = new HelperForm();
        $helper->show_toolbar = false;
        $helper->table = $this->table;
        $helper->default_form_language = (int) Configuration::get('PS_LANG_DEFAULT');
        $helper->submit_action = 'submitPs_webp';
        $helper->currentIndex = $this->context->link->getAdminLink('AdminModules', true) . '&configure=' . $this->name;
        $helper->token = Tools::getAdminTokenLite('AdminModules');
        $helper->tpl_vars = [
            'fields_value' => [
                self::CONFIG_ENABLED => (bool) Configuration::get(self::CONFIG_ENABLED),
                self::CONFIG_QUALITY => (int) Configuration::get(self::CONFIG_QUALITY),
                self::CONFIG_CACHE_ENABLED => (bool) Configuration::get(self::CONFIG_CACHE_ENABLED),
            ],
        ];

        return $helper->generateForm([$fields]);
    }

    protected function writeWebpConfig($quality, $cacheEnabled)
    {
        $configDir = $this->getLocalPath() . 'config';
        if (!is_dir($configDir)) {
            @mkdir($configDir, 0755, true);
        }
        $file = $configDir . '/webp_config.json';
        @file_put_contents($file, json_encode([
            'quality' => $quality,
            'cache_enabled' => $cacheEnabled,
        ]));
    }

    protected function renderHtaccessInstructions()
    {
        $rulesBlock = '# WebP delivery (ps_webp): serve WebP when browser sends Accept: image/webp
RewriteCond %{HTTP:Accept} image/webp
RewriteCond %{REQUEST_URI} \.(jpe?g|png|gif)$ [NC]
RewriteCond %{REQUEST_URI} ^/(img/|modules/.+/(img|images)/) [NC]
RewriteRule ^(img/|modules/).+\.(jpe?g|png|gif)$ %{ENV:REWRITEBASE}modules/ps_webp/webp.php [L]';

        return '<div class="panel"><h3>' . $this->trans('Apache configuration', [], 'Modules.Ps_webp.Admin') . '</h3>'
            . '<p>' . $this->trans('WebP is enabled by rules inlined in your shop\'s .htaccess (right after the line that sets REWRITEBASE).', [], 'Modules.Ps_webp.Admin') . '</p>'
            . '<p>' . $this->trans('If PrestaShop regenerates .htaccess, re-add the following block in the same place (after RewriteRule . - [E=REWRITEBASE:/]):', [], 'Modules.Ps_webp.Admin') . '</p>'
            . '<pre>' . htmlspecialchars($rulesBlock, ENT_QUOTES, 'UTF-8') . '</pre></div>';
    }
}
