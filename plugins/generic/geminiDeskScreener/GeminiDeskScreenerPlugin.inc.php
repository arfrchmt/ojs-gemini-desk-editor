<?php
import('lib.pkp.classes.plugins.GenericPlugin');

class GeminiDeskScreenerPlugin extends GenericPlugin {
    public function register($category, $path, $mainContextId = null) {
        $success = parent::register($category, $path, $mainContextId);
        if ($success) {
            HookRegistry::register('LoadHandler', array($this, 'callbackLoadHandler'));
        }
        return $success;
    }

    public function getName() {
        return 'geminideskscreenerplugin';
    }

    public function getDisplayName() {
        return 'Gemini Universal Desk Screener';
    }

    public function getDescription() {
        return 'Modul pemeriksa kepatuhan template dan desk screening berbasis custom prompt menggunakan Google Gemini API.';
    }

    public function getActions($request, $verb) {
        $router = $request->getRouter();
        import('lib.pkp.classes.linkAction.request.AjaxModal');
        return array_merge(
            $this->getEnabled() ? array(
                new LinkAction(
                    'settings',
                    new AjaxModal(
                        $router->url($request, null, null, 'manage', null, array('verb' => 'settings', 'plugin' => $this->getName(), 'category' => 'generic')),
                        $this->getDisplayName()
                    ),
                    __('manager.plugins.settings'),
                    null
                ),
            ) : array(),
            parent::getActions($request, $verb)
        );
    }

    public function manage($args, $request) {
        $context = $request->getContext();
        $contextId = $context ? $context->getId() : CONTEXT_ID_NONE;

        if ($request->getUserVar('verb') === 'settings') {
            $this->import('GeminiDeskScreenerSettingsForm');
            $form = new GeminiDeskScreenerSettingsForm($this, $contextId);

            if ($request->getUserVar('save')) {
                $form->readInputData();
                $form->execute();
                return new JSONMessage(true);
            }

            $form->initData();
            return new JSONMessage(true, $form->fetch($request));
        }
        return parent::manage($args, $request);
    }

    public function callbackLoadHandler($hookName, $args) {
        $page = $args[0];
        if ($page === 'geminiDeskScreenerHandler') {
            $this->import('GeminiDeskScreenerHandler');
            define('HANDLER_CLASS', 'GeminiDeskScreenerHandler');
            return true;
        }
        return false;
    }
}
