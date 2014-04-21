<?php

class IndexHandler {
    function get() {
        if (!isset($_SESSION['id'])) {
            global $BASE_URL;
            header("Location: " . $BASE_URL . "promotional.html");
        } else {
            global $smarty;
            global $BASE_DIR;
            include($BASE_DIR . 'pages/common/header.php');
            include($BASE_DIR . 'pages/catalogs/whats-hot.php');
            include($BASE_DIR . 'pages/common/footer.php');
        }
    }

    function get_xhr() {
        if (!isset($_SESSION['id'])) {
            global $BASE_URL;
            header("Location: " . $BASE_URL . "promotional.html");
        } else {
            global $smarty;
            global $BASE_DIR;
            include($BASE_DIR . 'pages/catalogs/whats-hot.php');
        }
    }
}