<?php

include_once('config/init.php');

if (isset($_SERVER['HTTP_REFERER'])) {
    if (substr_compare($_SERVER['HTTP_REFERER'], 'login.php', -strlen('login.php'), strlen('login.php')) != 0
        && substr_compare($_SERVER['HTTP_REFERER'], 'register.php', -strlen('register.php'), strlen('register.php')) != 0
    ) {
        $_SESSION['PREV_HTTP_REFERER'] = $_SERVER['HTTP_REFERER'];
    }

    if (substr_compare($_SERVER['HTTP_REFERER'], 'forgotpass.php', -strlen('login.php'), strlen('login.php')) != 0) {
        $_SESSION['PREV_HTTP_REFERER'] = $BASE_URL;
    }
}

$smarty->display('members/login.tpl');
