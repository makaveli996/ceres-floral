<?php
/**
 * New Products Slider module (tc_newproductsslider).
 * Renders a "Nowości" section on displayHome with a Splide slider of newest products.
 * BO config: TC_NEWPRODUCTSSLIDER_TITLE, TC_NEWPRODUCTSSLIDER_SUBTITLE (editable via Konfiguruj).
 * FE JS: _dev/js/custom/Sections/ProductSlider.js (shared, no module-specific JS needed).
 * FE CSS: _dev/css/custom/sections/_newproducts-slider.scss.
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

use PrestaShop\PrestaShop\Adapter\NewProducts\NewProductsProductSearchProvider;
use PrestaShop\PrestaShop\Adapter\Image\ImageRetriever;
use PrestaShop\PrestaShop\Adapter\Product\PriceFormatter;
use PrestaShop\PrestaShop\Adapter\Product\ProductColorsRetriever;
use PrestaShop\PrestaShop\Core\Module\WidgetInterface;
use PrestaShop\PrestaShop\Core\Product\Search\ProductSearchContext;
use PrestaShop\PrestaShop\Core\Product\Search\ProductSearchQuery;
use PrestaShop\PrestaShop\Core\Product\Search\SortOrder;

class Tc_Newproductsslider extends Module implements WidgetInterface
{
    /** @var string Template path for hook */
    private $templateFile;

    /** @var int Default number of new products to display */
    private const DEFAULT_NB_PRODUCTS = 12;

    private const CFG_TITLE    = 'TC_NEWPRODUCTSSLIDER_TITLE';
    private const CFG_SUBTITLE = 'TC_NEWPRODUCTSSLIDER_SUBTITLE';

    public function __construct()
    {
        $this->name = 'tc_newproductsslider';
        $this->tab = 'front_office_features';
        $this->version = '1.0.0';
        $this->author = 'Rafal Majdan';
        $this->need_instance = 0;
        $this->bootstrap = true;
        $this->is_configurable = 1;

        parent::__construct();

        $this->displayName = $this->trans('Nowości slider', [], 'Modules.Tc_newproductsslider.Admin');
        $this->description = $this->trans('Wyświetla sekcję „Nowości" na stronie głównej jako slider Splide z najnowszymi produktami.', [], 'Modules.Tc_newproductsslider.Admin');
        $this->ps_versions_compliancy = ['min' => '1.7.0.0', 'max' => _PS_VERSION_];
        $this->templateFile = 'module:tc_newproductsslider/views/templates/hook/tc_newproductsslider.tpl';
    }

    public function install()
    {
        return parent::install()
            && $this->registerHook('displayHome')
            && Configuration::updateValue(self::CFG_TITLE, 'Nowości')
            && Configuration::updateValue(self::CFG_SUBTITLE, '');
    }

    public function uninstall()
    {
        Configuration::deleteByName(self::CFG_TITLE);
        Configuration::deleteByName(self::CFG_SUBTITLE);

        return parent::uninstall();
    }

    /* ── Back-office configuration ── */

    public function getContent()
    {
        $output = '';

        if (Tools::isSubmit('submit_tc_newproductsslider')) {
            $title    = Tools::getValue(self::CFG_TITLE, '');
            $subtitle = Tools::getValue(self::CFG_SUBTITLE, '');

            if (empty(trim((string) $title))) {
                $output .= $this->displayError(
                    $this->trans('Tytuł nie może być pusty.', [], 'Modules.Tc_newproductsslider.Admin')
                );
            } else {
                Configuration::updateValue(self::CFG_TITLE, $title);
                Configuration::updateValue(self::CFG_SUBTITLE, $subtitle);
                $output .= $this->displayConfirmation(
                    $this->trans('Ustawienia zostały zapisane.', [], 'Modules.Tc_newproductsslider.Admin')
                );
            }
        }

        return $output . $this->renderConfigForm();
    }

    private function renderConfigForm(): string
    {
        $fields = [
            'form' => [
                'legend' => [
                    'title' => $this->trans('Ustawienia sekcji', [], 'Modules.Tc_newproductsslider.Admin'),
                    'icon'  => 'icon-cogs',
                ],
                'input' => [
                    [
                        'type'     => 'text',
                        'label'    => $this->trans('Tytuł', [], 'Modules.Tc_newproductsslider.Admin'),
                        'name'     => self::CFG_TITLE,
                        'required' => true,
                        'col'      => 6,
                    ],
                    [
                        'type'  => 'textarea',
                        'label' => $this->trans('Podtytuł', [], 'Modules.Tc_newproductsslider.Admin'),
                        'name'  => self::CFG_SUBTITLE,
                        'desc'  => $this->trans('Zostaw puste, aby ukryć podtytuł.', [], 'Modules.Tc_newproductsslider.Admin'),
                        'col'   => 6,
                        'rows'  => 3,
                    ],
                ],
                'submit' => [
                    'title' => $this->trans('Zapisz', [], 'Modules.Tc_newproductsslider.Admin'),
                ],
            ],
        ];

        $helper = new HelperForm();
        $helper->module          = $this;
        $helper->name_controller = $this->name;
        $helper->token           = Tools::getAdminTokenLite('AdminModules');
        $helper->currentIndex    = AdminController::$currentIndex . '&configure=' . $this->name;
        $helper->default_form_language    = $this->context->language->id;
        $helper->allow_employee_form_lang = (int) Configuration::get('PS_BO_ALLOW_EMPLOYEE_FORM_LANG', 0);
        $helper->submit_action   = 'submit_tc_newproductsslider';

        $helper->tpl_vars = [
            'fields_value' => [
                self::CFG_TITLE    => Configuration::get(self::CFG_TITLE),
                self::CFG_SUBTITLE => Configuration::get(self::CFG_SUBTITLE),
            ],
            'languages'   => $this->context->controller->getLanguages(),
            'id_language' => $this->context->language->id,
        ];

        return $helper->generateForm([$fields]);
    }

    /* ── Widget ── */

    public function renderWidget($hookName = null, array $configuration = [])
    {
        $variables = $this->getWidgetVariables($hookName, $configuration);
        if (empty($variables)) {
            return '';
        }
        $this->smarty->assign($variables);

        return $this->fetch($this->templateFile);
    }

    public function getWidgetVariables($hookName = null, array $configuration = [])
    {
        $products = $this->getNewProducts();
        if (empty($products)) {
            return [];
        }

        $title    = (string) Configuration::get(self::CFG_TITLE);
        $subtitle = (string) Configuration::get(self::CFG_SUBTITLE);

        if (empty($title)) {
            $title = $this->trans('Nowości', [], 'Modules.Tc_newproductsslider.Shop');
        }

        $link = $this->context->link;

        return [
            'tc_newproductsslider_products'   => $products,
            'tc_newproductsslider_title'       => $title,
            'tc_newproductsslider_subtitle'    => $subtitle,
            'tc_newproductsslider_all_url'     => $link->getPageLink('new-products'),
            'tc_newproductsslider_cta_label'   => $this->trans('Zobacz wszystkie', [], 'Modules.Tc_newproductsslider.Shop'),
        ];
    }

    /**
     * Fetch new products using core NewProductsProductSearchProvider.
     * Sorted by date_add descending. Respects catalog mode, language and shop.
     * Adds "last_units" flag when stock quantity is low (≤ 5).
     *
     * @return array<int, array> Presented products for Smarty (url, name, price, cover, flags, etc.)
     */
    protected function getNewProducts()
    {
        if (Configuration::get('PS_CATALOG_MODE')) {
            return [];
        }

        $searchProvider = new NewProductsProductSearchProvider($this->context->getTranslator());
        $context = new ProductSearchContext($this->context);
        $query = new ProductSearchQuery();
        $query
            ->setResultsPerPage(self::DEFAULT_NB_PRODUCTS)
            ->setPage(1)
            ->setSortOrder(new SortOrder('product', 'date_add', 'desc'));

        $result = $searchProvider->runQuery($context, $query);
        $rawProducts = $result->getProducts();
        if (empty($rawProducts)) {
            return [];
        }

        $assembler = new ProductAssembler($this->context);
        $presenterFactory = new ProductPresenterFactory($this->context);
        $presentationSettings = $presenterFactory->getPresentationSettings();

        if (version_compare(_PS_VERSION_, '1.7.5', '>=')) {
            $presenter = new \PrestaShop\PrestaShop\Adapter\Presenter\Product\ProductListingPresenter(
                new ImageRetriever($this->context->link),
                $this->context->link,
                new PriceFormatter(),
                new ProductColorsRetriever(),
                $this->context->getTranslator()
            );
        } else {
            $presenter = new \PrestaShop\PrestaShop\Core\Product\ProductListingPresenter(
                new ImageRetriever($this->context->link),
                $this->context->link,
                new PriceFormatter(),
                new ProductColorsRetriever(),
                $this->context->getTranslator()
            );
        }

        $assembleInBulk = method_exists($assembler, 'assembleProducts');
        if ($assembleInBulk) {
            $rawProducts = $assembler->assembleProducts($rawProducts);
        }

        $lastUnitsLabel     = $this->trans('Ostatnie sztuki!', [], 'Modules.Tc_newproductsslider.Shop');
        $lastUnitsThreshold = 5;
        $idShop             = (int) $this->context->shop->id;

        $productsForTemplate = [];
        foreach ($rawProducts as $rawProduct) {
            $assembled = $assembleInBulk ? $rawProduct : $assembler->assembleProduct($rawProduct);
            $presented = $presenter->present($presentationSettings, $assembled, $this->context->language);

            $idProduct = isset($assembled['id_product']) ? (int) $assembled['id_product'] : 0;
            if ($idProduct > 0) {
                $stock = (int) \Db::getInstance()->getValue(
                    'SELECT IFNULL(SUM(quantity), 0) FROM `' . _DB_PREFIX_ . 'stock_available`'
                    . ' WHERE id_product = ' . $idProduct . ' AND id_shop = ' . $idShop
                );
                if ($stock > 0 && $stock <= $lastUnitsThreshold) {
                    $flags = isset($presented['flags']) ? (array) $presented['flags'] : [];
                    $flags[] = ['type' => 'last_units', 'label' => $lastUnitsLabel];
                    if (is_object($presented)) {
                        $presented->offsetSet('flags', $flags, true);
                    } else {
                        $presented['flags'] = $flags;
                    }
                }
            }

            $productsForTemplate[] = $presented;
        }

        return $productsForTemplate;
    }

    public function hookDisplayHome(array $params)
    {
        return $this->renderWidget('displayHome', $params);
    }
}
