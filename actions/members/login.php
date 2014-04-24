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

$usr = getIdIfLoginCorrect($username, $password);

if ($usr != false) {
    $_SESSION['id'] = $usr['id'];
    $_SESSION['isAdmin'] = $usr['isadmin'];
    $_SESSION['username'] = $username;
    $_SESSION['success_messages'][] = 'Login successful';
} else {
    $_SESSION['error_messages'][] = 'Login failed';
    header("Location: " + $BASE_URL . "login.php");
}

if (isset($_SESSION['PREV_HTTP_REFERER']) && $_SESSION['PREV_HTTP_REFERER'] != null) {
    header('Location: ' . $_SESSION['PREV_HTTP_REFERER']);
    unset($_SESSION['PREV_HTTP_REFERER']);
} else {
    header('Location: ' . $BASE_URL);
}