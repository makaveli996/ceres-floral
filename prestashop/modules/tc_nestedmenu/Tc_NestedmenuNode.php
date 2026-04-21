<?php
/**
 * Menu tree node ObjectModel for tc_nestedmenu.
 * Used by tc_nestedmenu for BO CRUD and FO tree; multishop + multilang (label, link per shop/lang).
 * Fields: id_parent, position, active, new_window. Side effects: DB via ObjectModel; delete reorders siblings.
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

class Tc_NestedmenuNode extends ObjectModel
{
    /** @var int Parent node id; 0 = top level */
    public $id_parent;

    /** @var int Order among siblings */
    public $position;

    /** @var bool */
    public $active;

    /** @var bool Open link in new tab */
    public $new_window;

    /** @var string[] Label per language */
    public $label;

    /** @var string[] URL or path per language */
    public $link;

    public static $definition = [
        'table' => 'tc_nestedmenu_node',
        'primary' => 'id_tc_nestedmenu_node',
        'multilang' => true,
        'multilang_shop' => true,
        'multishop' => true,
        'fields' => [
            'id_parent' => [
                'type' => self::TYPE_INT,
                'validate' => 'isUnsignedInt',
                'required' => true,
            ],
            'position' => [
                'type' => self::TYPE_INT,
                'validate' => 'isUnsignedInt',
                'required' => true,
            ],
            'active' => [
                'type' => self::TYPE_BOOL,
                'validate' => 'isBool',
                'required' => true,
            ],
            'new_window' => [
                'type' => self::TYPE_BOOL,
                'validate' => 'isBool',
                'required' => true,
            ],
            'label' => [
                'type' => self::TYPE_STRING,
                'lang' => true,
                'validate' => 'isGenericName',
                'size' => 128,
            ],
            'link' => [
                'type' => self::TYPE_STRING,
                'lang' => true,
                'validate' => 'isString',
                'size' => 512,
            ],
        ],
    ];

    public function __construct($id = null, $id_lang = null, $id_shop = null)
    {
        parent::__construct($id, $id_lang, $id_shop);
    }

    public function add($autodate = true, $null_values = false)
    {
        $id_shop = (int) ($this->id_shop ?: Context::getContext()->shop->id);
        if (!isset($this->id_parent)) {
            $this->id_parent = 0;
        }
        $this->id_parent = (int) $this->id_parent;
        if (empty($this->position) || (int) $this->position === 0) {
            $this->position = (int) $this->getNextPosition($id_shop, $this->id_parent);
        }
        if (!isset($this->active)) {
            $this->active = 1;
        }
        if (!isset($this->new_window)) {
            $this->new_window = 0;
        }

        return parent::add($autodate, $null_values);
    }

    /**
     * @param int|null $id_shop
     * @param int $id_parent
     */
    public function getNextPosition($id_shop = null, $id_parent = 0)
    {
        if ($id_shop === null) {
            $id_shop = (int) Context::getContext()->shop->id;
        }
        $id_parent = (int) $id_parent;
        $sql = new DbQuery();
        $sql->select('MAX(n.`position`) AS `mx`');
        $sql->from('tc_nestedmenu_node', 'n');
        $sql->innerJoin('tc_nestedmenu_node_shop', 'ns', 'n.`id_tc_nestedmenu_node` = ns.`id_tc_nestedmenu_node`');
        $sql->where('ns.`id_shop` = ' . (int) $id_shop);
        $sql->where('n.`id_parent` = ' . $id_parent);
        $row = Db::getInstance((bool) _PS_USE_SQL_SLAVE_)->getRow($sql);

        return (int) ($row['mx'] ?? 0) + 1;
    }

    public function delete()
    {
        $id_shop = (int) ($this->id_shop ?: Context::getContext()->shop->id);
        $saved_parent = (int) $this->id_parent;

        $result = parent::delete();
        if ($result) {
            $this->reorderSiblings($saved_parent, $id_shop);
        }

        return $result;
    }

    /**
     * Renumber positions 1..n for siblings under id_parent in shop.
     */
    public function reorderSiblings($id_parent, $id_shop)
    {
        $sql = new DbQuery();
        $sql->select('n.`id_tc_nestedmenu_node`, n.`position`');
        $sql->from('tc_nestedmenu_node', 'n');
        $sql->innerJoin('tc_nestedmenu_node_shop', 'ns', 'n.`id_tc_nestedmenu_node` = ns.`id_tc_nestedmenu_node`');
        $sql->where('ns.`id_shop` = ' . (int) $id_shop);
        $sql->where('n.`id_parent` = ' . (int) $id_parent);
        $sql->orderBy('n.`position` ASC');
        $rows = Db::getInstance((bool) _PS_USE_SQL_SLAVE_)->executeS($sql);
        if (!$rows) {
            return true;
        }
        $pos = 1;
        foreach ($rows as $row) {
            $node = new self((int) $row['id_tc_nestedmenu_node'], null, $id_shop);
            if (Validate::isLoadedObject($node) && (int) $node->position !== $pos) {
                $node->position = $pos;
                $node->update();
            }
            ++$pos;
        }

        return true;
    }
}
