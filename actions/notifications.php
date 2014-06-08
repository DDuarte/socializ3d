<?php

include_once($BASE_DIR .'database/notifications.php');

class NotificationsHandler
{
    function get_notifications_page($memberId) {
        global $smarty;

        $notifications = getMemberNotifications($memberId, '2010-01-01', 1000); // TODO: pagination
        $member = getMember($memberId, getLoggedId());
        $smarty->assign('member', $member);
        $smarty->assign('notifications', $notifications);
        $smarty->display('notifications.tpl');
    }

    function get()
    {
        $memberId = getLoggedId();

        if ($memberId == null) {
            http_response_code(403);
            return;
        }

        global $smarty;
        global $BASE_DIR;
        include($BASE_DIR . 'pages/common/header.php');
        $this->get_notifications_page($memberId);
        include($BASE_DIR . 'pages/common/footer.php');
    }

    function get_xhr()
    {
        $memberId = getLoggedId();

        if ($memberId == null) {
            http_response_code(403);
            return;
        }

        $this->get_notifications_page($memberId);
    }
}
