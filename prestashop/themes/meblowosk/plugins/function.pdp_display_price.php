<?php
/**
 * Purpose: Format a raw price (float) for PDP Smarty snippets (installments, etc.).
 * Called from: theme templates, e.g. `{pdp_display_price price=$x}`.
 * Inputs: Smarty params `price` (float, required); optional `currency` (currency id).
 * Outputs: HTML string from Tools::displayPrice (currency symbol, locale).
 * Side effects: none.
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

/**
 * @param array<string, mixed> $params
 */
function smarty_function_pdp_display_price(array $params): string
{
    if (!isset($params['price'])) {
        return '';
    }

    $context = Context::getContext();
    $price = (float) $params['price'];

    if (isset($params['currency'])) {
        $currency = Currency::getCurrencyInstance((int) $params['currency']);
        if (Validate::isLoadedObject($currency)) {
            return Tools::displayPrice($price, $currency);
        }
    }

    return Tools::displayPrice($price, $context->currency);
}
