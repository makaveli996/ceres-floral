<?php
/**
 * Purpose: Dynamic footer logos module with two repeaters (payments and delivery).
 * Used from: widget call in theme footer.tpl (`{widget name='tc_footerlogos'}`).
 * Inputs: BO repeater rows with image upload + alt text for two groups.
 * Outputs: Footer logos markup in views/templates/hook/displayFooter.tpl.
 * Side effects: Uploads files into views/img/uploads/, stores JSON in Configuration.
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

use PrestaShop\PrestaShop\Core\Module\WidgetInterface;

class Tc_footerlogos extends Module implements WidgetInterface
{
    private const CONF_PAYMENT_LOGOS = 'TC_FOOTERLOGOS_PAYMENT_LOGOS';
    private const CONF_DELIVERY_LOGOS = 'TC_FOOTERLOGOS_DELIVERY_LOGOS';

    public function __construct()
    {
        $this->name = 'tc_footerlogos';
        $this->tab = 'front_office_features';
        $this->version = '1.0.0';
        $this->author = 'Rafal Majdan';
        $this->need_instance = 0;
        $this->bootstrap = true;
        $this->ps_versions_compliancy = ['min' => '8.0.0', 'max' => _PS_VERSION_];

        parent::__construct();

        $this->displayName = $this->trans(
            'Stopka — logotypy płatności i dostawy',
            [],
            'Modules.Tc_footerlogos.Admin'
        );
        $this->description = $this->trans(
            'Zarządza dwiema listami logotypów w stopce: płatności i dostawa.',
            [],
            'Modules.Tc_footerlogos.Admin'
        );
    }

    public function install(): bool
    {
        return parent::install()
            && $this->registerHook('displayFooter')
            && Configuration::updateValue(self::CONF_PAYMENT_LOGOS, json_encode([]))
            && Configuration::updateValue(self::CONF_DELIVERY_LOGOS, json_encode([]));
    }

    public function uninstall(): bool
    {
        $this->deleteAllUploadedLogos();

        return Configuration::deleteByName(self::CONF_PAYMENT_LOGOS)
            && Configuration::deleteByName(self::CONF_DELIVERY_LOGOS)
            && parent::uninstall();
    }

    public function getContent(): string
    {
        $output = '';

        if (Tools::isSubmit('submitTcFooterLogos')) {
            $result = $this->processConfigurationForm();
            if (true === $result) {
                $output .= $this->displayConfirmation(
                    $this->trans('Ustawienia zostały zapisane.', [], 'Modules.Tc_footerlogos.Admin')
                );
            } else {
                $output .= $this->displayError($result);
            }
        }

        $this->context->controller->addCSS($this->_path . 'views/css/admin.css');
        $this->context->controller->addJS($this->_path . 'views/js/admin.js');

        $this->context->smarty->assign([
            'form_action' => AdminController::$currentIndex
                . '&configure=' . $this->name
                . '&token=' . Tools::getAdminTokenLite('AdminModules'),
            'payment_logos' => $this->getStoredLogos(self::CONF_PAYMENT_LOGOS),
            'delivery_logos' => $this->getStoredLogos(self::CONF_DELIVERY_LOGOS),
        ]);

        return $output . $this->display(__FILE__, 'views/templates/admin/configure.tpl');
    }

    public function hookDisplayFooter(array $params): string
    {
        return $this->renderWidget('displayFooter', $params);
    }

    public function renderWidget($hookName = null, array $configuration = []): string
    {
        $this->smarty->assign($this->getWidgetVariables($hookName, $configuration));

        return $this->fetch('module:tc_footerlogos/views/templates/hook/displayFooter.tpl');
    }

    public function getWidgetVariables($hookName = null, array $configuration = []): array
    {
        return [
            'tc_footerlogos_payment_logos' => $this->getStoredLogos(self::CONF_PAYMENT_LOGOS),
            'tc_footerlogos_delivery_logos' => $this->getStoredLogos(self::CONF_DELIVERY_LOGOS),
        ];
    }

    /**
     * @return true|string
     */
    private function processConfigurationForm()
    {
        $paymentsInput = Tools::getValue('payment_logos', []);
        $deliveriesInput = Tools::getValue('delivery_logos', []);

        $savedPayments = $this->saveGroupLogos(
            is_array($paymentsInput) ? $paymentsInput : [],
            'payment_logo',
            'payment'
        );
        if (!is_array($savedPayments)) {
            return $savedPayments;
        }

        $savedDeliveries = $this->saveGroupLogos(
            is_array($deliveriesInput) ? $deliveriesInput : [],
            'delivery_logo',
            'delivery'
        );
        if (!is_array($savedDeliveries)) {
            return $savedDeliveries;
        }

        $ok = Configuration::updateValue(self::CONF_PAYMENT_LOGOS, json_encode($savedPayments))
            && Configuration::updateValue(self::CONF_DELIVERY_LOGOS, json_encode($savedDeliveries));

        if (!$ok) {
            return $this->trans('Nie udało się zapisać ustawień.', [], 'Modules.Tc_footerlogos.Admin');
        }

        return true;
    }

    /**
     * @return array<int, array{image:string,alt:string}>|string
     */
    private function saveGroupLogos(array $rows, string $fileFieldPrefix, string $groupKey)
    {
        $saved = [];

        foreach ($rows as $i => $row) {
            $index = (int) $i;
            if (!is_array($row)) {
                continue;
            }

            $keepImage = trim((string) ($row['image_keep'] ?? ''));
            $alt = trim((string) ($row['alt'] ?? ''));

            $uploaded = $this->uploadLogo($fileFieldPrefix, $index, $groupKey);
            if (false === $uploaded) {
                return $this->trans(
                    'Błąd uploadu pliku dla pozycji %d.',
                    [$index + 1],
                    'Modules.Tc_footerlogos.Admin'
                );
            }

            $image = $uploaded ?: $keepImage;
            if ('' === $image) {
                continue;
            }

            $saved[] = [
                'image' => $image,
                'alt' => $alt,
            ];
        }

        return $saved;
    }

    /**
     * @return string|false
     */
    private function uploadLogo(string $fieldPrefix, int $index, string $groupKey)
    {
        if (
            !isset($_FILES[$fieldPrefix]['name'][$index])
            || '' === $_FILES[$fieldPrefix]['name'][$index]
        ) {
            return '';
        }

        if ((int) $_FILES[$fieldPrefix]['error'][$index] !== UPLOAD_ERR_OK) {
            return false;
        }

        $file = [
            'name' => $_FILES[$fieldPrefix]['name'][$index],
            'type' => $_FILES[$fieldPrefix]['type'][$index],
            'tmp_name' => $_FILES[$fieldPrefix]['tmp_name'][$index],
            'error' => $_FILES[$fieldPrefix]['error'][$index],
            'size' => $_FILES[$fieldPrefix]['size'][$index],
        ];

        $validationError = ImageManager::validateUpload($file, 8000000);
        if ($validationError) {
            return false;
        }

        $extension = strtolower((string) pathinfo($file['name'], PATHINFO_EXTENSION));
        $filename = $groupKey . '-' . sha1(uniqid((string) mt_rand(), true)) . '.' . $extension;
        $destination = _PS_MODULE_DIR_ . $this->name . '/views/img/uploads/' . $filename;

        if (!move_uploaded_file($file['tmp_name'], $destination)) {
            return false;
        }

        return $this->_path . 'views/img/uploads/' . $filename;
    }

    /**
     * @return array<int, array{image:string,alt:string}>
     */
    private function getStoredLogos(string $configKey): array
    {
        $raw = Configuration::get($configKey);
        $decoded = json_decode((string) $raw, true);

        if (!is_array($decoded)) {
            return [];
        }

        $items = [];
        foreach ($decoded as $item) {
            $image = (string) ($item['image'] ?? '');
            if ('' === $image) {
                continue;
            }

            $items[] = [
                'image' => $image,
                'alt' => (string) ($item['alt'] ?? ''),
            ];
        }

        return $items;
    }

    private function deleteAllUploadedLogos(): void
    {
        $dir = _PS_MODULE_DIR_ . $this->name . '/views/img/uploads/';
        if (!is_dir($dir)) {
            return;
        }

        foreach (glob($dir . '*') ?: [] as $file) {
            if (is_file($file)) {
                @unlink($file);
            }
        }
    }
}
