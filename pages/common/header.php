<?php

ob_start();
include($BASE_DIR . 'pages/users/navbar.php');
$navbar = ob_get_contents();
ob_end_clean();

ob_start();
include($BASE_DIR . 'pages/users/sidebar.php');
$sidebar = ob_get_contents();
ob_end_clean();

$smarty->assign('navbar', $navbar);
$smarty->assign('sidebar', $sidebar);

$smarty->display('common/header.tpl');
