<?php

class UploadHandler
{
    function get()
    {
        global $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/common/header.php');
        include($BASE_DIR . 'pages/upload.php');
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function get_xhr()
    {
        global $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/upload.php');
    }
}
