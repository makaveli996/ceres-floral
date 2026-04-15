<?php
/**
 * Adds a free-text "subtitle" field to each product attribute value in BO.
 * Used from: hooks displayAttributeForm, actionAttributeSave, actionAttributeDelete.
 * Inputs: POST `tc_attribute_subtitle`, `id_attribute` (from hook params).
 * Outputs: HTML field in BO form; static getter for FO/PDP use.
 * DB: `PREFIX_tc_attribute_extra` (id_attribute, subtitle).
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

class Tc_Attributeextra extends Module
{
    /** @var string DB table name without prefix */
    const TABLE = 'tc_attribute_extra';

    public function __construct()
    {
        $this->name = 'tc_attributeextra';
        $this->tab = 'administration';
        $this->version = '1.0.0';
        $this->author = 'Rafal Majdan';
        $this->need_instance = 0;
        $this->bootstrap = true;

        parent::__construct();

        $this->displayName = $this->trans('Atrybut — dodatkowy tekst', [], 'Modules.Tc_attributeextra.Admin');
        $this->description = $this->trans(
            'Dodaje pole z dodatkowym tekstem do każdej wartości atrybutu. Wyświetlany na karcie produktu pod nazwą atrybutu.',
            [],
            'Modules.Tc_attributeextra.Admin'
        );
        $this->ps_versions_compliancy = ['min' => '1.7.0.0', 'max' => _PS_VERSION_];
    }

    public function install(): bool
    {
        return parent::install()
            && $this->createTable()
            && $this->registerHook('displayAttributeForm')
            && $this->registerHook('actionAttributeSave')
            && $this->registerHook('actionAttributeDelete');
    }

    public function uninstall(): bool
    {
        return parent::uninstall() && $this->dropTable();
    }

    // ─── Hooks ────────────────────────────────────────────────────────────────

    /**
     * Rendered right after the "Nazwa" field in the BO attribute edit form.
     *
     * @param array $params  Keys: id_attribute (int, 0 when creating new)
     */
    public function hookDisplayAttributeForm(array $params): string
    {
        $idAttribute = (int) ($params['id_attribute'] ?? 0);
        $subtitle = $idAttribute ? self::getSubtitle($idAttribute) : '';

        $this->context->smarty->assign([
            'tc_subtitle'      => $subtitle,
            'tc_id_attribute'  => $idAttribute,
        ]);

        return $this->display(__FILE__, 'views/templates/hook/displayAttributeForm.tpl');
    }

    /**
     * Fired by ProductAttribute::add() and ProductAttribute::update().
     *
     * @param array $params  Keys: id_attribute (int)
     */
    public function hookActionAttributeSave(array $params): void
    {
        $idAttribute = (int) ($params['id_attribute'] ?? 0);
        if (!$idAttribute) {
            return;
        }

        $subtitle = pSQL(Tools::getValue('tc_attribute_subtitle', ''));

        Db::getInstance()->execute(
            'INSERT INTO `' . _DB_PREFIX_ . self::TABLE . '`
             (`id_attribute`, `subtitle`)
             VALUES (' . $idAttribute . ', \'' . $subtitle . '\')
             ON DUPLICATE KEY UPDATE `subtitle` = \'' . $subtitle . '\''
        );
    }

    /**
     * Fired by ProductAttribute::delete().
     *
     * @param array $params  Keys: id_attribute (int)
     */
    public function hookActionAttributeDelete(array $params): void
    {
        $idAttribute = (int) ($params['id_attribute'] ?? 0);
        if (!$idAttribute) {
            return;
        }

        Db::getInstance()->execute(
            'DELETE FROM `' . _DB_PREFIX_ . self::TABLE . '`
             WHERE `id_attribute` = ' . $idAttribute
        );
    }

    // ─── Public API (for FO / PDP) ────────────────────────────────────────────

    /**
     * Returns the subtitle text for a given attribute value ID.
     * Returns empty string when no subtitle is set.
     *
     * @param int $idAttribute
     */
    public static function getSubtitle(int $idAttribute): string
    {
        if ($idAttribute <= 0) {
            return '';
        }

        $row = Db::getInstance()->getRow(
            'SELECT `subtitle`
             FROM `' . _DB_PREFIX_ . self::TABLE . '`
             WHERE `id_attribute` = ' . (int) $idAttribute
        );

        return $row ? (string) $row['subtitle'] : '';
    }

    // ─── DB helpers ───────────────────────────────────────────────────────────

    private function createTable(): bool
    {
        return Db::getInstance()->execute(
            'CREATE TABLE IF NOT EXISTS `' . _DB_PREFIX_ . self::TABLE . '` (
                `id_attribute` INT(10) UNSIGNED NOT NULL,
                `subtitle`     VARCHAR(255) NOT NULL DEFAULT \'\',
                PRIMARY KEY (`id_attribute`)
            ) ENGINE=' . _MYSQL_ENGINE_ . ' DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;'
        );
    }

    private function dropTable(): bool
    {
        return Db::getInstance()->execute(
            'DROP TABLE IF EXISTS `' . _DB_PREFIX_ . self::TABLE . '`'
        );
    }
}
