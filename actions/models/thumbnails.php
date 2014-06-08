<?php

include_once($BASE_DIR . 'database/models.php');

class ModelThumbnailHandler {
    function post($modelId) { // TODO: xhr
        global $BASE_DIR;
        global $smarty;

        error_log("here");

        $memberId = getLoggedId();
        if (!$memberId) {
            http_response_code(409);
            return;
        }

        $data = $_POST['image'];
        if (!isset($data)) {
            error_log("No image");
            http_response_code(401);
            return;
        }

        $model = getModel($modelId);
        $idAuthor = $model['idauthor'];
        if (!isset($idAuthor)) {
            error_log("Not the author");
            http_response_code(402);
            return;
        }

        if ($idAuthor != $memberId) {
            http_response_code(403);
            return;
        }

        list($type, $data) = explode(';', $data);
        list(, $data)      = explode(',', $data);
        $data = base64_decode($data);

        $baseDir = '/thumbnails/';
        $targetDir = $baseDir . $modelId . '.png';

        if(!is_dir($baseDir))
            mkdir($baseDir);

        if (file_put_contents($targetDir, $data, LOCK_EX) === false) {
            http_response_code(500);
            return;
        }

        http_response_code(200);
    }
}