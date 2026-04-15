<?php
/**
 * Bestsellers Slider module (tc_bestsellersslider).
 * Renders a "Najczęściej kupowane" section on displayHome with a Splide slider of bestsellers.
 * BO config: TC_BESTSELLERSSLIDER_TITLE, TC_BESTSELLERSSLIDER_SUBTITLE (editable via Konfiguruj).
 * FE JS: _dev/js/custom/Sections/BestsellersSlider.js
 * FE CSS: _dev/css/custom/sections/_bestsellers-slider.scss
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

use PrestaShop\PrestaShop\Adapter\BestSales\BestSalesProductSearchProvider;
use PrestaShop\PrestaShop\Adapter\Image\ImageRetriever;
use PrestaShop\PrestaShop\Adapter\Product\PriceFormatter;
use PrestaShop\PrestaShop\Adapter\Product\ProductColorsRetriever;
use PrestaShop\PrestaShop\Core\Module\WidgetInterface;
use PrestaShop\PrestaShop\Core\Product\Search\ProductSearchContext;
use PrestaShop\PrestaShop\Core\Product\Search\ProductSearchQuery;
use PrestaShop\PrestaShop\Core\Product\Search\SortOrder;

class Tc_Bestsellersslider extends Module implements WidgetInterface
{
    /** @var string Template path for hook */
    private $templateFile;

    /** @var int Default number of bestsellers to display */
    private const DEFAULT_NB_PRODUCTS = 12;

    private const CFG_TITLE    = 'TC_BESTSELLERSSLIDER_TITLE';
    private const CFG_SUBTITLE = 'TC_BESTSELLERSSLIDER_SUBTITLE';

    public function __construct()
    {
        $this->name = 'tc_bestsellersslider';
        $this->tab = 'front_office_features';
        $this->version = '1.0.0';
        $this->author = 'Rafal Majdan';
        $this->need_instance = 0;
        $this->bootstrap = true;
        $this->is_configurable = 1;

        parent::__construct();

        $this->displayName = $this->trans('Bestsellery slider', [], 'Modules.Tc_bestsellersslider.Admin');
        $this->description = $this->trans('Wyświetla sekcję „Najczęściej kupowane" na stronie głównej jako slider Splide z bestsellerami.', [], 'Modules.Tc_bestsellersslider.Admin');
        $this->ps_versions_compliancy = ['min' => '1.7.0.0', 'max' => _PS_VERSION_];
        $this->templateFile = 'module:tc_bestsellersslider/views/templates/hook/tc_bestsellersslider.tpl';
    }

    public function install()
    {
        return parent::install()
            && $this->registerHook('displayHome')
            && Configuration::updateValue(self::CFG_TITLE, 'Najczęściej kupowane')
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

        if (Tools::isSubmit('submit_tc_bestsellersslider')) {
            $title    = Tools::getValue(self::CFG_TITLE, '');
            $subtitle = Tools::getValue(self::CFG_SUBTITLE, '');

            if (empty(trim((string) $title))) {
                $output .= $this->displayError(
                    $this->trans('Tytuł nie może być pusty.', [], 'Modules.Tc_bestsellersslider.Admin')
                );
            } else {
                Configuration::updateValue(self::CFG_TITLE, $title);
                Configuration::updateValue(self::CFG_SUBTITLE, $subtitle);
                $output .= $this->displayConfirmation(
                    $this->trans('Ustawienia zostały zapisane.', [], 'Modules.Tc_bestsellersslider.Admin')
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
                    'title' => $this->trans('Ustawienia sekcji', [], 'Modules.Tc_bestsellersslider.Admin'),
                    'icon'  => 'icon-cogs',
                ],
                'input' => [
                    [
                        'type'     => 'text',
                        'label'    => $this->trans('Tytuł', [], 'Modules.Tc_bestsellersslider.Admin'),
                        'name'     => self::CFG_TITLE,
                        'required' => true,
                        'col'      => 6,
                    ],
                    [
                        'type'  => 'textarea',
                        'label' => $this->trans('Podtytuł', [], 'Modules.Tc_bestsellersslider.Admin'),
                        'name'  => self::CFG_SUBTITLE,
                        'desc'  => $this->trans('Zostaw puste, aby ukryć podtytuł.', [], 'Modules.Tc_bestsellersslider.Admin'),
                        'col'   => 6,
                        'rows'  => 3,
                    ],
                ],
                'submit' => [
                    'title' => $this->trans('Zapisz', [], 'Modules.Tc_bestsellersslider.Admin'),
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
        $helper->submit_action   = 'submit_tc_bestsellersslider';

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
        $products = $this->getBestsellers();
        if (empty($products)) {
            return [];
        }

        $title    = (string) Configuration::get(self::CFG_TITLE);
        $subtitle = (string) Configuration::get(self::CFG_SUBTITLE);

        if (empty($title)) {
            $title = $this->trans('Najczęściej kupowane', [], 'Modules.Tc_bestsellersslider.Shop');
        }

        $link = $this->context->link;

        return [
            'tc_bestsellersslider_products' => $products,
            'tc_bestsellersslider_title'    => $title,
            'tc_bestsellersslider_subtitle' => $subtitle,
            'tc_bestsellersslider_all_url'  => $link->getPageLink('best-sales'),
            'tc_bestsellersslider_cta_label' => $this->trans('Zobacz wszystkie', [], 'Modules.Tc_bestsellersslider.Shop'),
        ];
    }

    /**
     * Fetch bestsellers using core BestSalesProductSearchProvider and present for template.
     * Respects catalog mode, current language and shop. Adds "last_units" flag when quantity is low.
     *
     * @return array<int, array> Presented products for Smarty (url, name, price, cover, flags, etc.)
     */
    protected function getBestsellers()
    {
        if (Configuration::get('PS_CATALOG_MODE')) {
            return [];
        }

        $searchProvider = new BestSalesProductSearchProvider($this->context->getTranslator());
        $context = new ProductSearchContext($this->context);
        $query = new ProductSearchQuery();
        $query
            ->setResultsPerPage(self::DEFAULT_NB_PRODUCTS)
            ->setPage(1)
            ->setSortOrder(new SortOrder('product', 'sales', 'desc'));

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

        $lastUnitsLabel    = $this->trans('Ostatnie sztuki!', [], 'Modules.Tc_bestsellersslider.Shop');
        $lastUnitsThreshold = 5;
        $idShop            = (int) $this->context->shop->id;

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
                    // PS 8 LazyArray: offsetSet with $force=true bypasses the @isRewritable guard.
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
