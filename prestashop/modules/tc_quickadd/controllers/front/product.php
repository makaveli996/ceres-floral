<?php
/**
 * tc_quickadd — Product AJAX front controller.
 * Purpose: returns product name, price, cover image, attribute groups,
 *   and all combination data as JSON for the quick-add modal.
 * Called from: _dev/js/custom/Sections/QuickAddModal.js via
 *   /index.php?fc=module&module=tc_quickadd&controller=product&id_product=N
 * Inputs: GET id_product (int).
 * Outputs: JSON {id_product, name, price, cover_url, groups[], combinations[], ...}.
 * Side effects: none — read-only.
 *
 * @author Rafal Majdan
 */

declare(strict_types=1);

class Tc_QuickAddProductModuleFrontController extends ModuleFrontController
{
    /** @var bool */
    public $ajax = true;

    public function initContent(): void
    {
        parent::initContent();
    }

    public function display(): void
    {
        $idProduct = (int) Tools::getValue('id_product');

        if (!$idProduct) {
            $this->returnJson(['error' => 'Missing id_product'], 400);
        }

        $idLang = (int) $this->context->language->id;
        $product = new Product($idProduct, false, $idLang);

        if (!Validate::isLoadedObject($product)) {
            $this->returnJson(['error' => 'Product not found'], 404);
        }

        $currency   = $this->context->currency;
        $idShop     = (int) $this->context->shop->id;

        // Price (with tax, formatted)
        $priceRaw  = Product::getPriceStatic($idProduct, true, null, 2, null, false, true, 1, false, null, null, null, $nothing);
        $price     = Tools::displayPrice($priceRaw, $currency);

        // Cover image URL
        $coverUrl = '';
        $cover    = Product::getCover($idProduct, $idShop);
        if (!empty($cover['id_image'])) {
            $coverUrl = $this->context->link->getImageLink(
                $product->link_rewrite[$idLang] ?? $product->link_rewrite,
                (int) $cover['id_image'],
                'home_default'
            );
        }

        // Combination rows: one row per attribute per combination
        $rows = $product->getAttributeCombinations($idLang);

        $groupsMap       = [];
        $combinationsMap = [];

        foreach ($rows as $row) {
            $idAttrGroup    = (int) $row['id_attribute_group'];
            $idAttr         = (int) $row['id_attribute'];
            $idProductAttr  = (int) $row['id_product_attribute'];

            // Build attribute group index
            if (!isset($groupsMap[$idAttrGroup])) {
                $groupsMap[$idAttrGroup] = [
                    'id'         => $idAttrGroup,
                    'name'       => $row['group_name'],
                    'type'       => $row['group_type'],
                    'attributes' => [],
                ];
            }

            $attrExists = false;
            foreach ($groupsMap[$idAttrGroup]['attributes'] as $a) {
                if ($a['id'] === $idAttr) { $attrExists = true; break; }
            }
            if (!$attrExists) {
                $groupsMap[$idAttrGroup]['attributes'][] = [
                    'id'               => $idAttr,
                    'name'             => $row['attribute_name'],
                    'html_color_code'  => $row['attribute_color'] ?? '',
                ];
            }

            // Build combination index
            if (!isset($combinationsMap[$idProductAttr])) {
                $combinationsMap[$idProductAttr] = [
                    'id_product_attribute' => $idProductAttr,
                    'attributes'           => [],
                    'available'            => ((int) $row['quantity']) > 0 || !Product::isAvailableWhenOutOfStock((int) $product->out_of_stock) === false,
                ];
            }
            $combinationsMap[$idProductAttr]['attributes'][$idAttrGroup] = $idAttr;
        }

        $defaultCombo = (int) Product::getDefaultAttribute($idProduct);

        $this->returnJson([
            'id_product'          => $idProduct,
            'name'                => $product->name[$idLang] ?? (is_array($product->name) ? reset($product->name) : (string) $product->name),
            'price'               => $price,
            'cover_url'           => $coverUrl,
            'groups'              => array_values($groupsMap),
            'combinations'        => array_values($combinationsMap),
            'default_combination' => $defaultCombo,
            'cart_url'            => $this->context->link->getPageLink('cart', true),
            'static_token'        => Tools::getToken(false),
        ]);
    }

    /**
     * @param array<string,mixed> $data
     */
    private function returnJson(array $data, int $statusCode = 200): void
    {
        http_response_code($statusCode);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        exit;
    }
}
