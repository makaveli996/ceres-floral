<?php
/**
 * tc_quickadd — Quick-add-to-cart AJAX data provider for product tiles.
 * Purpose: exposes a front controller returning product combination data as JSON,
 *   consumed by _dev/js/custom/Sections/QuickAddModal.js.
 * Used by: hook: none (module only registers front controller route).
 * Inputs: GET id_product; Output: JSON {groups, combinations, price, cover_url, ...}.
 * Side effects: none (read-only product data).
 *
 * @author Rafal Majdan
 */

declare(strict_types=1);

if (!defined('_PS_VERSION_')) {
    exit;
}

class Tc_QuickAdd extends Module
{
    public function __construct()
    {
        $this->name            = 'tc_quickadd';
        $this->tab             = 'front_office_features';
        $this->version         = '1.0.0';
        $this->author          = 'Rafal Majdan';
        $this->need_instance   = 0;
        $this->ps_versions_compliancy = [
            'min' => '8.0.0',
            'max' => _PS_VERSION_,
        ];
        $this->bootstrap = false;

        parent::__construct();

        $this->displayName = $this->l('TC Szybkie dodanie do koszyka', 'tc_quickadd');
        $this->description = $this->l(
            'Dostarcza endpoint AJAX dla modalu szybkiego dodawania na kafelkach produktów.',
            'tc_quickadd'
        );
    }

    public function install(): bool
    {
        return parent::install();
    }

    public function uninstall(): bool
    {
        return parent::uninstall();
    }
}
