<?php

if (!isset($BASE_DIR))
    include_once("../../config/init.php");

include_once($BASE_DIR . 'database/models.php');

$memberId = getLoggedId();

if (!isset($skip))
    $skip = 0;

$prevSkip = $skip - 20;

if ($prevSkip < 0)
    $prevSkip = 0;

$nextSkip = $skip + 20;

$models = getNewModels($memberId, 20, $skip);
$smarty->assign("active", "new");
$smarty->assign("models", $models);
$smarty->assign('skip', $skip);
$smarty->assign('prevSkip', $prevSkip);
$smarty->assign('nextSkip', $nextSkip);
$smarty->display('catalog/catalog.tpl');