<?php

include_once($BASE_DIR . 'database/users.php');
include_once($BASE_DIR . 'database/groups.php');

function getMemberNotifications($id, $dateLimit, $numLimit)
{
    global $conn;
    global $BASE_URL;

    $stmt = $conn->prepare("SELECT * FROM get_member_notifications(:id, :date, :limit)");
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
                $stmt = $conn->prepare('SELECT idAuthor, name, description FROM Model WHERE id = :id');
                $stmt->execute(array(':id' => $idModel));
                $result = $stmt->fetch();
                $idAuthor = $result['idauthor'];
                $modelName = $result['name'];
                $description = $result['description'];
                $user = getMember($idAuthor, 0);
                $userName = $user['name'];
                $userLink = $BASE_URL . "members/$idAuthor";
                $modelLink = $BASE_URL . "models/$idModel";
                $r['icon'] = 'fa fa-file-image-o bg-yellow';
                $r['title'] = "<a href=\"$userLink\">$userName</a> published the model <a href=\"$modelLink\">$modelName</a>";
                $r['text'] = $description;
                $r['subtext'] = "<a href=\"$modelLink\" class=\"btn btn-warning btn-xs\">View Model</a>";
                break;
            case 'GroupInvite':
                $idGroupInvite = $r['idgroupinvite'];
                $stmt = $conn->prepare('SELECT idGroup, idSender FROM GroupInvite WHERE id = :id');
                $stmt->execute(array(':id' => $idGroupInvite));
                $result = $stmt->fetch();
                $groupId = $result['idgroup'];
                $group = getGroup($groupId);
                $groupName = $group['name'];
                $groupLink = $BASE_URL . "groups/$groupId";
                $groupAbout = $group['about'];
                $userId = $result['idsender'];
                $user = getMember($userId, 0);
                $userName = $user['name'];
                $userLink = $BASE_URL . "members/$userId";
                $r['icon'] = 'fa fa-group bg-maroon';
                $r['title'] = "You were invited to group <a href=\"$groupLink\">$groupName</a> by <a href=\"$userLink\">$userName</a>";
                $r['text'] = $groupAbout;
                // TODO: links
                $r['subtext'] = "<a href=\"$groupLink\" class=\"btn bg-maroon btn-xs\">View Group</a> <a class=\"btn btn-primary btn-xs\">Accept</a> <a class=\"btn btn-danger btn-xs\">Decline</a>";
                break;
            case 'GroupApplication':
                $idGroupApplication = $r['idgroupapplication'];
                $stmt = $conn->prepare('SELECT idGroup, idMember FROM GroupApplication WHERE id = :id');
                $stmt->execute(array(':id' => $idGroupApplication));
                $result = $stmt->fetch();
                $groupId = $result['idgroup'];
                $group = getGroup($groupId);
                $groupName = $group['name'];
                $groupLink = $BASE_URL . "groups/$groupId";
                $groupAbout = $group['about'];
                $userId = $result['idmember'];
                $user = getMember($userId, 0);
                $userName = $user['name'];
                $userLink = $BASE_URL . "members/$userId";
                $r['icon'] = 'ionicons ion-ios7-people bg-purple';
                $r['title'] = "<a href=\"$userLink\">$userName</a> applied to your group <a href=\"$groupLink\">$groupName</a>";
                $r['text'] = '';
                // TODO: links
                $r['subtext'] = "<a class=\"btn btn-primary btn-xs\">Accept</a> <a class=\"btn btn-danger btn-xs\">Decline</a>";
                break;
            case 'FriendshipInvite':
                $friendshipInviteId = $r['idfriendshipinvite'];
                $stmt = $conn->prepare('SELECT idSender FROM FriendshipInvite WHERE id = :id');
                $stmt->execute(array(':id' => $friendshipInviteId));
                $userId = $stmt->fetch()['idsender'];
                $user = getMember($userId, 0);
                $userName = $user['name'];
                $userLink = $BASE_URL . "members/$userId";
                $userFriendLink = $BASE_URL . "members/friend/$userId";
                $r['icon'] = 'fa fa-user bg-aqua';
                $r['title'] = "<a href=\"$userLink\">$userName</a> has sent you a friend request";
                $r['text'] = '';
                // TODO: Links
                $r['subtext'] = "<a href=\"$userFriendLink\" class=\"btn btn-primary btn-xs\">Accept</a> <a href=\"$userFriendLink\" class=\"btn btn-danger btn-xs\">Decline</a>";
                break;
            case 'FriendshipInviteAccepted':
                $friendshipInviteId = $r['idfriendshipinvite'];
                $stmt = $conn->prepare('SELECT idSender FROM FriendshipInvite WHERE id = :id');
                $stmt->execute(array(':id' => $friendshipInviteId));
                $userId = $stmt->fetch()['idsender'];
                $user = getMember($userId, 0);
                $userName = $user['name'];
                $userLink = $BASE_URL . "members/$userId";
                $r['icon'] = 'fa fa-user bg-green';
                $r['title'] = "<a href=\"$userLink\">$userName</a> accepted your friend request";
                $r['text'] = '';
                $r['subtext'] = '';
                break;
        }

        $day = date('d M. Y', strtotime($r['createdate']));
        $newResult[$day][] = $r;
    }

    $newResult = array_reverse($newResult);

    return $newResult;
}
