<?php

include_once('../config/init.php');

include_once($BASE_DIR . 'lib/Toro.php');

include_once($BASE_DIR . 'actions/indexAction.php');
include_once($BASE_DIR . 'actions/catalogActions.php');
include_once($BASE_DIR . 'actions/models/model.php');
include_once($BASE_DIR . 'actions/models/comments.php');
include_once($BASE_DIR . 'actions/members/member.php');

$handle_404 = create_function('', 'global $BASE_DIR; global $smarty; include($BASE_DIR . "pages/404.php");');

ToroHook::add("404", $handle_404);

$handle_404_xhr = create_function('', 'global $smarty; $smarty->display("common/404.tpl");');

ToroHook::add("404_xhr", $handle_404_xhr);

Toro::serve(array(
    "/catalog" => "IndexHandler",
    "/hot/:number" => "HotHandler",
    "/top/:number" => "TopHandler",
    "/new/:number" => "NewHandler",
    "/rand/:number" => "RandHandler",
    "/models/:number" => "ModelHandler",
    "/models/:number/comments" => "CommentsHandler",
    "/members/:number" => "MemberHandler"
));