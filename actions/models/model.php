<?php

include_once($BASE_DIR . 'database/models.php');

function getModelPage($model)
{
    global $smarty;
    $smarty->assign("model", $model);
    $smarty->display('models/model.tpl');
}

class ModelHandler
{
    function get($modelId)
    {
        global $smarty;
        global $BASE_DIR;

        if (!isModelVisibleToMember($modelId, getLoggedId())) {
            get404Page();
            return;
        }

        $model = getModel($modelId);
        if ($model == false) {
            get404Page();
            return;
        }

        include($BASE_DIR . 'pages/common/header.php');
        getModelPage($model);
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function get_xhr($modelId)
    {
        global $BASE_DIR;
        global $smarty;

        if (!isModelVisibleToMember($modelId, getLoggedId())) {
            get404Page_xhr();
            return;
        }

        $model = getModel($modelId);
        if ($model == false) {
            get404Page_xhr();
            return;
        }

        getModelPage($model);
    }
}