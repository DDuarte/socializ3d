<?php

include_once($BASE_DIR . 'database/models.php');

class ModelFilesHandler {
    function get($modelId) {
        global $BASE_DIR;
        global $smarty;

        if (!isModelVisibleToMember($modelId, getLoggedId())) {
            error_log("Not visible");
            http_response_code(404);
            return;
        }

        $model = getModel($modelId);
        if ($model == false) {
            error_log("Model doesn't exist.");
            http_response_code(404);
            return;
        }

        $file = $model['filename'];

        if (file_exists($file)) {
            header('Content-Description: File Transfer');
            header('Content-Type: ' . mime_content_type($file));
            header('Content-Disposition: attachment; filename='.basename($model['userfilename']));
            header('Expires: 0');
            header('Cache-Control: must-revalidate');
            header('Pragma: public');
            header('Content-Length: ' . filesize($file));
            ob_clean();
            flush();
            readfile($file);
            http_response_code(200);
            return;
        } else {
            http_response_code(404);
            return;
        }
    }
}
