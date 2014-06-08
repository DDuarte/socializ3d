<?php
if (!isset($BASE_DIR))
    include_once('../../index.php');

include_once($BASE_DIR . 'database/users.php');

function getPassChangePage($member, $memHash) {
    global $smarty;

    $smarty->assign('member', $member);
    $smarty->assign('memHash', $memHash);
    $smarty->display('members/passchange.tpl');
}

class ForgotPassHandler
{
    function get ($id)
    {
        global $BASE_DIR;
        global $smarty;

        if (!isset($_GET['usrhash'])) {
            http_response_code(400);
            return;
        }

        $memHash = getMemberPassChangeHash($id);
        if (!$memHash) {
            http_response_code(404);
            return;
        }

        if ($memHash !== $_GET['usrhash']) {
            http_response_code(400);
            return;
        }

        $member = getSimpleMember($id, 0);
        if (!$member) {
            http_response_code(404);
            return;
        }
        include($BASE_DIR . 'pages/common/header.php');
        getPassChangePage($member, $memHash);
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function post($id) {
        global $BASE_URL;
        if ($id == null) {
            http_response_code(400);
            return;
        }

        $memberHash = getMemberPassChangeHash($id);
        if (!$memberHash) {
            http_response_code(404);
            return;
        }

        if (!isset($_POST['password']) || !isset($_POST['password2']) || !isset($_GET['usrhash'])) {
            http_response_code(400);
            return;
        }

        $oldPassword = $_POST['password'];
        $newPassword = $_POST['password2'];
        if ($oldPassword !== $newPassword || $memberHash !== $_GET['usrhash']) {
            http_response_code(400);
            return;
        }

        updateMemberPassword($id, $newPassword);
        header("Location: $BASE_URL" . "login.php");
    }
}