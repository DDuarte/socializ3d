<?php

class IndexHandler {
    function get() {
        global $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/common/header.php');
        echo file_get_contents($BASE_DIR . 'pages/catalog.html');
        include($BASE_DIR . 'pages/common/footer.php');
    }
}