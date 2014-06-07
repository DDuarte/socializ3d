<?php

include_once($BASE_DIR . 'database/users.php');
include_once($BASE_DIR . 'database/groups.php');

function getMemberNotifications($id, $dateLimit, $numLimit)
{
    global $conn;
    global $BASE_URL;

    $stmt = $conn->prepare("SELECT * FROM get_complete_member_notifications(:id, :date, :limit);");
    $stmt->execute(array(
        ':id' => $id,
        ':date' => $dateLimit,
        ':limit' => $numLimit
    ));

    $result = $stmt->fetchAll();

    if ($result == false) return false;

    $newResult = Array();
    foreach ($result as $r) {
        switch ($r['nottype']) {
            case 'Publication':
                $idModel = $r['idmodel'];
                $userName = $r['username'];
                $userLink = $BASE_URL . "members/" . $r['idmember'];
                $modelLink = $BASE_URL . "models/$idModel";
                $r['icon'] = 'fa fa-file-image-o bg-yellow';
                $r['title'] = "<a href=\"$userLink\">$userName</a> published the model <a href=\"$modelLink\">".$r['modelname']."</a>";
                $r['text'] = $r['modeldescription'];
                $r['subtext'] = "<a href=\"$modelLink\" class=\"btn btn-warning btn-xs\">View Model</a>";
                break;
            case 'GroupInvite':
                $groupId = $r['idgroup'];
                $groupName = $r['groupname'];
                $groupLink = $BASE_URL . "groups/$groupId";
                $groupAbout = $r['groupabout'];
                $userId = $r['idmember'];
                $userName = $r['username'];
                $userLink = $BASE_URL . "members/$userId";
                $r['icon'] = 'fa fa-group bg-maroon';
                $r['title'] = "You were invited to group <a href=\"$groupLink\">$groupName</a> by <a href=\"$userLink\">$userName</a>";
                $r['text'] = $groupAbout;
                $accepted = $r['accepted'];
                if (is_null($accepted))
                    $r['subtext'] = "<a href=\"$groupLink\" class=\"btn bg-maroon btn-xs\">View Group</a> <a href=\"#\" class=\"btn btn-primary btn-xs\" name=\"$groupId\" onclick=\"groupInviteReply(this, true);\" >Accept</a> <a href=\"#\" class=\"btn btn-danger btn-xs\" name=\"$groupId\" onclick=\"groupInviteReply(this, false);\">Decline</a>";
                else if($accepted)
                    $r['subtext'] = "You accepted this request";
                else
                    $r['subtext'] = "You rejected this request";

                break;
            case 'GroupApplication':
                $groupId = $r['idgroup'];
                $accepted = $r['accepted'];
                $groupName = $r['groupname'];
                $groupLink = $BASE_URL . "groups/$groupId";
                $userId = $r['idmember'];
                $userName = $r['username'];
                $userLink = $BASE_URL . "members/$userId";
                $r['icon'] = 'fa fa-group bg-purple';
                if ($userId !== getLoggedId()) {
                    $r['title'] = "<a href=\"$userLink\">$userName</a> applied to your group <a href=\"$groupLink\">$groupName</a>";
                    $r['text'] = '';
                    // TODO: links
                    if (is_null($accepted))
                        $r['subtext'] = "<a class=\"btn btn-primary btn-xs\">Accept</a> <a class=\"btn btn-danger btn-xs\">Decline</a>";
                    else if ($accepted)
                        $r['subtext'] = 'This request was accepted.';
                    else
                        $r['subtext'] = 'This request was declined.';
                }
                else {
                    $r['title'] = "You applied to join group <a href=\"$groupLink\">$groupName</a>";
                    $r['text'] = '';
                    if (is_null($accepted))
                        $r['subtext'] = "Your application has not yet been answered.";
                    else if ($accepted)
                        $r['subtext'] = 'This request was accepted.';
                    else
                        $r['subtext'] = 'This request was declined.';
                }
                break;
            case 'FriendshipInvite':
                $userId = $r['idmember'];
                $accepted = $r['accepted'];
                $userName = $r['username'];
                $userLink = $BASE_URL . "members/$userId";
                $userFriendLink = $BASE_URL . "members/friend/$userId";
                $r['icon'] = 'fa fa-user bg-aqua';
                $r['title'] = "<a href=\"$userLink\">$userName</a> has sent you a friend request";
                $r['text'] = '';
                // TODO: Links
                if (is_null($accepted))
                    $r['subtext'] = "<a href=\"$userFriendLink\" class=\"btn btn-primary btn-xs\">Accept</a> <a href=\"$userFriendLink\" class=\"btn btn-danger btn-xs\">Decline</a>";
                else if ($accepted)
                    $r['subtext'] = 'You accepted this request.';
                else
                    $r['subtext'] = 'You declined this request.';
                break;
            case 'FriendshipInviteAccepted':
                $userId = $r['idmember'];
                $userName = $r['username'];
                $userLink = $BASE_URL . "members/$userId";
                $r['icon'] = 'fa fa-user bg-green';
                $r['title'] = "<a href=\"$userLink\">$userName</a> accepted your friend request";

                $r['text'] = '';
                $r['subtext'] = '';
                break;
            case 'GroupInviteAccepted':
                $userId = $r['idmember'];

                $groupId = $r['idgroup'];
                $groupName = $r['groupname'];
                $groupLink = $BASE_URL . "groups/$groupId";
                $userName = $r['username'];
                $userLink = $BASE_URL . "members/$userId";
                $r['icon'] = 'fa fa-group bg-maroon';
                $r['title'] = "<a href=\"$userLink\">$userName</a> accepted your request to join <a href=\"$groupLink\">$groupName</a>";


                $r['text'] = '';
                $r['subtext'] = '';
                break;
            case 'GroupApplicationAccepted':
                $groupId = $r['idgroup'];
                $userId = $r['idmember'];

                $groupName = $r['groupname'];
                $groupLink = $BASE_URL . "groups/$groupId";

                $userName = $r['username'];
                $userLink = $BASE_URL . "members/$userId";
                $r['icon'] = 'fa fa-group bg-purple';
                if ($userId == $id) {
                    $r['title'] = "Your application to join <a href=\"$groupLink\">$groupName</a> has been accepted";
                }
                else {
                    $r['title'] = "<a href=\"$userLink\">$userName</a>'s application to join <a href=\"$groupLink\">$groupName</a> has been accepted";
                }

                $r['text'] = '';
                $r['subtext'] = '';
                break;
        }

        $day = date('d M. Y', strtotime($r['createdate']));
        $newResult[$day][] = $r;
    }

    return $newResult;
}

function getGroupNotifications($id, $dateLimit, $numLimit) {
    global $conn;
    global $BASE_URL;

    $stmt = $conn->prepare("SELECT * FROM get_complete_group_notifications(:id, :date, :limit)");
    $stmt->execute(array(
        ':id' => $id,
        ':date' => $dateLimit,
        ':limit' => $numLimit
    ));

    $result = $stmt->fetchAll();

    if ($result == false) return false;

    $newResult = Array();
    foreach ($result as $r) {
        switch ($r['nottype']) { //TODO
            case 'Publication':
                $idModel = $r['idmodel'];
                $idAuthor = $r['idmember'];
                $modelName = $r['modelname'];
                $userName = $r['username'];
                $userLink = $BASE_URL . "members/$idAuthor";
                $modelLink = $BASE_URL . "models/$idModel";
                $r['img'] = 'http://www.gravatar.com/avatar/' . $r['hash'] . '?s=50&d=identicon';
                $r['text'] = "<a href=\"$userLink\">$userName</a> published <a href=\"$modelLink\">$modelName</a>";
                break;
            case 'GroupApplication':
                $userId = $r['idmember'];
                $userName = $r['username'];
                $userLink = $BASE_URL . "members/$userId";
                $r['img'] = 'http://www.gravatar.com/avatar/' . $r['hash'] . '?s=50&d=identicon';
                $r['text'] = "<a href=\"$userLink\">$userName</a> applied to join this group";
                break;
            case 'GroupApplicationAccepted':
                $userId = $r['idmember'];
                $userName = $r['username'];
                $userLink = $BASE_URL . "members/$userId";
                $r['img'] = 'http://www.gravatar.com/avatar/' . $r['hash'] . '?s=50&d=identicon';
                $r['text'] = "<a href=\"$userLink\">$userName</a>'s application to join this group has been accepted";
                break;
            case 'GroupInvite':
                $userId = $r['idsender'];
                $userName = $r['senderusername'];
                $userLink = $BASE_URL . "members/$userId";
                $userId2 = $r['idmember'];
                $userName2 = $r['username'];
                $userLink2 = $BASE_URL . "members/$userId2";
                $r['img'] = 'http://www.gravatar.com/avatar/' . $r['hash'] . '?s=50&d=identicon';
                $r['text'] = "<a href=\"$userLink2\">$userName2</a> was invited by <a href=\"$userLink\">$userName</a> to join this group";
                break;
            case 'GroupInviteAccepted':
                $userId = $r['idmember'];
                $userName = $r['username'];
                $r['img'] = 'http://www.gravatar.com/avatar/' . $r['hash'] . '?s=50&d=identicon';
                $userLink = $BASE_URL . "members/$userId";
                $r['text'] = "<a href=\"$userLink\">$userName</a> accepted the invitation to join this group";
                break;
            default:
                $r['img'] = '';
                $r['text'] = '';
                break;
        }
        $newResult[] = $r;
    }

    return $newResult;
}

function getGroupUnansweredApplications($id) {
    global $conn;

    $stmt = $conn->prepare("SELECT GroupApplication.idMember AS id FROM Notification " .
        "JOIN GroupNotification ON GroupNotification.idGroup = :id AND GroupNotification.idNotification = Notification.id " .
        "JOIN GroupApplication ON GroupApplication.id = Notification.idGroupApplication " .
        "WHERE Notification.notificationType = 'GroupApplication' AND GroupApplication.accepted IS NULL;");

    $stmt->execute(array(':id' => $id));

    $result = $stmt->fetchAll();

    if ($result == false) return array();

    $newRes = array();
    foreach ($result as $r) {
        $mem = getSimpleMember($r['id'], 0);
        $r['username'] = $mem['username'];
        $newRes[] = $r;
    }


    return $newRes;
}