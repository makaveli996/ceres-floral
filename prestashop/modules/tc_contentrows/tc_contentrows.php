<?php
/**
 * Purpose: Module rendering alternating content+image rows (repeater).
 * Used from: displayHome hook → views/templates/hook/displayHome.tpl.
 * Inputs: TC_CONTENT_ROWS_ROWS config (JSON: title, description, button_label, button_url, image).
 * Outputs: Section HTML with container-md, background --clr-gray.
 * Side effects: Image uploads saved to views/img/uploads/; JSON stored in Configuration.
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

use PrestaShop\PrestaShop\Core\Module\WidgetInterface;

class Tc_contentrows extends Module implements WidgetInterface
{
    private const CONF_ROWS = 'TC_CONTENT_ROWS_ROWS';

    public function __construct()
    {
        $this->name = 'tc_contentrows';
        $this->tab = 'front_office_features';
        $this->version = '1.0.0';
        $this->author = 'Rafal Majdan';
        $this->need_instance = 0;
        $this->bootstrap = true;
        $this->ps_versions_compliancy = ['min' => '8.0.0', 'max' => _PS_VERSION_];

        parent::__construct();

        $this->displayName = $this->trans('Wiersze treści', [], 'Modules.Tc_contentrows.Admin');
        $this->description = $this->trans('Powtarzalne sekcje content+zdjęcie na przemian (strona główna).', [], 'Modules.Tc_contentrows.Admin');
    }

    public function install()
    {
        $defaultRows = $this->getDefaultRows();
        foreach ($defaultRows as &$row) {
            $row['description'] = htmlspecialchars(
                (string) $row['description'],
                ENT_QUOTES | ENT_HTML5,
                'UTF-8'
            );
        }
        unset($row);

        return parent::install()
            && $this->registerHook('displayHome')
            && Configuration::updateValue(self::CONF_ROWS, json_encode($defaultRows));
    }

    public function uninstall()
    {
        return Configuration::deleteByName(self::CONF_ROWS)
            && parent::uninstall();
    }

    public function getContent()
    {
        $output = '';

        if (Tools::isSubmit('submitTcContentRows')) {
            if ($this->processConfigurationForm()) {
                $output .= $this->displayConfirmation(
                    $this->trans('Ustawienia zostały zapisane.', [], 'Modules.Tc_contentrows.Admin')
                );
            } else {
                $output .= $this->displayError(
                    $this->trans('Nie udało się zapisać ustawień.', [], 'Modules.Tc_contentrows.Admin')
                );
            }
        }

        $this->context->controller->addCSS($this->_path . 'views/css/admin.css');
        $this->context->controller->addJS($this->_path . 'views/js/admin.js');

        $this->context->smarty->assign([
            'form_action' => AdminController::$currentIndex . '&configure=' . $this->name . '&token=' . Tools::getAdminTokenLite('AdminModules'),
            'rows' => $this->getStoredRows(),
        ]);

        return $output . $this->display(__FILE__, 'views/templates/admin/configure.tpl');
    }

    public function hookDisplayHome($params)
    {
        return $this->renderWidget('displayHome', $params);
    }

    public function renderWidget($hookName, array $configuration)
    {
        $rows = $this->getStoredRows();
        if (empty($rows)) {
            return '';
        }

        $this->smarty->assign($this->getWidgetVariables($hookName, $configuration));

        return $this->fetch('module:tc_contentrows/views/templates/hook/displayHome.tpl');
    }

    public function getWidgetVariables($hookName, array $configuration)
    {
        return [
            'rows' => $this->getStoredRows(),
        ];
    }

    private function processConfigurationForm()
    {
        $rowsInput = Tools::getValue('rows', []);
        $storedRows = $this->getStoredRows();

        $rows = [];
        if (is_array($rowsInput)) {
            foreach ($rowsInput as $index => $rowInput) {
                if (!is_array($rowInput)) {
                    continue;
                }

                $title = trim((string) ($rowInput['title'] ?? ''));
                $description = (string) ($rowInput['description'] ?? '');
                $buttonLabel = trim((string) ($rowInput['button_label'] ?? ''));
                $buttonUrl = trim((string) ($rowInput['button_url'] ?? ''));
                $imageKeep = trim((string) ($rowInput['image_keep'] ?? ''));

                $uploadedImage = $this->uploadRowImage((string) $index);
                if (false === $uploadedImage) {
                    return false;
                }
                $image = $uploadedImage ?: $imageKeep;

                $rows[] = [
                    'title' => $title,
                    'description' => htmlspecialchars($description, ENT_QUOTES | ENT_HTML5, 'UTF-8'),
                    'button_label' => $buttonLabel,
                    'button_url' => $this->sanitizeUrl($buttonUrl),
                    'image' => $image,
                ];
            }
        }

        if (empty($rows)) {
            $rows = $this->getDefaultRows();
            foreach ($rows as &$row) {
                $row['description'] = htmlspecialchars(
                    (string) $row['description'],
                    ENT_QUOTES | ENT_HTML5,
                    'UTF-8'
                );
            }
            unset($row);
        }

        return Configuration::updateValue(self::CONF_ROWS, json_encode($rows));
    }

    private function uploadRowImage($index)
    {
        if (
            !isset($_FILES['rows_image']['name']) ||
            !isset($_FILES['rows_image']['name'][$index]) ||
            '' === $_FILES['rows_image']['name'][$index]
        ) {
            return '';
        }

        if (UPLOAD_ERR_OK !== (int) $_FILES['rows_image']['error'][$index]) {
            return false;
        }

        $file = [
            'name'     => $_FILES['rows_image']['name'][$index],
            'type'     => $_FILES['rows_image']['type'][$index],
            'tmp_name' => $_FILES['rows_image']['tmp_name'][$index],
            'error'    => $_FILES['rows_image']['error'][$index],
            'size'     => $_FILES['rows_image']['size'][$index],
        ];

        $validationError = ImageManager::validateUpload($file, 8000000);
        if ($validationError) {
            return false;
        }

        $extension = strtolower((string) pathinfo($file['name'], PATHINFO_EXTENSION));
        $filename = 'row-' . sha1(uniqid((string) mt_rand(), true)) . '.' . $extension;
        $destination = _PS_MODULE_DIR_ . $this->name . '/views/img/uploads/' . $filename;

        if (!move_uploaded_file($file['tmp_name'], $destination)) {
            return false;
        }

        return $this->_path . 'views/img/uploads/' . $filename;
    }

    private function getStoredRows()
    {
        $raw = Configuration::get(self::CONF_ROWS);
        $rows = json_decode((string) $raw, true);

        if (!is_array($rows) || empty($rows)) {
            return $this->getDefaultRows();
        }

        foreach ($rows as &$row) {
            $row['description'] = html_entity_decode(
                (string) ($row['description'] ?? ''),
                ENT_QUOTES | ENT_HTML5,
                'UTF-8'
            );
        }
        unset($row);

        return $rows;
    }

    private function sanitizeUrl($url)
    {
        if ('' === $url) {
            return '#';
        }

        if (Validate::isAbsoluteUrl($url) || strpos($url, '/') === 0) {
            return $url;
        }

        return '#';
    }

    private function getDefaultRows()
    {
        return [
            [
                'title' => 'Poznaj nas lepiej',
                'description' => '<p>Opowiedz nam o sobie i swojej historii.</p>',
                'button_label' => 'Więcej o nas',
                'button_url' => '#',
                'image' => '',
            ],
            [
                'title' => 'Załóż swoje konto firmowe i ciesz się unikalnymi cenami',
                'description' => '<p>Ciesz się unikalnymi cenami i specjalnymi ofertami dla firm.</p>',
                'button_label' => 'Dowiedz się więcej',
                'button_url' => '#',
                'image' => '',
            ],
        ];
    }
}
