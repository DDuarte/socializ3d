<?php

include_once('../../config/init.php');
include_once($BASE_DIR . 'database/users.php');

if (!$_POST['username'] || !$_POST['password']) {
    $_SESSION['error_messages'][] = 'Invalid login';
    $_SESSION['form_values'] = $_POST;
    header('Location: ' . $_SERVER['HTTP_REFERER']);
    exit;
}

$username = strip_tags($_POST['username']);
$password = $_POST['password'];

$id = getIdIfLoginCorrect($username, $password);

if ($id != false) {
    $_SESSION['id'] = $id;
    $_SESSION['username'] = $username;
    $_SESSION['success_messages'][] = 'Login successful';
} else {
    $_SESSION['error_messages'][] = 'Login failed';
}
header('Location: ' . $BASE_URL);