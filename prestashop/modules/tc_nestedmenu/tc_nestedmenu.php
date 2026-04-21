<?php
/**
 * Nested custom main menu (tc_nestedmenu).
 * BO: arbitrary tree (id_parent, order); FO: displayTop widget, markup aligned with ps_mainmenu theme styles.
 * Hooks: displayTop, getContent. Side effects: DB (tc_nestedmenu_node*), Smarty cache clear.
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

use PrestaShop\PrestaShop\Core\Module\WidgetInterface;

require_once __DIR__ . '/Tc_NestedmenuNode.php';

class Tc_Nestedmenu extends Module implements WidgetInterface
{
    /** @var string */
    protected $_html = '';

    /** @var string */
    private $templateFile;

    public function __construct()
    {
        $this->name = 'tc_nestedmenu';
        $this->tab = 'front_office_features';
        $this->version = '1.0.0';
        $this->author = 'Rafal Majdan';
        $this->need_instance = 0;
        $this->bootstrap = true;

        parent::__construct();

        $this->displayName = $this->trans('Menu wielopoziomowe (własne drzewo)', [], 'Modules.Tc_nestedmenu.Admin');
        $this->description = $this->trans('Buduj dowolną hierarchię pozycji menu z własnymi etykietami i linkami — bez ograniczeń do kategorii PrestaShop.', [], 'Modules.Tc_nestedmenu.Admin');
        $this->ps_versions_compliancy = ['min' => '1.7.7.0', 'max' => _PS_VERSION_];
        $this->templateFile = 'module:tc_nestedmenu/views/templates/hook/tc_nestedmenu.tpl';
    }

    public function install()
    {
        return parent::install()
            && $this->registerHook('displayTop')
            && $this->createTables()
            && $this->registerShopAssociations();
    }

    public function uninstall()
    {
        return $this->deleteTables() && parent::uninstall();
    }

    protected function registerShopAssociations()
    {
        Shop::addTableAssociation('tc_nestedmenu_node', ['type' => 'shop']);
        Shop::addTableAssociation('tc_nestedmenu_node_lang', ['type' => 'fk_shop']);

        return true;
    }

    protected function createTables()
    {
        $main = _DB_PREFIX_ . 'tc_nestedmenu_node';
        $lang = _DB_PREFIX_ . 'tc_nestedmenu_node_lang';
        $shop = _DB_PREFIX_ . 'tc_nestedmenu_node_shop';

        $sqlMain = 'CREATE TABLE IF NOT EXISTS `' . $main . '` (
            `id_tc_nestedmenu_node` int(10) unsigned NOT NULL AUTO_INCREMENT,
            `id_parent` int(10) unsigned NOT NULL DEFAULT 0,
            `position` int(10) unsigned NOT NULL DEFAULT 0,
            `active` tinyint(1) unsigned NOT NULL DEFAULT 1,
            `new_window` tinyint(1) unsigned NOT NULL DEFAULT 0,
            PRIMARY KEY (`id_tc_nestedmenu_node`),
            KEY `id_parent` (`id_parent`),
            KEY `position` (`position`)
        ) ENGINE=' . _MYSQL_ENGINE_ . ' DEFAULT CHARSET=utf8mb4;';

        $sqlLang = 'CREATE TABLE IF NOT EXISTS `' . $lang . '` (
            `id_tc_nestedmenu_node` int(10) unsigned NOT NULL,
            `id_lang` int(10) unsigned NOT NULL,
            `id_shop` int(10) unsigned NOT NULL,
            `label` varchar(128) NOT NULL DEFAULT "",
            `link` varchar(512) NOT NULL DEFAULT "",
            PRIMARY KEY (`id_tc_nestedmenu_node`, `id_lang`, `id_shop`)
        ) ENGINE=' . _MYSQL_ENGINE_ . ' DEFAULT CHARSET=utf8mb4;';

        $sqlShop = 'CREATE TABLE IF NOT EXISTS `' . $shop . '` (
            `id_tc_nestedmenu_node` int(10) unsigned NOT NULL,
            `id_shop` int(10) unsigned NOT NULL,
            PRIMARY KEY (`id_tc_nestedmenu_node`, `id_shop`)
        ) ENGINE=' . _MYSQL_ENGINE_ . ' DEFAULT CHARSET=utf8mb4;';

        return Db::getInstance()->execute($sqlMain)
            && Db::getInstance()->execute($sqlLang)
            && Db::getInstance()->execute($sqlShop);
    }

    protected function deleteTables()
    {
        $sql = 'DROP TABLE IF EXISTS `' . _DB_PREFIX_ . 'tc_nestedmenu_node_lang`,
            `' . _DB_PREFIX_ . 'tc_nestedmenu_node_shop`,
            `' . _DB_PREFIX_ . 'tc_nestedmenu_node`';

        return Db::getInstance()->execute($sql);
    }

    public function getContent()
    {
        $this->_html = '';
        $this->_clearCache($this->templateFile);
        $this->createTables();
        $this->registerShopAssociations();

        if (Shop::getContext() == Shop::CONTEXT_GROUP || Shop::getContext() == Shop::CONTEXT_ALL) {
            return $this->displayError($this->trans('Wybierz jeden sklep, aby edytować menu.', [], 'Modules.Tc_nestedmenu.Admin'));
        }

        $formSubmitFailed = false;
        if (
            Tools::isSubmit('submitTcNestedmenuNode')
            || Tools::isSubmit('delete_id_tc_nestedmenu_node')
            || Tools::isSubmit('move_node')
        ) {
            if ($this->postValidation()) {
                $this->postProcess();
            } elseif (Tools::isSubmit('submitTcNestedmenuNode')) {
                $formSubmitFailed = true;
            }
        }

        $idNodeGet = Tools::getValue('id_tc_nestedmenu_node');
        $showForm = Tools::isSubmit('addNode')
            || Tools::isSubmit('addChild')
            || ($idNodeGet && ctype_digit((string) $idNodeGet) && $this->nodeExistsInShop((int) $idNodeGet, (int) $this->context->shop->id))
            || $formSubmitFailed;

        if ($showForm) {
            $this->_html .= $this->renderNodeForm();
        } else {
            $this->_html .= $this->renderTreeList();
        }

        return $this->_html;
    }

    protected function nodeExistsInShop($id, $id_shop)
    {
        $n = new Tc_NestedmenuNode((int) $id, null, (int) $id_shop);

        return Validate::isLoadedObject($n);
    }

    protected function postValidation()
    {
        $errors = [];
        $id_shop = (int) $this->context->shop->id;

        if (Tools::isSubmit('delete_id_tc_nestedmenu_node')) {
            $id = (int) Tools::getValue('delete_id_tc_nestedmenu_node');
            $node = new Tc_NestedmenuNode($id, null, $id_shop);
            if (!Validate::isLoadedObject($node)) {
                $errors[] = $this->trans('Nieprawidłowa pozycja menu.', [], 'Modules.Tc_nestedmenu.Admin');
            }
        } elseif (Tools::isSubmit('move_node')) {
            $id = (int) Tools::getValue('id_tc_nestedmenu_node');
            $dir = Tools::getValue('direction');
            if (!in_array($dir, ['up', 'down'], true)) {
                $errors[] = $this->trans('Nieprawidłowy kierunek przesunięcia.', [], 'Modules.Tc_nestedmenu.Admin');
            }
            $node = new Tc_NestedmenuNode($id, null, $id_shop);
            if (!Validate::isLoadedObject($node)) {
                $errors[] = $this->trans('Nieprawidłowa pozycja menu.', [], 'Modules.Tc_nestedmenu.Admin');
            }
        } elseif (Tools::isSubmit('submitTcNestedmenuNode')) {
            $id_parent = (int) Tools::getValue('id_parent');
            if ($id_parent < 0) {
                $errors[] = $this->trans('Nieprawidłowy element nadrzędny.', [], 'Modules.Tc_nestedmenu.Admin');
            }
            if (Tools::getValue('id_tc_nestedmenu_node')) {
                $id = (int) Tools::getValue('id_tc_nestedmenu_node');
                $node = new Tc_NestedmenuNode($id, null, $id_shop);
                if (!Validate::isLoadedObject($node)) {
                    $errors[] = $this->trans('Nieprawidłowa pozycja menu.', [], 'Modules.Tc_nestedmenu.Admin');
                } else {
                    $bad = array_merge([$id], $this->getDescendantIds($id));
                    if (in_array($id_parent, $bad, true)) {
                        $errors[] = $this->trans('Element nie może być podrzędny względem samego siebie lub swojego potomka.', [], 'Modules.Tc_nestedmenu.Admin');
                    }
                }
            }
            if ($id_parent > 0) {
                $parentNode = new Tc_NestedmenuNode($id_parent, null, $id_shop);
                if (!Validate::isLoadedObject($parentNode)) {
                    $errors[] = $this->trans('Wybrany rodzic nie istnieje w tym sklepie.', [], 'Modules.Tc_nestedmenu.Admin');
                }
            }
            $defaultLang = (int) Configuration::get('PS_LANG_DEFAULT');
            $labelDef = trim((string) Tools::getValue('label_' . $defaultLang, ''));
            $linkDef = trim((string) Tools::getValue('link_' . $defaultLang, ''));
            if ($labelDef === '') {
                $errors[] = $this->trans('Podaj etykietę w domyślnym języku sklepu.', [], 'Modules.Tc_nestedmenu.Admin');
            }
            if ($linkDef === '') {
                $errors[] = $this->trans('Podaj link w domyślnym języku sklepu.', [], 'Modules.Tc_nestedmenu.Admin');
            }
            if (Tools::strlen($linkDef) > 512) {
                $errors[] = $this->trans('Link jest zbyt długi (max. 512 znaków).', [], 'Modules.Tc_nestedmenu.Admin');
            }
        }

        if (count($errors)) {
            $this->_html .= $this->displayError(implode('<br/>', $errors));

            return false;
        }

        return true;
    }

    protected function postProcess()
    {
        $id_shop = (int) $this->context->shop->id;

        if (Tools::isSubmit('delete_id_tc_nestedmenu_node')) {
            $id = (int) Tools::getValue('delete_id_tc_nestedmenu_node');
            if ($this->deleteNodeRecursive($id, $id_shop)) {
                Tools::redirectAdmin($this->context->link->getAdminLink('AdminModules', true)
                    . '&conf=1&configure=' . $this->name . '&tab_module=' . $this->tab . '&module_name=' . $this->name);
            }
            $this->_html .= $this->displayError($this->trans('Nie udało się usunąć.', [], 'Modules.Tc_nestedmenu.Admin'));

            return;
        }

        if (Tools::isSubmit('move_node')) {
            $id = (int) Tools::getValue('id_tc_nestedmenu_node');
            $dir = Tools::getValue('direction');
            if ($this->moveNodePosition($id, $dir, $id_shop)) {
                Tools::redirectAdmin($this->context->link->getAdminLink('AdminModules', true)
                    . '&conf=4&configure=' . $this->name . '&tab_module=' . $this->tab . '&module_name=' . $this->name);
            }
            $this->_html .= $this->displayError($this->trans('Nie można przesunąć tej pozycji.', [], 'Modules.Tc_nestedmenu.Admin'));

            return;
        }

        if (Tools::isSubmit('submitTcNestedmenuNode')) {
            $languages = Language::getLanguages(false);
            $id = (int) Tools::getValue('id_tc_nestedmenu_node');
            if ($id) {
                $node = new Tc_NestedmenuNode($id, null, $id_shop);
                if (!Validate::isLoadedObject($node)) {
                    $this->_html .= $this->displayError($this->trans('Nieprawidłowy ID.', [], 'Modules.Tc_nestedmenu.Admin'));

                    return;
                }
                $old_parent = (int) $node->id_parent;
            } else {
                // id_shop jest protected w ObjectModel — ustawiamy sklep wyłącznie przez konstruktor.
                $node = new Tc_NestedmenuNode(null, null, $id_shop);
                $old_parent = null;
            }

            $node->id_parent = (int) Tools::getValue('id_parent');
            $node->active = (int) (bool) Tools::getValue('active');
            $node->new_window = (int) (bool) Tools::getValue('new_window');

            foreach ($languages as $lang) {
                $lid = (int) $lang['id_lang'];
                $node->label[$lid] = trim((string) Tools::getValue('label_' . $lid, ''));
                $node->link[$lid] = trim((string) Tools::getValue('link_' . $lid, ''));
            }

            if ($id) {
                if ($old_parent !== (int) $node->id_parent) {
                    $node->position = (int) $node->getNextPosition($id_shop, (int) $node->id_parent);
                    $ok = $node->update();
                    if ($ok) {
                        $reorder = new Tc_NestedmenuNode();
                        $reorder->reorderSiblings($old_parent, $id_shop);
                    }
                } else {
                    $ok = $node->update();
                }
            } else {
                $ok = $node->add();
            }

            if ($ok) {
                Tools::redirectAdmin($this->context->link->getAdminLink('AdminModules', true)
                    . '&conf=4&configure=' . $this->name . '&tab_module=' . $this->tab . '&module_name=' . $this->name);
            }
            $this->_html .= $this->displayError($this->trans('Zapis nie powiódł się.', [], 'Modules.Tc_nestedmenu.Admin'));
        }
    }

    /**
     * Delete node and all descendants (deepest first).
     */
    protected function deleteNodeRecursive($id, $id_shop)
    {
        $id = (int) $id;
        $children = Db::getInstance()->executeS(
            'SELECT n.`id_tc_nestedmenu_node` FROM `' . _DB_PREFIX_ . 'tc_nestedmenu_node` n
            INNER JOIN `' . _DB_PREFIX_ . 'tc_nestedmenu_node_shop` ns ON n.`id_tc_nestedmenu_node` = ns.`id_tc_nestedmenu_node`
            WHERE n.`id_parent` = ' . $id . ' AND ns.`id_shop` = ' . (int) $id_shop
        );
        if ($children) {
            foreach ($children as $row) {
                if (!$this->deleteNodeRecursive((int) $row['id_tc_nestedmenu_node'], $id_shop)) {
                    return false;
                }
            }
        }
        $node = new Tc_NestedmenuNode($id, null, $id_shop);

        return Validate::isLoadedObject($node) && $node->delete();
    }

    protected function getDescendantIds($id)
    {
        $ids = [];
        $rows = Db::getInstance()->executeS(
            'SELECT `id_tc_nestedmenu_node` FROM `' . _DB_PREFIX_ . 'tc_nestedmenu_node` WHERE `id_parent` = ' . (int) $id
        );
        if (!$rows) {
            return $ids;
        }
        foreach ($rows as $row) {
            $cid = (int) $row['id_tc_nestedmenu_node'];
            $ids[] = $cid;
            $ids = array_merge($ids, $this->getDescendantIds($cid));
        }

        return $ids;
    }

    protected function moveNodePosition($nodeId, $direction, $id_shop)
    {
        $node = new Tc_NestedmenuNode((int) $nodeId, null, (int) $id_shop);
        if (!Validate::isLoadedObject($node)) {
            return false;
        }
        $parent = (int) $node->id_parent;
        $siblings = Db::getInstance()->executeS(
            'SELECT n.`id_tc_nestedmenu_node` FROM `' . _DB_PREFIX_ . 'tc_nestedmenu_node` n
            INNER JOIN `' . _DB_PREFIX_ . 'tc_nestedmenu_node_shop` ns ON n.`id_tc_nestedmenu_node` = ns.`id_tc_nestedmenu_node`
            WHERE n.`id_parent` = ' . $parent . ' AND ns.`id_shop` = ' . (int) $id_shop . '
            ORDER BY n.`position` ASC'
        );
        if (!$siblings) {
            return false;
        }
        $ids = array_map('intval', array_column($siblings, 'id_tc_nestedmenu_node'));
        $idx = array_search((int) $nodeId, $ids, true);
        if ($idx === false) {
            return false;
        }
        $swapWith = null;
        if ($direction === 'up' && $idx > 0) {
            $swapWith = $ids[$idx - 1];
        } elseif ($direction === 'down' && $idx < count($ids) - 1) {
            $swapWith = $ids[$idx + 1];
        }
        if ($swapWith === null) {
            return false;
        }
        $n1 = new Tc_NestedmenuNode((int) $nodeId, null, $id_shop);
        $n2 = new Tc_NestedmenuNode((int) $swapWith, null, $id_shop);
        if (!Validate::isLoadedObject($n1) || !Validate::isLoadedObject($n2)) {
            return false;
        }
        $p1 = (int) $n1->position;
        $p2 = (int) $n2->position;
        $n1->position = $p2;
        $n2->position = $p1;

        return $n1->update() && $n2->update();
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    protected function getFlatNodesForAdmin($id_shop, $id_lang)
    {
        $sql = new DbQuery();
        $sql->select('n.*, IFNULL(nl.`label`, "") AS `label`');
        $sql->from('tc_nestedmenu_node', 'n');
        $sql->innerJoin('tc_nestedmenu_node_shop', 'ns', 'n.`id_tc_nestedmenu_node` = ns.`id_tc_nestedmenu_node`');
        $sql->leftJoin(
            'tc_nestedmenu_node_lang',
            'nl',
            'n.`id_tc_nestedmenu_node` = nl.`id_tc_nestedmenu_node` AND nl.`id_lang` = ' . (int) $id_lang . ' AND nl.`id_shop` = ' . (int) $id_shop
        );
        $sql->where('ns.`id_shop` = ' . (int) $id_shop);

        return Db::getInstance()->executeS($sql) ?: [];
    }

    /**
     * @return array<int, list<array<string, mixed>>>
     */
    protected function groupChildrenByParent(array $rows)
    {
        $map = [];
        foreach ($rows as $r) {
            $pid = (int) $r['id_parent'];
            if (!isset($map[$pid])) {
                $map[$pid] = [];
            }
            $map[$pid][] = $r;
        }
        foreach ($map as &$list) {
            usort($list, static function ($a, $b) {
                return (int) $a['position'] - (int) $b['position'];
            });
        }

        return $map;
    }

    /**
     * HelperForm field values (multilang label/link). Uses POST after failed submit.
     *
     * @param int $id 0 = new node
     */
    protected function getNodeFormFieldsValues($id, $id_shop, $defaultParent, $node)
    {
        $languages = Language::getLanguages(false);
        if (isset($_POST['id_parent'])) {
            $idParent = (int) Tools::getValue('id_parent');
        } elseif ($node && Validate::isLoadedObject($node)) {
            $idParent = (int) $node->id_parent;
        } else {
            $idParent = (int) $defaultParent;
        }

        $fields = [
            'id_parent' => $idParent,
            'active' => (int) Tools::getValue('active', $node && Validate::isLoadedObject($node) ? $node->active : 1),
            'new_window' => (int) Tools::getValue('new_window', $node && Validate::isLoadedObject($node) ? $node->new_window : 0),
        ];
        if ($id) {
            $fields['id_tc_nestedmenu_node'] = $id;
        }
        foreach ($languages as $lang) {
            $lid = (int) $lang['id_lang'];
            $defLabel = ($node && Validate::isLoadedObject($node)) ? ($node->label[$lid] ?? '') : '';
            $defLink = ($node && Validate::isLoadedObject($node)) ? ($node->link[$lid] ?? '') : '';
            $fields['label'][$lid] = Tools::getValue('label_' . $lid, $defLabel);
            $fields['link'][$lid] = Tools::getValue('link_' . $lid, $defLink);
        }

        return $fields;
    }

    protected function renderTreeList()
    {
        $id_shop = (int) $this->context->shop->id;
        $id_lang = (int) $this->context->language->id;
        $rows = $this->getFlatNodesForAdmin($id_shop, $id_lang);
        $byParent = $this->groupChildrenByParent($rows);

        $addUrl = $this->context->link->getAdminLink('AdminModules', true)
            . '&configure=' . $this->name . '&tab_module=' . $this->tab . '&module_name=' . $this->name;

        $html = '<div class="panel">';
        $html .= '<h3><i class="icon icon-list"></i> ' . $this->trans('Struktura menu', [], 'Modules.Tc_nestedmenu.Admin') . '</h3>';
        $html .= '<p>' . $this->trans('Dodaj pozycje na najwyższym poziomie lub jako dzieci dowolnego elementu. Kolejność na danym poziomie zmieniasz strzałkami.', [], 'Modules.Tc_nestedmenu.Admin') . '</p>';
        $html .= '<a class="btn btn-primary" href="' . $addUrl . '&addNode=1"><i class="icon-plus"></i> '
            . $this->trans('Dodaj pozycję (poziom główny)', [], 'Modules.Tc_nestedmenu.Admin') . '</a>';
        $html .= '<table class="table table-bordered" style="margin-top:15px"><thead><tr>';
        $html .= '<th>' . $this->trans('Pozycja', [], 'Modules.Tc_nestedmenu.Admin') . '</th>';
        $html .= '<th>' . $this->trans('Aktywna', [], 'Modules.Tc_nestedmenu.Admin') . '</th>';
        $html .= '<th>' . $this->trans('Akcje', [], 'Modules.Tc_nestedmenu.Admin') . '</th>';
        $html .= '</tr></thead><tbody>';

        $renderBranch = function ($parentId, $depth) use (&$renderBranch, &$html, $byParent, $addUrl) {
            if (empty($byParent[$parentId])) {
                return;
            }
            foreach ($byParent[$parentId] as $r) {
                $id = (int) $r['id_tc_nestedmenu_node'];
                $indent = str_repeat('&nbsp;&nbsp;&nbsp;', $depth);
                $label = $indent . htmlspecialchars($r['label'] !== '' ? $r['label'] : ('#' . $id), ENT_QUOTES, 'UTF-8');
                $active = (int) $r['active'] ? '✓' : '—';
                $token = Tools::getAdminTokenLite('AdminModules');
                $base = $this->context->link->getAdminLink('AdminModules', true)
                    . '&configure=' . $this->name . '&tab_module=' . $this->tab . '&module_name=' . $this->name . '&token=' . $token;

                $html .= '<tr><td>' . $label . '</td><td>' . $active . '</td><td>';
                $html .= '<a class="btn btn-default btn-sm" href="' . $base . '&id_tc_nestedmenu_node=' . $id . '"><i class="icon-edit"></i> '
                    . $this->trans('Edytuj', [], 'Modules.Tc_nestedmenu.Admin') . '</a> ';
                $html .= '<a class="btn btn-default btn-sm" href="' . $addUrl . '&addChild=' . $id . '"><i class="icon-plus"></i> '
                    . $this->trans('Dodaj dziecko', [], 'Modules.Tc_nestedmenu.Admin') . '</a> ';
                $html .= '<a class="btn btn-default btn-sm" href="' . $base . '&move_node=1&id_tc_nestedmenu_node=' . $id . '&direction=up"><i class="icon-arrow-up"></i></a> ';
                $html .= '<a class="btn btn-default btn-sm" href="' . $base . '&move_node=1&id_tc_nestedmenu_node=' . $id . '&direction=down"><i class="icon-arrow-down"></i></a> ';
                $html .= '<a class="btn btn-danger btn-sm" href="' . $base . '&delete_id_tc_nestedmenu_node=' . $id . '" onclick="return confirm(\''
                    . $this->trans('Usunąć tę pozycję wraz z podmenu?', [], 'Modules.Tc_nestedmenu.Admin') . '\');"><i class="icon-trash"></i> '
                    . $this->trans('Usuń', [], 'Modules.Tc_nestedmenu.Admin') . '</a>';
                $html .= '</td></tr>';
                $renderBranch($id, $depth + 1);
            }
        };
        $renderBranch(0, 0);

        if (empty($rows)) {
            $html .= '<tr><td colspan="3">' . $this->trans('Brak pozycji — dodaj pierwszą.', [], 'Modules.Tc_nestedmenu.Admin') . '</td></tr>';
        }

        $html .= '</tbody></table></div>';
        $html .= '<div class="alert alert-info">' . $this->trans('Po zainstalowaniu modułu wyłącz moduł „Główne menu” (ps_mainmenu), żeby nie duplikować menu w nagłówku. W motywie hook displayTop powinien wskazywać na tc_nestedmenu zamiast ps_mainmenu.', [], 'Modules.Tc_nestedmenu.Admin') . '</div>';

        return $html;
    }

    protected function renderNodeForm()
    {
        $id_shop = (int) $this->context->shop->id;
        $id_lang = (int) $this->context->language->id;
        $rows = $this->getFlatNodesForAdmin($id_shop, $id_lang);
        $byParent = $this->groupChildrenByParent($rows);

        $id = (int) Tools::getValue('id_tc_nestedmenu_node');
        $default_parent = (int) Tools::getValue('addChild');

        $excludeSubtree = $id ? array_merge([$id], $this->getDescendantIds($id)) : [];

        $parentChoices = [];
        $parentChoices[] = [
            'id_option' => 0,
            'name' => $this->trans('— Poziom główny —', [], 'Modules.Tc_nestedmenu.Admin'),
        ];
        $walk = function ($parentId, $depth) use (&$walk, $byParent, &$parentChoices, $excludeSubtree) {
            if (empty($byParent[$parentId])) {
                return;
            }
            foreach ($byParent[$parentId] as $r) {
                $nid = (int) $r['id_tc_nestedmenu_node'];
                if (in_array($nid, $excludeSubtree, true)) {
                    continue;
                }
                $name = str_repeat('— ', $depth) . ($r['label'] !== '' ? $r['label'] : ('#' . $nid));
                $parentChoices[] = ['id_option' => $nid, 'name' => $name];
                $walk($nid, $depth + 1);
            }
        };
        $walk(0, 0);

        $node = ($id && $this->nodeExistsInShop($id, $id_shop)) ? new Tc_NestedmenuNode($id, null, $id_shop) : null;

        $fields_form = [
            'form' => [
                'legend' => [
                    'title' => $id
                        ? $this->trans('Edycja pozycji menu', [], 'Modules.Tc_nestedmenu.Admin')
                        : $this->trans('Nowa pozycja menu', [], 'Modules.Tc_nestedmenu.Admin'),
                    'icon' => 'icon-link',
                ],
                'input' => [
                    [
                        'type' => 'select',
                        'label' => $this->trans('Element nadrzędny', [], 'Modules.Tc_nestedmenu.Admin'),
                        'name' => 'id_parent',
                        'options' => [
                            'query' => $parentChoices,
                            'id' => 'id_option',
                            'name' => 'name',
                        ],
                    ],
                    [
                        'type' => 'switch',
                        'label' => $this->trans('Aktywna', [], 'Modules.Tc_nestedmenu.Admin'),
                        'name' => 'active',
                        'is_bool' => true,
                        'values' => [
                            ['id' => 'active_on', 'value' => 1, 'label' => $this->trans('Tak', [], 'Modules.Tc_nestedmenu.Admin')],
                            ['id' => 'active_off', 'value' => 0, 'label' => $this->trans('Nie', [], 'Modules.Tc_nestedmenu.Admin')],
                        ],
                    ],
                    [
                        'type' => 'switch',
                        'label' => $this->trans('Nowa karta', [], 'Modules.Tc_nestedmenu.Admin'),
                        'name' => 'new_window',
                        'is_bool' => true,
                        'values' => [
                            ['id' => 'nw_on', 'value' => 1, 'label' => $this->trans('Tak', [], 'Modules.Tc_nestedmenu.Admin')],
                            ['id' => 'nw_off', 'value' => 0, 'label' => $this->trans('Nie', [], 'Modules.Tc_nestedmenu.Admin')],
                        ],
                    ],
                ],
                'submit' => [
                    'title' => $this->trans('Zapisz', [], 'Modules.Tc_nestedmenu.Admin'),
                    'name' => 'submitTcNestedmenuNode',
                ],
            ],
        ];

        $fields_form['form']['input'][] = [
            'type' => 'text',
            'label' => $this->trans('Etykieta', [], 'Modules.Tc_nestedmenu.Admin'),
            'name' => 'label',
            'lang' => true,
            'required' => true,
            'size' => 128,
        ];
        $fields_form['form']['input'][] = [
            'type' => 'text',
            'label' => $this->trans('Link (URL lub ścieżka, np. /kontakt)', [], 'Modules.Tc_nestedmenu.Admin'),
            'name' => 'link',
            'lang' => true,
            'required' => true,
            'size' => 512,
        ];

        if ($id) {
            $fields_form['form']['input'][] = [
                'type' => 'hidden',
                'name' => 'id_tc_nestedmenu_node',
            ];
        }

        $helper = new HelperForm();
        $helper->show_toolbar = false;
        $helper->table = 'tc_nestedmenu_node';
        $helper->module = $this;
        $helper->default_form_language = (int) Configuration::get('PS_LANG_DEFAULT');
        $helper->allow_employee_form_lang = Configuration::get('PS_BO_ALLOW_EMPLOYEE_FORM_LANG')
            ? (int) Configuration::get('PS_BO_ALLOW_EMPLOYEE_FORM_LANG') : 0;
        $helper->identifier = 'id_tc_nestedmenu_node';
        $helper->token = Tools::getAdminTokenLite('AdminModules');
        $helper->currentIndex = $this->context->link->getAdminLink('AdminModules', false)
            . '&configure=' . $this->name . '&tab_module=' . $this->tab . '&module_name=' . $this->name;
        $helper->submit_action = 'submitTcNestedmenuNode';
        $helper->title = '';
        $helper->tpl_vars = [
            'fields_value' => $this->getNodeFormFieldsValues(
                $id,
                $id_shop,
                $default_parent,
                $node
            ),
            'languages' => $this->context->controller->getLanguages(),
            'id_language' => $this->context->language->id,
        ];

        $backUrl = $this->context->link->getAdminLink('AdminModules', true)
            . '&configure=' . $this->name . '&tab_module=' . $this->tab . '&module_name=' . $this->name;

        $out = $helper->generateForm([$fields_form]);
        $out .= '<a class="btn btn-default" href="' . $backUrl . '"><i class="icon-arrow-left"></i> '
            . $this->trans('Wróć do listy', [], 'Modules.Tc_nestedmenu.Admin') . '</a>';

        return $out;
    }

    /**
     * Normalize href for storefront (relative vs absolute).
     */
    public function normalizeMenuLink($raw)
    {
        $raw = trim((string) $raw);
        if ($raw === '' || $raw === '#') {
            return '#';
        }
        if (preg_match('#^https?://#i', $raw)) {
            return $raw;
        }
        $base = rtrim($this->context->link->getBaseLink(), '/');
        if ($raw[0] === '/') {
            return $base . $raw;
        }

        return $base . '/' . ltrim($raw, '/');
    }

    /**
     * @return list<array<string, mixed>>
     */
    protected function buildMenuNodesForContext($id_shop, $id_lang)
    {
        $sql = new DbQuery();
        $sql->select('n.*, nl.`label`, nl.`link`');
        $sql->from('tc_nestedmenu_node', 'n');
        $sql->innerJoin('tc_nestedmenu_node_shop', 'ns', 'n.`id_tc_nestedmenu_node` = ns.`id_tc_nestedmenu_node`');
        $sql->innerJoin(
            'tc_nestedmenu_node_lang',
            'nl',
            'n.`id_tc_nestedmenu_node` = nl.`id_tc_nestedmenu_node` AND nl.`id_lang` = ' . (int) $id_lang . ' AND nl.`id_shop` = ' . (int) $id_shop
        );
        $sql->where('ns.`id_shop` = ' . (int) $id_shop);
        $sql->where('n.`active` = 1');
        $rows = Db::getInstance()->executeS($sql);
        if (!$rows) {
            return [];
        }
        $byParent = $this->groupChildrenByParent($rows);

        $build = function ($parentId, $depth) use (&$build, $byParent) {
            $out = [];
            if (empty($byParent[$parentId])) {
                return $out;
            }
            foreach ($byParent[$parentId] as $r) {
                $id = (int) $r['id_tc_nestedmenu_node'];
                $children = $build($id, $depth + 1);
                $label = (string) $r['label'];
                $linkRaw = (string) $r['link'];
                if ($label === '') {
                    $label = '#' . $id;
                }
                if ($linkRaw === '') {
                    $linkRaw = '#';
                }
                $out[] = [
                    'type' => 'link',
                    'page_identifier' => 'tc-nested-' . $id,
                    'label' => $label,
                    'url' => $this->normalizeMenuLink($linkRaw),
                    'open_in_new_window' => (bool) (int) $r['new_window'],
                    'current' => false,
                    'depth' => $depth,
                    'children' => $children,
                    'image_urls' => [],
                ];
            }

            return $out;
        };

        // Depth 1 = top-level links (zgodnie z mapTree w ps_mainmenu).
        return $build(0, 1);
    }

    public function getWidgetVariables($hookName = null, array $configuration = [])
    {
        $id_shop = (int) $this->context->shop->id;
        $id_lang = (int) $this->context->language->id;
        $children = $this->buildMenuNodesForContext($id_shop, $id_lang);
        if ($children === []) {
            return [];
        }

        return [
            'menu' => [
                'type' => 'root',
                'label' => null,
                'page_identifier' => 'tc-nested-root',
                'children' => $children,
                'depth' => 0,
            ],
        ];
    }

    public function renderWidget($hookName = null, array $configuration = [])
    {
        $variables = $this->getWidgetVariables($hookName, $configuration);
        if ($variables === []) {
            return '';
        }
        $this->smarty->assign($variables);

        return $this->fetch($this->templateFile);
    }

    public function hookDisplayTop(array $params)
    {
        return $this->renderWidget('displayTop', $params);
    }
}
