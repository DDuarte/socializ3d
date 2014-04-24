<?php

include_once($BASE_DIR . 'database/models.php');

function getModelPage($model) {
    global $smarty;
    $smarty->assign("model", $model);
    $smarty->display('models/model.tpl');
}

class ModelHandler {
    function get($modelId) {
        global $smarty;
        global $BASE_DIR;

        $model = getModel($modelId);
        if ($model == false) {
            include($BASE_DIR . "pages/404.php");
            exit;
        }

        include($BASE_DIR . 'pages/common/header.php');
        getModelPage($model);
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function get_xhr($modelId) {
        global $BASE_DIR;
        global $smarty;

        $model = getMember($modelId);
        if ($model == false) {
            $smarty->display("common/404.tpl");
            exit;
        }

        getModelPage($model);
    }
}