<?php

if (!isset($BASE_DIR))
    include_once("../../config/init.php");

include_once($BASE_DIR . 'database/models.php');

$memberId = getLoggedId();

$prevSkip = $skip - 20;
$nextSkip = $skip + 20;

$models = getWhatsHotModels($memberId, 20, $skip);
$smarty->assign("active", "whatsHot");
$smarty->assign("models", $models);
$smarty->assign('skip', $skip);
$smarty->assign('prevSkip', $prevSkip);
$smarty->assign('nextSkip', $nextSkip);
$smarty->display('catalog/catalog.tpl');