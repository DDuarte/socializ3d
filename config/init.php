<?php
session_set_cookie_params(3600, '/~lbaw1313');
session_start();

$BASE_DIR = '/opt/lbaw/lbaw1313/public_html/proto/';
$BASE_URL = '/~lbaw1313/proto/';
$GRAVATAR_BASE_URL = 'http://www.gravatar.com/avatar/';

$conn = new PDO('pgsql:host=vdbm.fe.up.pt;dbname=lbaw1313', 'lbaw1313', 'sM553sn4');
$conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$conn->exec("SET SCHEMA 'proto'");

include_once($BASE_DIR . 'lib/smarty/Smarty.class.php');

$smarty = new Smarty;
$smarty->template_dir = $BASE_DIR . 'templates/';
$smarty->compile_dir = $BASE_DIR . 'templates_c/';

if(!isset($_SESSION['error_messages'])){ $_SESSION['error_messages'] = null; }
if(!isset($_SESSION['form_values'])){ $_SESSION['form_values'] = null; }
if(!isset($_SESSION['username'])){ $_SESSION['username'] = null; }
if(!isset($_SESSION['success_messages'])){ $_SESSION['success_messages'] = null; }
if(!isset($_SESSION['field_errors'])){ $_SESSION['field_errors'] = null; }

$smarty->assign('BASE_URL', $BASE_URL);
$smarty->assign('GRAVATAR_URL', $GRAVATAR_BASE_URL);
$smarty->assign('ERROR_MESSAGES', $_SESSION['error_messages']);
$smarty->assign('FIELD_ERRORS', $_SESSION['field_errors']);
$smarty->assign('SUCCESS_MESSAGES', $_SESSION['success_messages']);
$smarty->assign('FORM_VALUES', $_SESSION['form_values']);
$smarty->assign('USERNAME', $_SESSION['username']);

$smarty->assign('MEMBERS', 'members');
$smarty->assign('MODELS', 'models');
$smarty->assign('GROUPS', 'groups');

unset($_SESSION['success_messages']);
unset($_SESSION['error_messages']);
unset($_SESSION['field_errors']);
unset($_SESSION['form_values']);

$_SESSION['id'] = 1;
