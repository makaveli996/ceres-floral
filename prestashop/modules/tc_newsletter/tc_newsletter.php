<?php
/**
 * Purpose: Configuration module for the newsletter section — stores the decorative image shown on the right.
 * Used from: getContent() (BO config), hookActionFrontControllerSetMedia (assigns $tc_newsletter_image to Smarty).
 * Inputs: Image file upload via BO form.
 * Outputs: Configuration::get('TC_NEWSLETTER_IMAGE') — URL of the uploaded image.
 * Side effects: Image saved to views/img/uploads/; value persisted in ps_configuration table.
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

class Tc_newsletter extends Module
{
    private const CONF_IMAGE = 'TC_NEWSLETTER_IMAGE';

    public function __construct()
    {
        $this->name = 'tc_newsletter';
        $this->tab = 'front_office_features';
        $this->version = '1.0.0';
        $this->author = 'Rafal Majdan';
        $this->need_instance = 0;
        $this->bootstrap = true;
        $this->ps_versions_compliancy = ['min' => '8.0.0', 'max' => _PS_VERSION_];

        parent::__construct();

        $this->displayName = $this->trans('Newsletter — konfiguracja sekcji', [], 'Modules.Tc_newsletter.Admin');
        $this->description = $this->trans('Panel konfiguracji sekcji newsletter: wgrywanie obrazka dekoracyjnego wyświetlanego po prawej stronie.', [], 'Modules.Tc_newsletter.Admin');
    }

    public function install(): bool
    {
        return parent::install()
            && $this->registerHook('actionFrontControllerSetMedia')
            && Configuration::updateValue(self::CONF_IMAGE, '');
    }

    public function uninstall(): bool
    {
        Configuration::deleteByName(self::CONF_IMAGE);

        return parent::uninstall();
    }

    public function getContent(): string
    {
        $output = '';

        if (Tools::isSubmit('submitTcNewsletter')) {
            if ($this->processForm()) {
                $output .= $this->displayConfirmation(
                    $this->trans('Ustawienia zostały zapisane.', [], 'Modules.Tc_newsletter.Admin')
                );
            } else {
                $output .= $this->displayError(
                    $this->trans('Nie udało się zapisać ustawień.', [], 'Modules.Tc_newsletter.Admin')
                );
            }
        }

        $this->context->smarty->assign([
            'form_action' => AdminController::$currentIndex . '&configure=' . $this->name . '&token=' . Tools::getAdminTokenLite('AdminModules'),
            'image_url'   => Configuration::get(self::CONF_IMAGE),
        ]);

        return $output . $this->display(__FILE__, 'views/templates/admin/configure.tpl');
    }

    public function hookActionFrontControllerSetMedia(): void
    {
        $this->context->smarty->assign(
            'tc_newsletter_image',
            Configuration::get(self::CONF_IMAGE) ?: ''
        );
    }

    private function processForm(): bool
    {
        $uploaded = $this->uploadImage('newsletter_image');

        if (false === $uploaded) {
            return false;
        }

        $path = $uploaded ?: (string) Tools::getValue('newsletter_image_keep', '');

        return (bool) Configuration::updateValue(self::CONF_IMAGE, $path);
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
}
