<?php

if (!isset($BASE_DIR))
    include_once("../../config/init.php");

include_once($BASE_DIR . 'database/models.php');

$memberId = getLoggedId();

global $MODELS_PER_PAGE;

if (!isset($skip))
    $skip = 0;

$prevSkip = $skip - $MODELS_PER_PAGE;

if ($prevSkip < 0)
    $prevSkip = 0;

$nextSkip = $skip + $MODELS_PER_PAGE;

$models = getTopRatedModels($memberId, $MODELS_PER_PAGE, $skip);
$smarty->assign("active", "topRated");
$smarty->assign("models", $models);
$smarty->assign('skip', $skip);
$smarty->assign('prevSkip', $prevSkip);
$smarty->assign('nextSkip', $nextSkip);
$smarty->display('catalog/catalog.tpl');