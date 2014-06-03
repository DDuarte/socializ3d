<?php

function getMember($id, $id2)
{
    global $conn;
    $stmt = $conn->prepare("SELECT Member.id,
                                   Member.name,
                                   Member.about,
                                   Member.birthDate,
                                   get_user_hash(:id) AS hash
                            FROM Member
                            WHERE Member.id = :id");
    $stmt->execute(array(':id' => $id));
    $result = $stmt->fetch();

    if ($result == false) return false;

    $result['models'] = getMemberModels($id);
    $result['friends'] = getFriendsOfMember($id);
    $result['myFriend'] = false;
    foreach ($result['friends'] as $key => $value) {
        if ($result['friends'][$key]['id'] == $id2) {
            $result['myFriend'] = true;
            break;
        }
    }

    $result['friendRequests'] = getUnansweredFriendRequestsOfMember($id);
    $result['sentRequest'] = false;
    foreach ($result['friendRequests'] as $value) {
        if ($value['idsender'] == $id2) {
            $result['sentRequest'] = true;
            break;
        }
    }

    $result['groups'] = getGroupsOfMember($id);
    $result['interests_array'] = getMemberInterests($id);
    $result['interests'] = implode(', ', $result['interests_array']);
    return $result;
}

function getMemberInterests($id) {
    global $conn;
    $stmt = $conn->prepare("SELECT name FROM user_tags WHERE idmember = :id;");
    $stmt->execute(array(':id' => $id));
    $result = $stmt->fetchAll();

    $resultNames = array();
    foreach($result as $interest) {
        array_push($resultNames, $interest['name']);
    }

    return $resultNames;

}

function getFriendsOfMember($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT memberid AS id, membername AS name, hash, about FROM get_complete_friends_of_member(:id)");
    $stmt->execute(array(':id' => $id));
    $result = $stmt->fetchAll();

    foreach ($result as $key => $value) {
        $result[$key]['isFriend'] = true;
    }

    return $result;
}

function getGroupsOfMember($id)
{
    global $conn;
    $stmt  = $conn->prepare("SELECT groupid AS id, groupname AS name, about, coverimg FROM get_complete_groups_of_member(:id)");
    $stmt->execute(array(':id' => $id));
    $result = $stmt->fetchAll();

    foreach ($result as $key => $value) {
        $result[$key]['memberInGroup'] = true;
    }

    return $result;
}

function getMemberModels($id)
{
    $loggedId = getLoggedId();

    global $conn;
    $stmt = $conn->prepare("SELECT *, (get_thumbnail_information(Model.id)).*, get_user_hash(Model.idAuthor) AS authorHash FROM Model JOIN get_all_visibile_models(:logged_id) USING (id) WHERE idAuthor = :id");
    $stmt->execute(array(':id' => $id, ':logged_id' => $loggedId));
    return $stmt->fetchAll();
}

function getMemberHash($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM get_user_hash(?)");
    $stmt->execute(array($id));
    $result = $stmt->fetch();
    return $result['get_user_hash'];
}

function isAdmin($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT 1 FROM RegisteredUser WHERE id = ? AND isadmin = TRUE");
    $stmt->execute(array($id));
    $result = $stmt->fetch();
    return $result;
}

function getUserSidebarInfo($id) {
    if ($id == null) return null;

    global $conn;
    $stmt = $conn->prepare("SELECT Member.name FROM Member WHERE Member.id = ?");
    $stmt->execute(array($id));
    $username = $stmt->fetch();
    $username = $username['name'];

    $stmt = $conn->prepare("SELECT * FROM get_complete_friends_of_member(?)");
    $stmt->execute(array($id));
    $friends = $stmt->fetchAll();

    $stmt = $conn->prepare("SELECT * FROM get_complete_groups_of_member(?)");
    $stmt->execute((array($id)));
    $groups = $stmt->fetchAll();

    $userHash = getMemberHash($id);

    $isAdmin = isAdmin($id);

    $result['userId'] = $id;
    $result['username'] = $username;
    $result['userHash'] = $userHash;
    $result['friends'] = $friends;
    $result['groups'] = $groups;
    $result['isAdmin'] = $isAdmin;

    return $result;
}

function getUserNavbarInfo($id) {
    if ($id == null) return null;

    global $conn;
    $stmt = $conn->prepare("SELECT Member.name FROM Member WHERE Member.id = ?");
    $stmt->execute(array($id));
    $username = $stmt->fetch();
    $username = $username['name'];

    $userHash = getMemberHash($id);

    $result['userId'] = $id;
    $result['username'] = $username;
    $result['userHash'] = $userHash;

    return $result;
}

function getIdIfLoginCorrect($username, $password)
{
    global $conn;
    $stmt = $conn->prepare("SELECT id, isadmin
                            FROM RegisteredUser JOIN Member USING(id)
                            WHERE deleteDate IS NULL AND username = ? AND passwordHash = ?");
    $stmt->execute(array($username, hash('sha256', $password)));
    $result = $stmt->fetch();

    if ($result == false){
        return false;
    } else {
        return $result;
    }
}

function createUser($username, $password, $email, $realName, $birthDate)
{
    global $conn;
    $stmt = $conn->prepare("SELECT add_member(:username, :passwordHash, :email, :realName, '', :birthDate);");
    $stmt->execute(array(':username' => $username,
                         ':passwordHash' => hash('sha256', $password),
                         ':email' => $email,
                         ':realName' => $realName,
                         ':birthDate' => $birthDate));
}

function updateUserAbout($memberId, $aboutInfo)
{
    global $conn;
    $stmt = $conn->prepare('UPDATE Member SET about = :about WHERE id = :id');
    $stmt->execute(array(':id' => $memberId, ":about" => $aboutInfo));
}

function deleteUserInterests($memberId, $toDelete)
{
    global $conn;
    if (count($toDelete) > 0) {
        $stmt = $conn->prepare('DELETE FROM user_tags WHERE idMember = ? AND name IN (' . implode(',', array_fill(0, count($toDelete), '?')) . ")");
        $stmt->execute(array_merge(array($memberId), $toDelete));
    }
}

function insertUserInterests($memberId, $toInsert)
{
    global $conn;
    if (count($toInsert) > 0) {
        $stmt = $conn->prepare('INSERT INTO user_tags VALUES (?, ?)');
        foreach ($toInsert as $newTag) {
            $stmt->execute(array($memberId, $newTag));
        }
    }
}

function checkPassword($memberId, $password)
{
    global $conn;
    $stmt = $conn->prepare("SELECT id
                            FROM RegisteredUser JOIN Member USING(id)
                            WHERE deleteDate IS NULL AND id = ? AND passwordHash = ?");
    $stmt->execute(array($memberId, hash('sha256', $password)));
    $result = $stmt->fetch();

    if ($result == false){
        return false;
    } else {
        return $result;
    }
}

function updateMemberPassword($memberId, $newPassword)
{
    global $conn;
    $stmt = $conn->prepare("UPDATE RegisteredUser SET passwordHash = ? WHERE id = ?");
    $stmt->execute(array(hash('sha256', $newPassword), $memberId));
}

function createFriendRequest($senderId, $receiverId)
{
    global $conn;
    $stmt = $conn->prepare("INSERT INTO FriendshipInvite(idReceiver, idSender) VALUES (?, ?)");
    $stmt->execute(array($receiverId, $senderId));
}

function deleteFriendship($member1, $member2)
{
    global $conn;
    $stmt = $conn->prepare("DELETE FROM Friendship WHERE idMember1 = :idMember1 AND idMember2 = :idMember2;");
    $stmt->execute(array($member1, $member2));
}

function getUnansweredFriendRequestsOfMember($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT id, idReceiver, idSender FROM FriendshipInvite WHERE idReceiver = :id AND accepted IS NULL");
    $stmt->execute(array(':id' => $id));
    $result = $stmt->fetchAll();

    return $result;
}

function answerFriendshipInvite($friendshipInviteId, $answer)
{
    global $conn;
    $stmt = $conn->prepare("UPDATE FriendshipInvite SET accepted = :accepted WHERE FriendshipInvite.id = :id;");
    $stmt->execute(array($answer, $friendshipInviteId));
}