<?php

include_once('../../config/init.php');
include_once($BASE_DIR . 'database/models.php');

if (!$_GET['id']) {
    $_SESSION['error_messages'][] = 'Undefined model';
    header("Location: $BASE_URL");
    exit;
}

$id = $_GET['id'];

$model = getModel($id);

$smarty->assign("model", $model);
$smarty->display('models/model.tpl');