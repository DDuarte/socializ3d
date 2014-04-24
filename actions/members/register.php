<?php
include_once('../../config/init.php');
include_once($BASE_DIR .'database/users.php');

if (!$_POST['username'] || !$_POST['realName'] || !$_POST['password'] || !$_POST['email'] || !$_POST['birthDate']) {
    $_SESSION['error_messages'][] = 'All fields are mandatory';
    $_SESSION['form_values'] = $_POST;
    header("Location: $BASE_URL" . 'register.php');
    exit;
}

$realName = strip_tags($_POST['realName']);
$username = strip_tags($_POST['username']);
$email = strip_tags($_POST['email']);
$birthDate = strip_tags($_POST['birthDate']);
$password = $_POST['password'];

try {
    createUser($username, $password, $email, $realName, $birthDate);
} catch (PDOException $e) {

    if (strpos($e->getMessage(), 'RegisteredUser_userName_uk') !== false)
    {
        $_SESSION['error_messages'][] = 'Duplicate username';
        $_SESSION['field_errors']['username'] = 'Username already exists';
    }
    else
        $_SESSION['error_messages'][] = 'Error creating user ' . $e->getMessage();

    $_SESSION['form_values'] = $_POST;
    header("Location: $BASE_URL" . 'register.php');
    exit;
}

$_SESSION['success_messages'][] = 'User registered successfully';
header("Location: $BASE_URL");
