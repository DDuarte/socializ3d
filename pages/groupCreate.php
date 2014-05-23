<?php

if (!isset($BASE_DIR))
    include_once("../../config/init.php");

$memberId = getLoggedId();

if ($memberId == null) {
    header('HTTP/1.0 403 Forbidden');
    exit('Not authenticated.');
}

$smarty->display('groups/create.tpl');
