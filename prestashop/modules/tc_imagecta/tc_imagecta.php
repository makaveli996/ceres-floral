<?php
/**
 * Purpose: Renders image+CTA content section on the homepage.
 * Used from: displayHome hook → views/templates/hook/displayHome.tpl.
 * Inputs: title, description, button label/URL, 6 image uploads (3 left + 3 right).
 * Outputs: Section HTML with container-md, background --clr-gray-2.
 * Side effects: Image uploads saved to views/img/uploads/; config stored in Configuration.
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

use PrestaShop\PrestaShop\Core\Module\WidgetInterface;

class Tc_imagecta extends Module implements WidgetInterface
{
    private const CONF_TITLE          = 'TC_IMAGECTA_TITLE';
    private const CONF_DESC           = 'TC_IMAGECTA_DESC';
    private const CONF_BTN_LABEL      = 'TC_IMAGECTA_BTN_LABEL';
    private const CONF_BTN_URL        = 'TC_IMAGECTA_BTN_URL';
    private const CONF_IMG_LEFT_BIG   = 'TC_IMAGECTA_IMG_LEFT_BIG';
    private const CONF_IMG_LEFT_SMALL = 'TC_IMAGECTA_IMG_LEFT_SMALL';
    private const CONF_IMG_LEFT_MED   = 'TC_IMAGECTA_IMG_LEFT_MED';
    private const CONF_IMG_RIGHT_BIG  = 'TC_IMAGECTA_IMG_RIGHT_BIG';
    private const CONF_IMG_RIGHT_SMALL = 'TC_IMAGECTA_IMG_RIGHT_SMALL';
    private const CONF_IMG_RIGHT_MED  = 'TC_IMAGECTA_IMG_RIGHT_MED';

    public function __construct()
    {
        $this->name = 'tc_imagecta';
        $this->tab = 'front_office_features';
        $this->version = '1.0.0';
        $this->author = 'Rafal Majdan';
        $this->need_instance = 0;
        $this->bootstrap = true;
        $this->ps_versions_compliancy = ['min' => '8.0.0', 'max' => _PS_VERSION_];

        parent::__construct();

        $this->displayName = $this->trans('Image CTA — sekcja z obrazkami i przyciskiem', [], 'Modules.Tc_imagecta.Admin');
        $this->description = $this->trans('Blok contentowy: nagłówek, opis, przycisk CTA oraz mozaika trzech obrazków po lewej i prawej stronie.', [], 'Modules.Tc_imagecta.Admin');
    }

    public function install()
    {
        return parent::install()
            && $this->registerHook('displayHome')
            && Configuration::updateValue(self::CONF_TITLE, 'Szukaj indywidualnego produktu?')
            && Configuration::updateValue(self::CONF_DESC, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.')
            && Configuration::updateValue(self::CONF_BTN_LABEL, 'Zobacz pełną ofertę')
            && Configuration::updateValue(self::CONF_BTN_URL, '#')
            && Configuration::updateValue(self::CONF_IMG_LEFT_BIG, '')
            && Configuration::updateValue(self::CONF_IMG_LEFT_SMALL, '')
            && Configuration::updateValue(self::CONF_IMG_LEFT_MED, '')
            && Configuration::updateValue(self::CONF_IMG_RIGHT_BIG, '')
            && Configuration::updateValue(self::CONF_IMG_RIGHT_SMALL, '')
            && Configuration::updateValue(self::CONF_IMG_RIGHT_MED, '');
    }

    public function uninstall()
    {
        foreach ([
            self::CONF_TITLE, self::CONF_DESC,
            self::CONF_BTN_LABEL, self::CONF_BTN_URL,
            self::CONF_IMG_LEFT_BIG, self::CONF_IMG_LEFT_SMALL, self::CONF_IMG_LEFT_MED,
            self::CONF_IMG_RIGHT_BIG, self::CONF_IMG_RIGHT_SMALL, self::CONF_IMG_RIGHT_MED,
        ] as $key) {
            Configuration::deleteByName($key);
        }

        return parent::uninstall();
    }

    public function getContent()
    {
        $output = '';

        if (Tools::isSubmit('submitTcImageCta')) {
            if ($this->processForm()) {
                $output .= $this->displayConfirmation(
                    $this->trans('Ustawienia zostały zapisane.', [], 'Modules.Tc_imagecta.Admin')
                );
            } else {
                $output .= $this->displayError(
                    $this->trans('Nie udało się zapisać ustawień.', [], 'Modules.Tc_imagecta.Admin')
                );
            }
        }

        $this->context->smarty->assign([
            'form_action' => AdminController::$currentIndex . '&configure=' . $this->name . '&token=' . Tools::getAdminTokenLite('AdminModules'),
            'conf'        => $this->getConfig(),
        ]);

        return $output . $this->display(__FILE__, 'views/templates/admin/configure.tpl');
    }

    public function hookDisplayHome($params)
    {
        return $this->renderWidget('displayHome', $params);
    }

    public function renderWidget($hookName, array $configuration)
    {
        $this->smarty->assign($this->getWidgetVariables($hookName, $configuration));

        return $this->fetch('module:tc_imagecta/views/templates/hook/displayHome.tpl');
    }

    public function getWidgetVariables($hookName, array $configuration)
    {
        return $this->getConfig();
    }

    private function getConfig(): array
    {
        return [
            'title'           => Configuration::get(self::CONF_TITLE),
            'description'     => Configuration::get(self::CONF_DESC),
            'btn_label'       => Configuration::get(self::CONF_BTN_LABEL),
            'btn_url'         => Configuration::get(self::CONF_BTN_URL),
            'img_left_big'    => Configuration::get(self::CONF_IMG_LEFT_BIG),
            'img_left_small'  => Configuration::get(self::CONF_IMG_LEFT_SMALL),
            'img_left_med'    => Configuration::get(self::CONF_IMG_LEFT_MED),
            'img_right_big'   => Configuration::get(self::CONF_IMG_RIGHT_BIG),
            'img_right_small' => Configuration::get(self::CONF_IMG_RIGHT_SMALL),
            'img_right_med'   => Configuration::get(self::CONF_IMG_RIGHT_MED),
        ];
    }

    private function processForm(): bool
    {
        $ok = true;

        $ok = Configuration::updateValue(self::CONF_TITLE,     Tools::getValue('title', '')) && $ok;
        $ok = Configuration::updateValue(self::CONF_DESC,      Tools::getValue('description', '')) && $ok;
        $ok = Configuration::updateValue(self::CONF_BTN_LABEL, Tools::getValue('btn_label', '')) && $ok;
        $ok = Configuration::updateValue(self::CONF_BTN_URL,   $this->sanitizeUrl((string) Tools::getValue('btn_url', ''))) && $ok;

        foreach ([
            'img_left_big'    => self::CONF_IMG_LEFT_BIG,
            'img_left_small'  => self::CONF_IMG_LEFT_SMALL,
            'img_left_med'    => self::CONF_IMG_LEFT_MED,
            'img_right_big'   => self::CONF_IMG_RIGHT_BIG,
            'img_right_small' => self::CONF_IMG_RIGHT_SMALL,
            'img_right_med'   => self::CONF_IMG_RIGHT_MED,
        ] as $field => $confKey) {
            $uploaded = $this->uploadImage($field);
            if (false === $uploaded) {
                $ok = false;
                continue;
            }
            $path = $uploaded ?: (string) Tools::getValue($field . '_keep', '');
            $ok = Configuration::updateValue($confKey, $path) && $ok;
        }

        return $ok;
    }

    private function uploadImage(string $field): string|false
    {
        if (empty($_FILES[$field]['name'])) {
            return '';
        }

        if (UPLOAD_ERR_OK !== (int) $_FILES[$field]['error']) {
            return false;
        }

        $validationError = ImageManager::validateUpload($_FILES[$field], 8000000);
        if ($validationError) {
            return false;
        }

        $ext      = strtolower((string) pathinfo($_FILES[$field]['name'], PATHINFO_EXTENSION));
        $filename = $field . '-' . sha1(uniqid((string) mt_rand(), true)) . '.' . $ext;
        $dest     = _PS_MODULE_DIR_ . $this->name . '/views/img/uploads/' . $filename;

        if (!move_uploaded_file($_FILES[$field]['tmp_name'], $dest)) {
            return false;
        }

        return $this->_path . 'views/img/uploads/' . $filename;
    }

    private function sanitizeUrl(string $url): string
    {
        if ('' === $url) {
            return '#';
        }

        if (Validate::isAbsoluteUrl($url) || str_starts_with($url, '/')) {
            return $url;
        }

        return '#';
    }
}
