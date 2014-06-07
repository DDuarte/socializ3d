<?php

include_once($BASE_DIR . 'database/users.php');
include_once($BASE_DIR . 'database/groups.php');

function getMemberUnreadNotifications($id, $dateLimit, $numLimit)
{
    global $conn;
    global $BASE_URL;

    $stmt = $conn->prepare("SELECT * FROM get_complete_member_notifications(:id, :date, :limit) WHERE seen = false;");
    $stmt->execute(array(
        ':id' => $id,
        ':date' => $dateLimit,
        ':limit' => $numLimit
    ));

    $result = $stmt->fetchAll();

    if ($result == false) return false;

    $newResult = parseUserNotifications($id, $result, false);

    return $newResult;
}

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

    $newResult = parseUserNotifications($id, $result, true);

    markUserNotificationsAsRead($id);
    return $newResult;
}

function parseUserNotifications($id, $result, $full)
{
    global $BASE_URL;
    $newResult = Array();
    foreach ($result as $r) {
        switch ($r['nottype']) {
            case 'Publication':
                $idModel = $r['idmodel'];
                $userName = $r['username'];
                $userLink = $BASE_URL . "members/" . $r['idmember'];
                $modelLink = $BASE_URL . "models/$idModel";
                $r['icon'] = 'fa fa-file-image-o bg-yellow';
                if ($full)
                    $r['title'] = "<a href=\"$userLink\">$userName</a> published the model <a href=\"$modelLink\">".$r['modelname']."</a>";
                else {
                    $r['title'] = "$userName published the model " . $r['modelname'];
                    break;
                }
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
                if ($full)
                    $r['title'] = "You were invited to group <a href=\"$groupLink\">$groupName</a> by <a href=\"$userLink\">$userName</a>";
                else {
                    $r['title'] = "You were invited to group $groupName by $userName";
                    break;
                }
                $r['text'] = $groupAbout;
                $accepted = $r['accepted'];
                if (is_null($accepted))
                    $r['subtext'] = "<a href=\"$groupLink\" class=\"btn bg-maroon btn-xs\">View Group</a> <button class=\"btn btn-primary btn-xs\" name=\"$groupId\" onclick=\"groupInviteReply(this, true);\" >Accept</button> <button class=\"btn btn-danger btn-xs\" name=\"$groupId\" onclick=\"groupInviteReply(this, false);\">Decline</button>";
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
                    if ($full)
                        $r['title'] = "<a href=\"$userLink\">$userName</a> applied to your group <a href=\"$groupLink\">$groupName</a>";
                    else {
                        $r['title'] = "$userName applied to your group $groupName";
                        break;
                    }
                    $r['text'] = '';
                    if (is_null($accepted))
                        $r['subtext'] = "<button class=\"btn btn-primary btn-xs\" name=\"$groupId $userId\" onclick=\"groupApplicationReply(this, true);\">Accept</button> <button class=\"btn btn-danger btn-xs\" name=\"$groupId $userId\" onclick=\"groupApplicationReply(this, false);\">Decline</button>";
                    else if ($accepted)
                        $r['subtext'] = 'This request was accepted.';
                    else
                        $r['subtext'] = 'This request was declined.';
                }
                else {
                    if ($full)
                        $r['title'] = "You applied to join group <a href=\"$groupLink\">$groupName</a>";
                    else {
                        $r['title'] = "You applied to join group $groupName";
                        break;
                    }
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
                if ($full)
                    $r['title'] = "<a href=\"$userLink\">$userName</a> has sent you a friend request";
                else {
                    $r['title'] = "$userName has sent you a friend request";
                    break;
                }
                $r['text'] = '';
                if (is_null($accepted))
                    $r['subtext'] = "<button class=\"btn btn-primary btn-xs\" name=\"$userId\" onclick=\"friendshipReply(this, true);\">Accept</button> <button class=\"btn btn-danger btn-xs\" name=\"$userId\" onclick=\"friendshipReply(this, false);\">Decline</button>";
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
                if ($full)
                    $r['title'] = "<a href=\"$userLink\">$userName</a> accepted your friend request";
                else {
                    $r['title'] = "$userName accepted your friend request";
                    break;
                }

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
                if ($full)
                    $r['title'] = "<a href=\"$userLink\">$userName</a> accepted your request to join <a href=\"$groupLink\">$groupName</a>";
                else {
                    $r['title'] = "$userName accepted your request to join $groupName";
                    break;
                }


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
                    if ($full)
                        $r['title'] = "Your application to join <a href=\"$groupLink\">$groupName</a> has been accepted";
                    else {
                        $r['title'] = "Your application to join $groupName has been accepted";
                        break;
                    }
                }
                else {
                    if ($full)
                        $r['title'] = "<a href=\"$userLink\">$userName</a>'s application to join <a href=\"$groupLink\">$groupName</a> has been accepted";
                    else {
                        $r['title'] = "$userName's application to join $groupName has been accepted";
                        break;
                    }
                }

                $r['text'] = '';
                $r['subtext'] = '';
                break;
        }

        if ($full) {
            $day = date('d M. Y', strtotime($r['createdate']));
            $newResult[$day][] = $r;
        }
        else {
            $newResult[] = $r;
        }
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
        switch ($r['nottype']) {
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

function markUserNotificationsAsRead($id)
{
    global $conn;

    $stmt = $conn->prepare("UPDATE UserNotification SET seen = true WHERE idMember = :id");
    $stmt->execute(array(':id' => $id));
}