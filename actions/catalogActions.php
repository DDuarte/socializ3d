<?php

class HotHandler {
    function get() {
        global $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/common/header.php');
        include($BASE_DIR . 'pages/catalogs/whats-hot.php');
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function get_xhr() {
        global $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/catalogs/whats-hot.php');
    }
}

class TopHandler {
    function get() {
        global $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/common/header.php');
        include($BASE_DIR . 'pages/catalogs/top-rated.php');
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function get_xhr() {
        global $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/catalogs/top-rated.php');
    }
}

class NewHandler {
    function get() {
        global $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/common/header.php');
        include($BASE_DIR . 'pages/catalogs/new.php');
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function get_xhr() {
        global $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/catalogs/new.php');
    }
}

class RandHandler {
    function get() {
        global $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/common/header.php');
        include($BASE_DIR . 'pages/catalogs/random.php');
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function get_xhr() {
        global $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/catalogs/random.php');
    }
}