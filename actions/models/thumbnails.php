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
            http_response_code(401);
            return;
        }

        $model = getModel($modelId);
        $idAuthor = $model['idauthor'];
        if (!isset($idAuthor)) {
            http_response_code(402);
            return;
        }

        if ($idAuthor != $memberId && !loggedIsAdmin()) {
            http_response_code(403);
            return;
        }

        list($type, $data) = explode(';', $data);
        list(, $data)      = explode(',', $data);
        $data = base64_decode($data);

        $baseDir = $BASE_DIR . 'thumbnails/';
        $targetDir = $baseDir . $modelId . '.png';

        if (!file_exists($baseDir)) {
            mkdir($baseDir);
            chmod($baseDir, 0755);
        }

        if (file_put_contents($targetDir, $data, LOCK_EX) === false) {
            http_response_code(500);
            return;
        }

        chmod($targetDir, 0755);

        http_response_code(200);
    }
}