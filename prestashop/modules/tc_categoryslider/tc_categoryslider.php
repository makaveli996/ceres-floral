<?php
/**
 * Category Slider module (tc_categoryslider).
 * Displays a repeater of category segments on displayHome.
 * Each segment shows a bg image panel (left) + Splide product slider (right, 3 per page).
 * BO config: TC_CATEGORYSLIDER_SEGMENTS (JSON array of {id_category, image}).
 * FE JS: _dev/js/custom/Sections/CategorySlider.js
 * FE CSS: _dev/css/custom/sections/_category-slider.scss
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

use PrestaShop\PrestaShop\Adapter\Image\ImageRetriever;
use PrestaShop\PrestaShop\Adapter\Product\PriceFormatter;
use PrestaShop\PrestaShop\Adapter\Product\ProductColorsRetriever;
use PrestaShop\PrestaShop\Core\Module\WidgetInterface;

class Tc_Categoryslider extends Module implements WidgetInterface
{
    private const CONF_SEGMENTS = 'TC_CATEGORYSLIDER_SEGMENTS';

    /** @var int Default number of products per category slider */
    private const DEFAULT_NB_PRODUCTS = 12;

    public function __construct()
    {
        $this->name = 'tc_categoryslider';
        $this->tab = 'front_office_features';
        $this->version = '1.0.0';
        $this->author = 'Rafal Majdan';
        $this->need_instance = 0;
        $this->bootstrap = true;
        $this->is_configurable = 1;

        parent::__construct();

        $this->displayName = $this->trans('Slider kategorii', [], 'Modules.Tc_categoryslider.Admin');
        $this->description = $this->trans(
            'Wyświetla repeatera segmentów kategorii na stronie głównej — każdy segment to panel z obrazkiem i slider produktów.',
            [],
            'Modules.Tc_categoryslider.Admin'
        );
        $this->ps_versions_compliancy = ['min' => '8.0.0', 'max' => _PS_VERSION_];
    }

    public function install()
    {
        return parent::install()
            && $this->registerHook('displayHome')
            && Configuration::updateValue(self::CONF_SEGMENTS, json_encode([]));
    }

    public function uninstall()
    {
        $this->deleteAllSegmentImages();
        Configuration::deleteByName(self::CONF_SEGMENTS);

        return parent::uninstall();
    }

    /* ── Back-office configuration ── */

    public function getContent()
    {
        $output = '';

        if (Tools::isSubmit('submitTcCategorySlider')) {
            $result = $this->processConfiguration();
            if ($result === true) {
                $output .= $this->displayConfirmation(
                    $this->trans('Ustawienia zostały zapisane.', [], 'Modules.Tc_categoryslider.Admin')
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
            'segments'   => $this->getStoredSegments(),
            'categories' => $this->getActiveCategoryList(),
        ]);

        return $output . $this->display(__FILE__, 'views/templates/admin/configure.tpl');
    }

    /**
     * Parse POST, validate, upload images, persist JSON.
     *
     * @return true|string  true on success, error message on failure
     */
    private function processConfiguration()
    {
        $rawSegments  = Tools::getValue('segments', []);
        $stored       = $this->getStoredSegments();
        $saved        = [];

        if (!is_array($rawSegments)) {
            $rawSegments = [];
        }

        foreach ($rawSegments as $i => $seg) {
            $index      = (int) $i;
            $idCategory = (int) ($seg['id_category'] ?? 0);
            $keepImage  = trim((string) ($seg['image_keep'] ?? ''));

            $uploaded = $this->uploadSegmentImage($index);
            if ($uploaded === false) {
                return $this->trans(
                    'Błąd uploadu obrazka dla segmentu %d.',
                    [$index + 1],
                    'Modules.Tc_categoryslider.Admin'
                );
            }

            $image = $uploaded ?: $keepImage;

            // Keep existing image if no new one and none stored but old stored exists
            if ('' === $image && isset($stored[$index]['image'])) {
                $image = $stored[$index]['image'];
            }

            $saved[] = [
                'id_category' => $idCategory,
                'image'       => $image,
                'position'    => $index,
            ];
        }

        Configuration::updateValue(self::CONF_SEGMENTS, json_encode($saved));

        return true;
    }

    /**
     * Upload segment background image. Returns URL (relative to PS root) or '' if no file, false on error.
     *
     * @param int $index Repeater row index
     *
     * @return string|false
     */
    private function uploadSegmentImage(int $index)
    {
        if (
            !isset($_FILES['segments_image']['name'][$index])
            || '' === $_FILES['segments_image']['name'][$index]
        ) {
            return '';
        }

        if ((int) $_FILES['segments_image']['error'][$index] !== UPLOAD_ERR_OK) {
            return false;
        }

        $file = [
            'name'     => $_FILES['segments_image']['name'][$index],
            'type'     => $_FILES['segments_image']['type'][$index],
            'tmp_name' => $_FILES['segments_image']['tmp_name'][$index],
            'error'    => $_FILES['segments_image']['error'][$index],
            'size'     => $_FILES['segments_image']['size'][$index],
        ];

        $validationError = ImageManager::validateUpload($file, 8000000);
        if ($validationError) {
            return false;
        }

        $extension   = strtolower((string) pathinfo($file['name'], PATHINFO_EXTENSION));
        $filename    = 'segment-' . sha1(uniqid((string) mt_rand(), true)) . '.' . $extension;
        $destination = _PS_MODULE_DIR_ . $this->name . '/views/img/uploads/' . $filename;

        if (!move_uploaded_file($file['tmp_name'], $destination)) {
            return false;
        }

        return $this->_path . 'views/img/uploads/' . $filename;
    }

    /**
     * Decode stored segments JSON. Returns array of normalized segment arrays.
     *
     * @return array<int, array{id_category:int,image:string,position:int}>
     */
    private function getStoredSegments(): array
    {
        $raw  = Configuration::get(self::CONF_SEGMENTS);
        $data = json_decode((string) $raw, true);

        if (!is_array($data)) {
            return [];
        }

        $segments = [];
        foreach ($data as $item) {
            $segments[] = [
                'id_category' => (int) ($item['id_category'] ?? 0),
                'image'       => (string) ($item['image'] ?? ''),
                'position'    => (int) ($item['position'] ?? 0),
            ];
        }

        return $segments;
    }

    /**
     * Return a flat list of active categories for the select widget in BO.
     *
     * @return array<int, array{id:int,name:string}>
     */
    private function getActiveCategoryList(): array
    {
        $langId = (int) $this->context->language->id;
        $shopId = (int) $this->context->shop->id;

        $sql = 'SELECT c.id_category, cl.name
                FROM `' . _DB_PREFIX_ . 'category` c
                INNER JOIN `' . _DB_PREFIX_ . 'category_lang` cl
                    ON c.id_category = cl.id_category AND cl.id_lang = ' . $langId . '
                INNER JOIN `' . _DB_PREFIX_ . 'category_shop` cs
                    ON c.id_category = cs.id_category AND cs.id_shop = ' . $shopId . '
                WHERE c.active = 1
                    AND c.is_root_category = 0
                    AND c.level_depth >= 2
                ORDER BY cl.name ASC';

        $rows = Db::getInstance()->executeS($sql);
        if (!is_array($rows)) {
            return [];
        }

        $list = [];
        foreach ($rows as $row) {
            $list[] = [
                'id'   => (int) $row['id_category'],
                'name' => (string) $row['name'],
            ];
        }

        return $list;
    }

    /** Remove all segment images from the module's uploads directory. */
    private function deleteAllSegmentImages(): void
    {
        $dir = _PS_MODULE_DIR_ . $this->name . '/views/img/uploads/';
        if (!is_dir($dir)) {
            return;
        }

        foreach (glob($dir . 'segment-*') ?: [] as $file) {
            if (is_file($file)) {
                @unlink($file);
            }
        }
    }

    /* ── Widget ── */

    public function renderWidget($hookName = null, array $configuration = [])
    {
        $variables = $this->getWidgetVariables($hookName, $configuration);
        if (empty($variables['tc_categoryslider_segments'])) {
            return '';
        }

        $this->smarty->assign($variables);

        return $this->fetch('module:tc_categoryslider/views/templates/hook/displayHome.tpl');
    }

    public function getWidgetVariables($hookName = null, array $configuration = [])
    {
        $segments = $this->getStoredSegments();
        if (empty($segments)) {
            return [];
        }

        $enriched = [];
        $langId = (int) $this->context->language->id;

        foreach ($segments as $segment) {
            $idCategory = (int) $segment['id_category'];
            if ($idCategory <= 0) {
                continue;
            }

            // Load with language ID so name/description are plain strings, not arrays
            $category = new Category($idCategory, $langId);
            if (!Validate::isLoadedObject($category)) {
                continue;
            }

            $products = $this->getCategoryProducts($idCategory);
            if (empty($products)) {
                continue;
            }

            $enriched[] = [
                'id_category'          => $idCategory,
                'category_name'        => (string) $category->name,
                'category_description' => strip_tags((string) $category->additional_description),
                'category_url'         => $this->context->link->getCategoryLink($category),
                'image'                => $segment['image'],
                'products'             => $products,
            ];
        }

        if (empty($enriched)) {
            return [];
        }

        return ['tc_categoryslider_segments' => $enriched];
    }

    /**
     * Fetch and present up to DEFAULT_NB_PRODUCTS from the given category.
     *
     * @param int $idCategory
     *
     * @return array Presented products for Smarty
     */
    private function getCategoryProducts(int $idCategory): array
    {
        if (Configuration::get('PS_CATALOG_MODE') || $idCategory <= 0) {
            return [];
        }

        $category = new Category($idCategory);
        $rawProducts = $category->getProducts(
            (int) $this->context->language->id,
            1,
            self::DEFAULT_NB_PRODUCTS
        );

        if (empty($rawProducts)) {
            return [];
        }

        $assembler        = new ProductAssembler($this->context);
        $presenterFactory = new ProductPresenterFactory($this->context);
        $presentationSettings = $presenterFactory->getPresentationSettings();

        $presenter = new \PrestaShop\PrestaShop\Adapter\Presenter\Product\ProductListingPresenter(
            new ImageRetriever($this->context->link),
            $this->context->link,
            new PriceFormatter(),
            new ProductColorsRetriever(),
            $this->context->getTranslator()
        );

        $assembleInBulk = method_exists($assembler, 'assembleProducts');
        if ($assembleInBulk) {
            $rawProducts = $assembler->assembleProducts($rawProducts);
        }

        $presented = [];
        foreach ($rawProducts as $raw) {
            $assembled  = $assembleInBulk ? $raw : $assembler->assembleProduct($raw);
            $presented[] = $presenter->present($presentationSettings, $assembled, $this->context->language);
        }

        return $presented;
    }

    public function hookDisplayHome(array $params)
    {
        return $this->renderWidget('displayHome', $params);
    }
}
