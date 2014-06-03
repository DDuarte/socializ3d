<?php

include_once('config/init.php');

include_once($BASE_DIR . 'lib/Toro.php');

include_once($BASE_DIR . 'actions/indexAction.php');
include_once($BASE_DIR . 'actions/catalogActions.php');
include_once($BASE_DIR . 'actions/models/model.php');
include_once($BASE_DIR . 'actions/models/comments.php');
include_once($BASE_DIR . 'actions/models/votes.php');
include_once($BASE_DIR . 'actions/members/member.php');
include_once($BASE_DIR . 'actions/members/friend.php');
include_once($BASE_DIR . 'actions/uploadAction.php');
include_once($BASE_DIR . 'actions/groups/group.php');
include_once($BASE_DIR . 'actions/groups/create.php');
include_once($BASE_DIR . 'actions/admin/stats.php');
include_once($BASE_DIR . 'actions/notifications.php');


$handle_404 = create_function('', 'global $BASE_DIR; global $smarty; error_log("404"); include($BASE_DIR . "pages/404.php");');
ToroHook::add("404", $handle_404);

$handle_404_xhr = create_function('', 'global $BASE_DIR; error_log("404_xhr"); echo file_get_contents($BASE_DIR . "pages/404.html");');
ToroHook::add("404_xhr", $handle_404_xhr);

$handle_500 = create_function('', 'global $BASE_DIR; global $smarty; error_log("500"); include($BASE_DIR . "pages/500.php");');
ToroHook::add("500", $handle_500);

$handle_500_xhr = create_function('', 'global $BASE_DIR; error_log("500_xhr"); echo file_get_contents($BASE_DIR . "pages/500.html");');
ToroHook::add("500_xhr", $handle_500_xhr);

$handle_403 = create_function('', 'global $BASE_DIR; global $smarty; error_log("403"); include($BASE_DIR . "pages/403.php");');
ToroHook::add("403", $handle_403);

$handle_403_xhr = create_function('', 'global $BASE_DIR; error_log("403_xhr"); echo(file_get_contents($BASE_DIR . "pages/403.html"));');
ToroHook::add("403_xhr", $handle_403_xhr);

Toro::serve(array(
    '/' => 'IndexHandler',
    '/catalog' => 'IndexHandler',
    '/hot/:number' => 'HotHandler',
    '/top/:number' => 'TopHandler',
    '/new/:number' => 'NewHandler',
    '/rand/:number' => 'RandHandler',
    '/models/:number' => 'ModelHandler',
    '/models/:number/comments' => 'CommentsHandler',
    '/models/:number/comments/:number' => 'CommentsHandler',
    '/models/:number/votes' => 'VotesHandler',
    '/members/:number' => 'MemberHandler',
    '/members/friend/:number' => 'FriendsHandler',
    '/upload' => 'UploadHandler',
    '/groups/:number' => 'GroupHandler',
    '/groups/create' => 'GroupCreateHandler',
    '/admin/stats' => 'StatisticsHandler',
    '/notifications' => 'NotificationsHandler'
));
