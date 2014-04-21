<?php

include_once($BASE_DIR . 'database/models.php');

function getModelPage($modelId) {
    global $smarty;
    $model = getModel($modelId);
    $smarty->assign("model", $model);
    $smarty->display('models/model.tpl');
}

class ModelHandler {
    function get($modelId) {
        global $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/common/header.php');
        getModelPage($modelId);
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function get_xhr($modelId) {
        getModelPage($modelId);
    }
}