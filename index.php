<?php

include_once('config/init.php');

include_once($BASE_DIR . 'lib/Toro.php');

include_once($BASE_DIR . 'actions/indexAction.php');
include_once($BASE_DIR . 'actions/catalogActions.php');
include_once($BASE_DIR . 'actions/models/model.php');
include_once($BASE_DIR . 'actions/members/member.php');

function handle_404() {
    global $BASE_DIR;
    global $smarty;
    include($BASE_DIR . 'pages/404.php');
}

ToroHook::add("404", handle_404);

function handle_404_xhr() {
    global $BASE_DIR;
    echo file_get_contents($BASE_DIR . 'pages/404.html');
}

ToroHook::add("404_xhr", handle_404_xhr);

Toro::serve(array(
    "/" => "IndexHandler",
    "/catalog" => "IndexHandler",
    "/hot" => "HotHandler",
    "/top" => "TopHandler",
    "/pop" => "PopHandler",
    "/rand" => "RandHandler",
    "/models/:number" => "ModelHandler",
    "/members/:number" => "MemberHandler"

));