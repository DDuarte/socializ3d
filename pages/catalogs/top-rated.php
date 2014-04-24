<?php

if (!isset($BASE_DIR))
    include_once("../../config/init.php");

include_once($BASE_DIR . 'database/models.php');

$memberId = getLoggedId();

$models = getTopRatedModels($memberId, 20, 0);
$smarty->assign("active", "topRated");
$smarty->assign("models", $models);
$smarty->display('catalog/catalog.tpl');