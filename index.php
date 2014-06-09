<?php

include_once('config/init.php');

include_once($BASE_DIR . 'lib/Toro.php');
include_once($BASE_DIR . 'lib/PHPMailer/class.phpmailer.php');
include_once($BASE_DIR . 'lib/CompatUtils.php');

include_once($BASE_DIR . 'actions/indexAction.php');
include_once($BASE_DIR . 'actions/catalogActions.php');
include_once($BASE_DIR . 'actions/models/model.php');
include_once($BASE_DIR . 'actions/models/files.php');
include_once($BASE_DIR . 'actions/models/thumbnails.php');
include_once($BASE_DIR . 'actions/models/comments.php');
include_once($BASE_DIR . 'actions/models/votes.php');
include_once($BASE_DIR . 'actions/members/forgotpass.php');
include_once($BASE_DIR . 'actions/members/member.php');
include_once($BASE_DIR . 'actions/members/friend.php');
include_once($BASE_DIR . 'actions/uploadAction.php');
include_once($BASE_DIR . 'actions/groups/group.php');
include_once($BASE_DIR . 'actions/groups/invite.php');
include_once($BASE_DIR . 'actions/groups/application.php');
include_once($BASE_DIR . 'actions/groups/create.php');
include_once($BASE_DIR . 'actions/groups/members.php');
include_once($BASE_DIR . 'actions/admin/stats.php');
include_once($BASE_DIR . 'actions/notifications.php');
include_once($BASE_DIR . 'actions/searchAction.php');

function getErrorPage($code, $is_xhr) {
    switch ($code) {
        case (400):
            $title = "Bad Request";
            $message = "You have specified wrong parameters for the script.";
            break;
        case (403):
            $title = "Forbidden";
            $message = "You have to be logged in in order to access this page.";
            break;
        case (404):
            $title = "Oops! Page not found.";
            $message = "We could not find the page you were looking for.";
            break;
        case (410):
            $title = "Oops! This page no longer exists.";
            $message = "The page you requested no longer exists.";
            break;
        case (500):
            $title = "Oops! Something went wrong.";
            $message = "We will work on fixing that right away. ";
            break;
        default:
            $title = "Oops! An error occured.";
            $message = "An error occured. ";
            break;
    }

    global $smarty;
    global $BASE_DIR;

    if (!$is_xhr)
        include($BASE_DIR . 'pages/common/header.php');

    $smarty->assign('code', $code);
    $smarty->assign('title', $title);
    $smarty->assign('message', $message);

    $smarty->display("common/error.tpl");

    if (!$is_xhr)
        include($BASE_DIR . 'pages/common/footer.php');
}

$handle_400 = create_function('', 'getErrorPage(400, false);');
ToroHook::add("400", $handle_400);

$handle_400_xhr = create_function('', 'getErrorPage(400, true);');
ToroHook::add("400_xhr", $handle_400_xhr);

$handle_403 = create_function('', 'getErrorPage(403, false);');
ToroHook::add("403", $handle_403);

$handle_403_xhr = create_function('', 'getErrorPage(403, true);');
ToroHook::add("403_xhr", $handle_403_xhr);

$handle_404 = create_function('', 'getErrorPage(404, false);');
ToroHook::add("404", $handle_404);

$handle_404_xhr = create_function('', 'getErrorPage(404, true);');
ToroHook::add("404_xhr", $handle_404_xhr);

$handle_500 = create_function('', 'getErrorPage(500, false);');
ToroHook::add("500", $handle_500);

$handle_500_xhr = create_function('', 'getErrorPage(500, true);');
ToroHook::add("500_xhr", $handle_500_xhr);

$handle_410 = create_function('', 'getErrorPage(410, false);');
ToroHook::add("410", $handle_410);

$handle_410_xhr = create_function('', 'getErrorPage(410, true);');
ToroHook::add("410_xhr", $handle_410_xhr);

Toro::serve(array(
    '/' => 'IndexHandler',
    '/catalog' => 'IndexHandler',
    '/hot/:number' => 'HotHandler',
    '/top/:number' => 'TopHandler',
    '/new/:number' => 'NewHandler',
    '/rand/:number' => 'RandHandler',
    '/models/:number' => 'ModelHandler',
    '/models/:number/file' => 'ModelFilesHandler',
    '/models/:number/thumbnail' => 'ModelThumbnailHandler',
    '/models/:number/comments' => 'CommentsHandler',
    '/models/:number/comments/:number' => 'CommentsHandler',
    '/models/:number/votes' => 'VotesHandler',
    '/members/:number' => 'MemberHandler',
    '/members/:number/forgotpass' => 'ForgotPassHandler',
    '/members/friend/:number' => 'FriendsHandler',
    '/upload' => 'UploadHandler',
    '/groups/:number' => 'GroupHandler',
    '/groups/:number/invite/:number' => 'InvitationHandler',
    '/groups/:number/application/:number' => 'ApplicationHandler',
    '/groups/:number/members/:number' => 'GroupMemberHandler',
    '/groups/create' => 'GroupCreateHandler',
    '/admin/stats' => 'StatisticsHandler',
    '/notifications' => 'NotificationsHandler',
    '/search' => 'SearchHandler'
));
