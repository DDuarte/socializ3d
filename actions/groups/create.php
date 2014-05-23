<?php

class GroupCreateHandler
{
    function get()
    {
        global /** @noinspection PhpUnusedLocalVariableInspection */
        $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/common/header.php');
        include($BASE_DIR . 'pages/groupCreate.php');
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function get_xhr()
    {
        global /** @noinspection PhpUnusedLocalVariableInspection */
        $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/groupCreate.php');
    }
}
