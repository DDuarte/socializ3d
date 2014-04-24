<?php

if (!isset($BASE_DIR))
    include_once("../../config/init.php");

include_once($BASE_DIR . 'database/models.php');

$memberId = $_SESSION['id'];

$models = getNewModels($memberId, 20, 0);
$smarty->assign("active", "new");
$smarty->assign("models", $models);
$smarty->display('catalog/catalog.tpl');