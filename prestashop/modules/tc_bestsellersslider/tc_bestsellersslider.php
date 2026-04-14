<?php
/**
 * Bestsellers Slider module (tc_bestsellersslider).
 * Renders a "Bestsellery" section on displayHome with a Splide slider of bestsellers.
 * Uses BestSalesProductSearchProvider + ProductListingPresenter; FE JS in _dev/js/custom/Sections/TcBestsellersSlider.js, styles in _dev/css/custom/sections/_bestsellers-slider.scss.
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

    public function __construct()
    {
        $this->name = 'tc_bestsellersslider';
        $this->tab = 'front_office_features';
        $this->version = '1.0.0';
        $this->author = 'Rafal Majdan';
        $this->need_instance = 0;
        $this->bootstrap = true;

        parent::__construct();

        $this->displayName = $this->trans('Bestsellery slider', [], 'Modules.Tc_bestsellersslider.Admin');
        $this->description = $this->trans('Wyświetla sekcję „Bestsellery” na stronie głównej jako slider Splide z bestsellerami.', [], 'Modules.Tc_bestsellersslider.Admin');
        $this->ps_versions_compliancy = ['min' => '1.7.0.0', 'max' => _PS_VERSION_];
        $this->templateFile = 'module:tc_bestsellersslider/views/templates/hook/tc_bestsellersslider.tpl';
    }

    public function install()
    {
        return parent::install()
            && $this->registerHook('displayHome');
    }

    public function uninstall()
    {
        return parent::uninstall();
    }

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

        $link = $this->context->link;
        $allBestSellersUrl = $link->getPageLink('best-sales');
        $title = $this->trans('Najczęściej kupowane', [], 'Modules.Tc_bestsellersslider.Shop');
        $subtitle = $this->trans('Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut', [], 'Modules.Tc_bestsellersslider.Shop');
        $ctaLabel = $this->trans('Zobacz wszystkie', [], 'Modules.Tc_bestsellersslider.Shop');

        return [
            'tc_bestsellersslider_products' => $products,
            'tc_bestsellersslider_title' => $title,
            'tc_bestsellersslider_subtitle' => $subtitle,
            'tc_bestsellersslider_all_url' => $allBestSellersUrl,
            'tc_bestsellersslider_cta_label' => $ctaLabel,
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

        $lastUnitsLabel = $this->trans('Ostatnie sztuki!', [], 'Modules.Tc_bestsellersslider.Shop');
        $lastUnitsThreshold = 5;
        $idShop = (int) $this->context->shop->id;

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
                    // PS 8 LazyArray: getFlags() has no @isRewritable, so standard offsetSet throws
                    // RuntimeException. Call with $force=true to bypass the guard.
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
