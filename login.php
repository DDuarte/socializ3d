<?php

include_once("config/init.php");

if (substr_compare($_SERVER['HTTP_REFERER'], "login.php", -strlen("login.php"), strlen("login.php")) != 0)
    $_SESSION['PREV_HTTP_REFERER'] = $_SERVER['HTTP_REFERER'];

$smarty->display('members/login.tpl');