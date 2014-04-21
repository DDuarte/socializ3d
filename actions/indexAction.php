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
            echo file_get_contents($BASE_DIR . 'pages/catalog.html');
            include($BASE_DIR . 'pages/common/footer.php');
        }
    }
}