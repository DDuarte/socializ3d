<?php
include_once('../../config/init.php');
include_once($BASE_DIR .'database/users.php');

if (!$_POST['username'] || !$_POST['realName'] || !$_POST['password'] || !$_POST['email'] || !$_POST['birthDate']) {
    $_SESSION['error_messages'][] = 'All fields are mandatory';
    $_SESSION['form_values'] = $_POST;
    header("Location: $BASE_URL" . 'register.php');
    exit;
}

$realName = stripslashes(strip_tags($_POST['realName']));
$username = stripslashes(strip_tags($_POST['username']));
$email = strip_tags($_POST['email']);
$birthDate = strip_tags($_POST['birthDate']);
$password = $_POST['password'];

try {
    createUser($username, $password, $email, $realName, $birthDate);
} catch (PDOException $e) {

    if (strpos($e->getMessage(), 'registereduser_username_uk') !== false)
    {
        $_SESSION['error_messages'][] = 'Duplicate Username';
        $_SESSION['field_errors']['username'] = 'Username already exists';
    }
    else if (strpos($e->getMessage(), 'registereduser_email_uk') !== false)
    {
        $_SESSION['error_messages'][] = 'Email already registered';
        $_SESSION['field_errors']['username'] = 'Email already in use';
    }
    else
        $_SESSION['error_messages'][] = 'Error creating user ' . $e->getMessage();

    $_SESSION['form_values'] = $_POST;
    header("Location: $BASE_URL" . 'register.php');
    exit;
}

$usr = getIdIfLoginCorrect($username, $password);

if ($usr != false) {
    $_SESSION['id'] = $usr['id'];
    $_SESSION['isAdmin'] = $usr['isadmin'];
    $_SESSION['username'] = $username;
    $_SESSION['success_messages'][] = 'Login successful';
} else {
    //$_SESSION['error_messages'][] = 'Something went (very) wrong :/';
    header("Location: " . $BASE_URL . "register.php");
    exit;
}

$_SESSION['success_messages'][] = 'User registered successfully';
header("Location: $BASE_URL");
