<?php

include_once('../../config/init.php');

if (session_destroy()) {
    header('Location: ' . $_SERVER['HTTP_REFERER']);
} else {
    http_response_code(500);
}
