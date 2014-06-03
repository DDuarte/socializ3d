<?php

if (!isset($BASE_DIR))
    include_once("../../config/init.php");

$memberId = getLoggedId();

if ($memberId == null) {
    http_response_code(403);
    exit('Not authenticated.');
}

$smarty->display('groups/create.tpl');
