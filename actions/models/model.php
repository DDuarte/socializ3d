<?php

include_once($BASE_DIR . 'database/models.php');

function getModelPage($model) {
    global $smarty;
    $smarty->assign('model', $model);
    $smarty->display('models/model.tpl');
}

class ModelHandler {
    function get($modelId) {
        global $smarty;
        global $BASE_DIR;

        if (!isModelVisibleToMember($modelId, getLoggedId())) {
            http_response_code(404);
            return;
        }

        $model = getModel($modelId);
        if ($model == false) {
            http_response_code(404);
            return;
        }

        include($BASE_DIR . 'pages/common/header.php');
        getModelPage($model);
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function get_xhr($modelId) {
        global $BASE_DIR;
        global $smarty;

        if (!isModelVisibleToMember($modelId, getLoggedId())) {
            http_response_code(404);
            return;
        }

        $model = getModel($modelId);
        if ($model == false) {
            http_response_code(404);
            return;
        }

        getModelPage($model);
    }

    function post($modelId) {
        $model = getModel($modelId);

        $loggedId = getLoggedId();
        $authorId = intval($model['idauthor']);

        if ($loggedId != $authorId && !loggedIsAdmin()) {
            http_response_code(403);
            return;
        }

        if (!isset($_POST['name']) || !isset($_POST['about']) || !isset($_POST['tags'])) {
            return;
        }

        $name = $_POST['name'];
        $about = $_POST['about'];
        $tags = $_POST['tags'];
        $tagsArray = explode(',', $tags);

        foreach($tagsArray as $key => $value) {
            $tagsArray[$key] = trim($value);
        }

        global $conn;
        $stmt = $conn->prepare('UPDATE Model SET name = :name, description = :about WHERE id = :id');
        $stmt->execute(array(':id' => $modelId, ':name' => $name, ':about' => $about));

        $prevTags = getModelTags($modelId);
        $prevTagsNames = array();
        foreach($prevTags as $tag) array_push($prevTagsNames, $tag['name']);

        $toDelete = array_diff($prevTagsNames, $tagsArray);
        if (count($toDelete) > 0) {
            $stmt = $conn->prepare('DELETE FROM model_tags WHERE idModel = ? AND name IN (' . implode(',', array_fill(0, count($toDelete), '?')) . ")");
            $stmt->execute(array_merge(array($modelId), $toDelete));
        }

        $toInsert = array_diff($tagsArray, $prevTagsNames);
        if (count($toInsert) > 0) {
            $stmt = $conn->prepare('INSERT INTO model_tags VALUES (?, ?)');
            foreach ($toInsert as $newTag) {
                $stmt->execute(array($modelId, $newTag));
            }
        }

        header("Location: " . $_SERVER['HTTP_REFERER']);
    }

    function delete($modelId) {
        $model = getModel($modelId);

        $loggedId = getLoggedId();
        $authorId = intval($model['idauthor']);

        if ($loggedId != $authorId && !loggedIsAdmin()) {
            http_response_code(403);
            return;
        }

        global $conn;
        global $BASE_DIR;

        $stmt = $conn->prepare("DELETE FROM model WHERE id = ?");
        $stmt->execute(Array($modelId));

        $filename = $model['filname'];

        unlink($filename);
        unlink($BASE_DIR . 'thumbnail/' . $model['id'] . '.png');

    }
}
