<?php

include_once('config/init.php');

include_once($BASE_DIR . 'lib/Toro.php');

include_once($BASE_DIR . 'actions/indexAction.php');
include_once($BASE_DIR . 'actions/models/model.php');
include_once($BASE_DIR . 'actions/members/member.php');

ToroHook::add("404", function() {
    global $BASE_DIR;
    global $smarty;
    include($BASE_DIR . 'pages/404.php');
});

ToroHook::add("404_xhr", function() {
    global $BASE_DIR;
    echo file_get_contents($BASE_DIR . 'pages/404.html');
});

Toro::serve(array(
    "/" => "IndexHandler",
    "/model/:number" => "CompleteModelHandler",
    "/member/:number" => "CompleteMemberHandler"

));