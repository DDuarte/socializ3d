<?php

include_once("config/init.php");

$_SESSION['PREV_HTTP_REFERER'] = $_SERVER['HTTP_REFERER'];

$smarty->display('members/login.tpl');