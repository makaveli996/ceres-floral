<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

use PrestaShop\PrestaShop\Core\Module\WidgetInterface;

class Tc_homepromoslider extends Module implements WidgetInterface
{
    private const CONF_SLIDES = 'TC_HPS_SLIDES';
    private const CONF_LIST_TITLE = 'TC_HPS_LIST_TITLE';
    private const CONF_LIST_ITEMS = 'TC_HPS_LIST_ITEMS';

    public function __construct()
    {
        $this->name = 'tc_homepromoslider';
        $this->tab = 'front_office_features';
        $this->version = '1.0.0';
        $this->author = 'Rafal Majdan';
        $this->need_instance = 0;
        $this->bootstrap = true;
        $this->ps_versions_compliancy = ['min' => '8.0.0', 'max' => _PS_VERSION_];

        parent::__construct();

        $this->displayName = $this->trans('Slider promocyjny Home', [], 'Modules.Tc_homepromoslider.Admin');
        $this->description = $this->trans('Slider hero z listą benefitów na stronie głównej.', [], 'Modules.Tc_homepromoslider.Admin');
    }

    public function install()
    {
        return parent::install()
            && $this->registerHook('displayHome')
            && Configuration::updateValue(self::CONF_SLIDES, json_encode($this->getDefaultSlides()))
            && Configuration::updateValue(self::CONF_LIST_TITLE, 'Dlaczego Ceres Floral')
            && Configuration::updateValue(self::CONF_LIST_ITEMS, json_encode($this->getDefaultListItems()));
    }

    public function uninstall()
    {
        return Configuration::deleteByName(self::CONF_SLIDES)
            && Configuration::deleteByName(self::CONF_LIST_TITLE)
            && Configuration::deleteByName(self::CONF_LIST_ITEMS)
            && parent::uninstall();
    }

    public function getContent()
    {
        $output = '';

        if (Tools::isSubmit('submitTcHomePromoSlider')) {
            if ($this->processConfigurationForm()) {
                $output .= $this->displayConfirmation($this->trans('Ustawienia zostały zapisane.', [], 'Modules.Tc_homepromoslider.Admin'));
            } else {
                $output .= $this->displayError($this->trans('Nie udało się zapisać ustawień.', [], 'Modules.Tc_homepromoslider.Admin'));
            }
        }

        $this->context->controller->addCSS($this->_path . 'views/css/admin.css');
        $this->context->controller->addJS($this->_path . 'views/js/admin.js');

        $this->context->smarty->assign([
            'form_action' => AdminController::$currentIndex . '&configure=' . $this->name . '&token=' . Tools::getAdminTokenLite('AdminModules'),
            'slides' => $this->getSlidesConfig(),
            'list_title' => Configuration::get(self::CONF_LIST_TITLE),
            'list_items' => $this->getListItemsConfig(),
        ]);

        return $output . $this->display(__FILE__, 'views/templates/admin/configure.tpl');
    }

    public function hookDisplayHome($params)
    {
        return $this->renderWidget('displayHome', $params);
    }

    public function renderWidget($hookName, array $configuration)
    {
        $slides = $this->getSlidesConfig();
        if (empty($slides)) {
            return '';
        }

        $this->smarty->assign($this->getWidgetVariables($hookName, $configuration));

        return $this->fetch('module:' . $this->name . '/views/templates/hook/displayHome.tpl');
    }

    public function getWidgetVariables($hookName, array $configuration)
    {
        return [
            'slides' => $this->getSlidesConfig(),
            'list_title' => Configuration::get(self::CONF_LIST_TITLE),
            'list_items' => $this->getListItemsConfig(),
        ];
    }

    private function processConfigurationForm()
    {
        $slidesInput = Tools::getValue('slides', []);
        $listItemsInput = Tools::getValue('list_items', []);
        $listTitle = trim((string) Tools::getValue('list_title', ''));
        $storedSlides = $this->getSlidesConfig();
        $defaultSlide = $this->getDefaultSlides()[0];

        $slides = [];
        if (is_array($slidesInput)) {
            foreach ($slidesInput as $index => $slideInput) {
                if (!is_array($slideInput)) {
                    continue;
                }

                $baseSlide = $storedSlides[$index] ?? $defaultSlide;
                $buttonUrl = trim((string) ($slideInput['button_url'] ?? ''));
                $currentImage = trim((string) ($slideInput['current_image'] ?? ''));

                $uploadedImage = $this->uploadSlideImage((string) $index);
                if (false === $uploadedImage) {
                    return false;
                }
                $image = $uploadedImage ?: $currentImage;

                if ('' === $buttonUrl && '' === $image) {
                    continue;
                }

                $slides[] = [
                    'title' => (string) ($baseSlide['title'] ?? $defaultSlide['title']),
                    'description' => (string) ($baseSlide['description'] ?? $defaultSlide['description']),
                    'button_label' => (string) ($baseSlide['button_label'] ?? $defaultSlide['button_label']),
                    'button_url' => $this->sanitizeUrl($buttonUrl ?: (string) ($baseSlide['button_url'] ?? '#')),
                    'badge_text' => (string) ($baseSlide['badge_text'] ?? $defaultSlide['badge_text']),
                    'image' => $image ?: (string) ($baseSlide['image'] ?? $defaultSlide['image']),
                ];
            }
        }

        if (empty($slides)) {
            $slides = $this->getDefaultSlides();
        }

        $listItems = [];
        if (is_array($listItemsInput)) {
            foreach ($listItemsInput as $item) {
                $label = trim((string) $item);
                if ('' !== $label) {
                    $listItems[] = $label;
                }
            }
        }
        if (empty($listItems)) {
            $listItems = $this->getDefaultListItems();
        }

        return Configuration::updateValue(self::CONF_SLIDES, json_encode($slides))
            && Configuration::updateValue(self::CONF_LIST_TITLE, $listTitle ?: 'Dlaczego Ceres Floral')
            && Configuration::updateValue(self::CONF_LIST_ITEMS, json_encode($listItems));
    }

    private function uploadSlideImage($index)
    {
        if (
            !isset($_FILES['slides_image']['name']) ||
            !isset($_FILES['slides_image']['name'][$index]) ||
            '' === $_FILES['slides_image']['name'][$index]
        ) {
            return '';
        }

        if (UPLOAD_ERR_OK !== (int) $_FILES['slides_image']['error'][$index]) {
            return false;
        }

        $file = [
            'name' => $_FILES['slides_image']['name'][$index],
            'type' => $_FILES['slides_image']['type'][$index],
            'tmp_name' => $_FILES['slides_image']['tmp_name'][$index],
            'error' => $_FILES['slides_image']['error'][$index],
            'size' => $_FILES['slides_image']['size'][$index],
        ];

        $validationError = ImageManager::validateUpload($file, 8000000);
        if ($validationError) {
            return false;
        }

        $extension = strtolower((string) pathinfo($file['name'], PATHINFO_EXTENSION));
        $filename = 'slide-' . sha1(uniqid((string) mt_rand(), true)) . '.' . $extension;
        $destination = _PS_MODULE_DIR_ . $this->name . '/views/img/uploads/' . $filename;

        if (!move_uploaded_file($file['tmp_name'], $destination)) {
            return false;
        }

        return $this->_path . 'views/img/uploads/' . $filename;
    }

    private function getSlidesConfig()
    {
        $slidesRaw = Configuration::get(self::CONF_SLIDES);
        $slides = json_decode((string) $slidesRaw, true);

        return is_array($slides) && !empty($slides) ? $slides : $this->getDefaultSlides();
    }

    private function getListItemsConfig()
    {
        $itemsRaw = Configuration::get(self::CONF_LIST_ITEMS);
        $items = json_decode((string) $itemsRaw, true);

        return is_array($items) && !empty($items) ? $items : $this->getDefaultListItems();
    }

    private function sanitizeUrl($url)
    {
        if ('' === $url) {
            return '#';
        }

        if (Validate::isAbsoluteUrl($url) || strpos($url, '/') === 0) {
            return $url;
        }

        return '#';
    }

    private function getDefaultSlides()
    {
        return [[
            'title' => 'Wakacyjna promocja',
            'description' => 'Ograniczona promocja na zestawy kwiatów bukietowych',
            'button_label' => 'Zobacz pełną ofertę',
            'button_url' => '#',
            'badge_text' => '-60%',
            'image' => $this->_path . 'views/img/default-slide.png',
        ]];
    }

    private function getDefaultListItems()
    {
        return [
            'Sprawdzone produkty',
            'Bogaty asortyment',
            'Indywidualne ceny',
            'Gwarancja jakości',
        ];
    }
}
