<?php
import('classes.handler.Handler');

class GeminiDeskScreenerHandler extends Handler {

    private function getEnvVariable($key, $default = null) {
        $envPath = Core::getBaseDir() . DIRECTORY_SEPARATOR . '.env';
        if (!file_exists($envPath) || !is_readable($envPath)) {
            $envPath = dirname(dirname(dirname(dirname(__FILE__)))) . DIRECTORY_SEPARATOR . '.env';
        }

        if (file_exists($envPath) && is_readable($envPath)) {
            $lines = file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
            foreach ($lines as $line) {
                $line = trim($line);
                if (empty($line) || strpos($line, '#') === 0) continue;
                if (strpos($line, '=') !== false) {
                    list($envKey, $envVal) = explode('=', $line, 2);
                    if (trim($envKey) === $key) {
                        return trim($envVal, " \t\n\r\0\x0B\"'");
                    }
                }
            }
        }
        $sysEnv = getenv($key);
        return ($sysEnv !== false) ? $sysEnv : $default;
    }

    private function getPromptFilePath() {
        return dirname(__FILE__) . DIRECTORY_SEPARATOR . 'prompt_rule.txt';
    }

    public function saveSettings($args, $request) {
        header('Content-Type: application/json');
        
        $prompt = (string) $request->getUserVar('customPromptRule');
        $context = $request->getContext();
        $contextId = $context ? $context->getId() : CONTEXT_ID_NONE;

        // 1. Simpan ke database
        $pluginSettingsDao = DAORegistry::getDAO('PluginSettingsDAO');
        $pluginSettingsDao->updateSetting($contextId, 'geminiDeskScreener', 'customPromptRule', $prompt, 'string');
        $pluginSettingsDao->updateSetting(CONTEXT_ID_NONE, 'geminiDeskScreener', 'customPromptRule', $prompt, 'string');

        // 2. Simpan cadangan ke file prompt_rule.txt
        @file_put_contents($this->getPromptFilePath(), $prompt);

        echo json_encode(array('status' => true, 'message' => 'Prompt Rule berhasil disimpan!'));
        exit;
    }

    public function getPromptSettings($args, $request) {
        header('Content-Type: application/json');
        $context = $request->getContext();
        $contextId = $context ? $context->getId() : CONTEXT_ID_NONE;

        $pluginSettingsDao = DAORegistry::getDAO('PluginSettingsDAO');
        $prompt = $pluginSettingsDao->getSetting($contextId, 'geminiDeskScreener', 'customPromptRule');
        if (empty($prompt)) {
            $prompt = $pluginSettingsDao->getSetting(CONTEXT_ID_NONE, 'geminiDeskScreener', 'customPromptRule');
        }

        if (empty($prompt) && file_exists($this->getPromptFilePath())) {
            $prompt = file_get_contents($this->getPromptFilePath());
        }

        echo json_encode(array('status' => true, 'prompt' => (string)$prompt));
        exit;
    }

    public function runScreening($args, $request) {
        header('Content-Type: application/json');

        $apiKey = $this->getEnvVariable('GEMINI_API_KEY');
        $model  = $this->getEnvVariable('GEMINI_MODEL', 'gemini-3.6-flash');

        if (empty($apiKey)) {
            echo json_encode(array('status' => false, 'message' => 'GEMINI_API_KEY tidak ditemukan di file .env.'));
            exit;
        }

        $context = $request->getContext();
        $contextId = $context ? $context->getId() : CONTEXT_ID_NONE;
        $submissionId = (int) $request->getUserVar('submissionId');

        $submissionDao = DAORegistry::getDAO('SubmissionDAO');
        $submission = $submissionDao->getById($submissionId, $contextId);

        if (!$submission) {
            echo json_encode(array('status' => false, 'message' => 'Naskah submission tidak ditemukan.'));
            exit;
        }

        // Ambil Prompt Rule
        $pluginSettingsDao = DAORegistry::getDAO('PluginSettingsDAO');
        $systemPrompt = $pluginSettingsDao->getSetting($contextId, 'geminiDeskScreener', 'customPromptRule');
        if (empty($systemPrompt)) {
            $systemPrompt = $pluginSettingsDao->getSetting(CONTEXT_ID_NONE, 'geminiDeskScreener', 'customPromptRule');
        }
        if (empty($systemPrompt) && file_exists($this->getPromptFilePath())) {
            $systemPrompt = file_get_contents($this->getPromptFilePath());
        }

        if (empty($systemPrompt)) {
            echo json_encode(array('status' => false, 'message' => 'Prompt Rule belum tersimpan di menu Settings plugin. Silakan buka Settings plugin dan klik Simpan.'));
            exit;
        }

        $title = (string) $submission->getLocalizedTitle();
        $abstract = (string) strip_tags($submission->getLocalizedAbstract());
        
        $promptPayload = "EVALUATE THIS MANUSCRIPT SUBMISSION:\n\n" .
                         "TITLE:\n" . $title . "\n\n" .
                         "ABSTRACT & METADATA:\n" . $abstract . "\n";

        $postData = array(
            'contents' => array(
                array(
                    'role' => 'user',
                    'parts' => array(
                        array('text' => $systemPrompt . "\n\n" . $promptPayload)
                    )
                )
            ),
            'generationConfig' => array(
                'response_mime_type' => 'application/json'
            )
        );

        $cleanModel = str_replace('models/', '', $model);
        $genUrl = 'https://generativelanguage.googleapis.com/v1beta/models/' . $cleanModel . ':generateContent?key=' . $apiKey;

        $chGen = curl_init($genUrl);
        curl_setopt($chGen, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($chGen, CURLOPT_POST, true);
        curl_setopt($chGen, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
        curl_setopt($chGen, CURLOPT_POSTFIELDS, json_encode($postData));
        curl_setopt($chGen, CURLOPT_SSL_VERIFYPEER, true);
        curl_setopt($chGen, CURLOPT_TIMEOUT, 60);
        $response = curl_exec($chGen);
        $httpCode = curl_getinfo($chGen, CURLINFO_HTTP_CODE);
        curl_close($chGen);

        if ($httpCode !== 200) {
            echo json_encode(array('status' => false, 'message' => 'Gemini API Error (HTTP ' . $httpCode . '): ' . $response));
            exit;
        }

        $resDecoded = json_decode($response, true);
        $rawOutput = '{}';
        if (isset($resDecoded['candidates'][0]['content']['parts'][0]['text'])) {
            $rawOutput = $resDecoded['candidates'][0]['content']['parts'][0]['text'];
        }

        echo json_encode(array(
            'status' => true,
            'submissionId' => $submissionId,
            'report' => json_decode($rawOutput, true)
        ));
        exit;
    }
}
