<?php
import('lib.pkp.classes.form.Form');

class GeminiDeskScreenerSettingsForm extends Form {
    public $plugin;
    public $contextId;

    public function __construct($plugin, $contextId) {
        parent::__construct($plugin->getTemplateResource('settingsForm.tpl'));
        $this->plugin = $plugin;
        $this->contextId = $contextId;
        $this->addCheck(new FormValidatorPost($this));
        $this->addCheck(new FormValidatorCSRF($this));
    }

    public function initData() {
        $pluginSettingsDao = DAORegistry::getDAO('PluginSettingsDAO');
        $savedPrompt = $pluginSettingsDao->getSetting($this->contextId, 'geminideskscreenerplugin', 'customPromptRule');
        if ($savedPrompt === null && $this->contextId != CONTEXT_ID_NONE) {
            $savedPrompt = $pluginSettingsDao->getSetting(CONTEXT_ID_NONE, 'geminideskscreenerplugin', 'customPromptRule');
        }
        $this->setData('customPromptRule', $savedPrompt !== null ? $savedPrompt : '');
    }

    public function readInputData() {
        $this->readUserVars(array('customPromptRule'));
    }

    public function fetch($request, $template = null, $display = false) {
        $templateMgr = TemplateManager::getManager($request);
        $templateMgr->assign('customPromptRule', $this->getData('customPromptRule'));
        return parent::fetch($request, $template, $display);
    }

    public function execute(...$functionArgs) {
        $pluginSettingsDao = DAORegistry::getDAO('PluginSettingsDAO');
        $promptValue = (string) $this->getData('customPromptRule');
        $pluginSettingsDao->updateSetting($this->contextId, 'geminideskscreenerplugin', 'customPromptRule', $promptValue, 'string');
        return true;
    }
}
