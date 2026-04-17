<?php
/**
 * Purpose: Renders location/showroom section on the homepage.
 * Used from: displayHome hook → views/templates/hook/displayHome.tpl.
 * Inputs: title, images (JSON repeater), address, maps_url, maps_iframe (src URL).
 * Outputs: Section HTML — Google Maps iframe (left) + image slider + address + nav link (right).
 * Side effects: Image uploads saved to views/img/uploads/; config stored in Configuration.
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

use PrestaShop\PrestaShop\Core\Module\WidgetInterface;

class Tc_location extends Module implements WidgetInterface
{
    private const CONF_TITLE       = 'TC_LOCATION_TITLE';
    private const CONF_IMAGES      = 'TC_LOCATION_IMAGES';
    private const CONF_ADDRESS     = 'TC_LOCATION_ADDRESS';
    private const CONF_MAPS_URL    = 'TC_LOCATION_MAPS_URL';
    private const CONF_MAPS_IFRAME = 'TC_LOCATION_MAPS_IFRAME';

    public function __construct()
    {
        $this->name = 'tc_location';
        $this->tab = 'front_office_features';
        $this->version = '1.0.0';
        $this->author = 'Rafal Majdan';
        $this->need_instance = 0;
        $this->bootstrap = true;
        $this->ps_versions_compliancy = ['min' => '8.0.0', 'max' => _PS_VERSION_];

        parent::__construct();

        $this->displayName = $this->trans(
            'Lokalizacja — showroom z mapą i slajderem zdjęć',
            [],
            'Modules.Tc_location.Admin'
        );
        $this->description = $this->trans(
            'Wyświetla sekcję lokalizacji: mapa Google po lewej, slider zdjęć + adres + link do nawigacji po prawej.',
            [],
            'Modules.Tc_location.Admin'
        );
    }

    public function install(): bool
    {
        return parent::install()
            && $this->registerHook('displayHome')
            && Configuration::updateValue(self::CONF_TITLE, 'Odwiedź nasze showroom')
            && Configuration::updateValue(self::CONF_IMAGES, json_encode([]))
            && Configuration::updateValue(self::CONF_ADDRESS, '')
            && Configuration::updateValue(self::CONF_MAPS_URL, '')
            && Configuration::updateValue(self::CONF_MAPS_IFRAME, '');
    }

    public function uninstall(): bool
    {
        $this->deleteAllImages();

        foreach ([
            self::CONF_TITLE,
            self::CONF_IMAGES,
            self::CONF_ADDRESS,
            self::CONF_MAPS_URL,
            self::CONF_MAPS_IFRAME,
        ] as $key) {
            Configuration::deleteByName($key);
        }

        return parent::uninstall();
    }

    /* ── Back-office configuration ── */

    public function getContent(): string
    {
        $output = '';

        if (Tools::isSubmit('submitTcLocation')) {
            $result = $this->processForm();
            if ($result === true) {
                $output .= $this->displayConfirmation(
                    $this->trans('Ustawienia zostały zapisane.', [], 'Modules.Tc_location.Admin')
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
            'conf'        => $this->getConfig(),
            'images'      => $this->getStoredImages(),
        ]);

        return $output . $this->display(__FILE__, 'views/templates/admin/configure.tpl');
    }

    /**
     * Save scalar fields and process image repeater.
     *
     * @return true|string  true on success, error message on failure
     */
    private function processForm()
    {
        $ok = true;

        $ok = Configuration::updateValue(self::CONF_TITLE,   Tools::getValue('title', '')) && $ok;
        $ok = Configuration::updateValue(self::CONF_ADDRESS, Tools::getValue('address', '')) && $ok;
        $ok = Configuration::updateValue(
            self::CONF_MAPS_URL,
            $this->sanitizeUrl((string) Tools::getValue('maps_url', ''))
        ) && $ok;
        $ok = Configuration::updateValue(self::CONF_MAPS_IFRAME, Tools::getValue('maps_iframe', '')) && $ok;

        $rawImages    = Tools::getValue('images', []);
        $storedImages = $this->getStoredImages();
        $saved        = [];

        if (!is_array($rawImages)) {
            $rawImages = [];
        }

        foreach ($rawImages as $i => $img) {
            $index     = (int) $i;
            $keepImage = trim((string) ($img['image_keep'] ?? ''));

            $uploaded = $this->uploadImage($index);
            if ($uploaded === false) {
                return $this->trans(
                    'Błąd uploadu zdjęcia dla pozycji %d.',
                    [$index + 1],
                    'Modules.Tc_location.Admin'
                );
            }

            $image = $uploaded ?: $keepImage;
            if ('' === $image && isset($storedImages[$index]['image'])) {
                $image = $storedImages[$index]['image'];
            }

            $saved[] = [
                'image'    => $image,
                'position' => $index,
            ];
        }

        if (!Configuration::updateValue(self::CONF_IMAGES, json_encode($saved))) {
            $ok = false;
        }

        return $ok ? true : $this->trans('Nie udało się zapisać ustawień.', [], 'Modules.Tc_location.Admin');
    }

    /**
     * Upload a single slide image from the repeater file array.
     *
     * @param int $index Repeater row index
     *
     * @return string|false URL on success, '' if no file, false on upload error
     */
    private function uploadImage(int $index)
    {
        if (
            !isset($_FILES['images_file']['name'][$index])
            || '' === $_FILES['images_file']['name'][$index]
        ) {
            return '';
        }

        if ((int) $_FILES['images_file']['error'][$index] !== UPLOAD_ERR_OK) {
            return false;
        }

        $file = [
            'name'     => $_FILES['images_file']['name'][$index],
            'type'     => $_FILES['images_file']['type'][$index],
            'tmp_name' => $_FILES['images_file']['tmp_name'][$index],
            'error'    => $_FILES['images_file']['error'][$index],
            'size'     => $_FILES['images_file']['size'][$index],
        ];

        $validationError = ImageManager::validateUpload($file, 8000000);
        if ($validationError) {
            return false;
        }

        $extension   = strtolower((string) pathinfo($file['name'], PATHINFO_EXTENSION));
        $filename    = 'slide-' . sha1(uniqid((string) mt_rand(), true)) . '.' . $extension;
        $destination = _PS_MODULE_DIR_ . $this->name . '/views/img/uploads/' . $filename;

        if (!move_uploaded_file($file['tmp_name'], $destination)) {
            return false;
        }

        return $this->_path . 'views/img/uploads/' . $filename;
    }

    /**
     * Decode stored images JSON. Returns array of normalized image arrays.
     *
     * @return array<int, array{image:string,position:int}>
     */
    private function getStoredImages(): array
    {
        $raw  = Configuration::get(self::CONF_IMAGES);
        $data = json_decode((string) $raw, true);

        if (!is_array($data)) {
            return [];
        }

        $images = [];
        foreach ($data as $item) {
            $images[] = [
                'image'    => (string) ($item['image'] ?? ''),
                'position' => (int) ($item['position'] ?? 0),
            ];
        }

        return $images;
    }

    /** Remove all slide images from the module's uploads directory on uninstall. */
    private function deleteAllImages(): void
    {
        $dir = _PS_MODULE_DIR_ . $this->name . '/views/img/uploads/';
        if (!is_dir($dir)) {
            return;
        }

        foreach (glob($dir . 'slide-*') ?: [] as $file) {
            if (is_file($file)) {
                @unlink($file);
            }
        }
    }

    private function getConfig(): array
    {
        return [
            'title'       => Configuration::get(self::CONF_TITLE),
            'address'     => Configuration::get(self::CONF_ADDRESS),
            'maps_url'    => Configuration::get(self::CONF_MAPS_URL),
            'maps_iframe' => Configuration::get(self::CONF_MAPS_IFRAME),
        ];
    }

    private function sanitizeUrl(string $url): string
    {
        if ('' === $url) {
            return '';
        }

        if (Validate::isAbsoluteUrl($url) || str_starts_with($url, '/')) {
            return $url;
        }

        return '';
    }

    /* ── Widget ── */

    public function hookDisplayHome(array $params): string
    {
        return $this->renderWidget('displayHome', $params);
    }

    public function renderWidget($hookName = null, array $configuration = []): string
    {
        $variables = $this->getWidgetVariables($hookName, $configuration);
        $this->smarty->assign($variables);

        return $this->fetch('module:tc_location/views/templates/hook/displayHome.tpl');
    }

    public function getWidgetVariables($hookName = null, array $configuration = []): array
    {
        return array_merge($this->getConfig(), [
            'tc_location_images' => $this->getStoredImages(),
        ]);
    }
}
