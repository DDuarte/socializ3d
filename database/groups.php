<?php

include_once('users.php');
include_once('notifications.php');

function getSimpleGroup($id) {
    $loggedId = getLoggedId();

    global $conn;
    $stmt = $conn->prepare("SELECT * FROM get_group_profile(?, ?)");
    $stmt->execute(array($loggedId, $id));
    $result = $stmt->fetch();

    if ($result == false) return false;

    $result['id'] = $id;
    $result['isGroupAdmin'] = isGroupAdmin($id, $loggedId) || isAdmin($loggedId);
    $result['memberInGroup'] = isGroupMember($id, $loggedId);
    return $result;
}

function getGroup($id) {
    $loggedId = getLoggedId();

    global $conn;
    $stmt = $conn->prepare("SELECT * FROM get_group_profile(?, ?)");
    $stmt->execute(array($loggedId, $id));
    $result = $stmt->fetch();

    if ($result == false) return false;

    $result['id'] = $id;
    $result['models'] = getGroupModels($id);
    $result['members'] = getMembersOfGroup($id);
    $result['isMember'] = isGroupMember($id, $loggedId);
    $result['isGroupAdmin'] = isGroupAdmin($id, $loggedId) || isAdmin($loggedId);
    $result['activity'] = getGroupNotifications($id, '2010-01-01', 1000); // TODO: pagination
    $result['groupMemberApplications'] = getGroupUnansweredApplications($id);


    return $result;
}

function getGroupModels($id) {
    $loggedId = getLoggedId();

    global $conn;
    $stmt = $conn->prepare("SELECT *, (get_thumbnail_information(Model.id)).*, get_user_hash(Model.idAuthor) AS authorHash FROM Model JOIN get_group_models(1000, 0, :logged_id, :id) ON (Model.id = modelId)");
    $stmt->execute(array(':id' => $id, ':logged_id' => $loggedId));
    return $stmt->fetchAll();
}

function getMembersOfGroup($id) {
    global $conn;
    $stmt = $conn->prepare("SELECT * FROM get_members_of_group(:id)");
    $stmt->execute(array(':id' => $id));
    $members = $stmt->fetchAll();

    return $members;
}

function isGroupVisibleToMember($groupId, $memberId) {
    global $conn;
    $stmt = $conn->prepare("SELECT 1 FROM get_group_profile(:memberId, :groupId)");
    try {
        $stmt->execute(array(":memberId" => $memberId, ":groupId" => $groupId));
        $stmt->fetch();
        return true;
    } catch (PDOException $e) {
        return false;
    }
}

function isGroupAdmin($idGroup, $idMember) {
    global $conn;
    $stmt = $conn->prepare("SELECT 1 FROM GroupUser WHERE idGroup = ? AND idMember = ? AND isadmin = TRUE");
    $stmt->execute(array($idGroup, $idMember));
    $result = $stmt->fetch();
    return $result;
}

function isGroupMember($idGroup, $idMember) {
    global $conn;
    $stmt = $conn->prepare("SELECT 1 FROM GroupUser WHERE idGroup = ? AND idMember = ?");
    $stmt->execute(array($idGroup, $idMember));
    $result = $stmt->fetch();
    return $result;
}

function createGroupInvite($memberId, $newMemberId, $groupId)
{
    global $conn;
    $stmt = $conn->prepare("INSERT INTO GroupInvite(idGroup, idReceiver, idSender) VALUES (?, ?, ?)");
    $stmt->execute(array($groupId, $newMemberId, $memberId));
}


function getUnansweredGroupInvitesOfMember($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT id, idGroup, idReceiver, idSender FROM GroupInvite WHERE idReceiver = :id AND accepted IS NULL");
    $stmt->execute(array(':id' => $id));
    $result = $stmt->fetchAll();

    return $result;
}

function answerGroupInvite($inviteId, $answer)
{
    global $conn;
    $stmt = $conn->prepare("UPDATE GroupInvite SET accepted = :accepted WHERE GroupInvite.id = :id;");
    $converted_answer = ($answer) ? 'true' : 'false';
    $stmt->execute(array($converted_answer, $inviteId));
}

function getUnansweredGroupApplicationsOfMember($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT id, idGroup, idMember FROM GroupApplication WHERE idMember = :id AND accepted IS NULL");
    $stmt->execute(array(':id' => $id));
    $result = $stmt->fetchAll();

    return $result;
}

function createGroupApplication($memberId, $groupId)
{
    global $conn;
    $stmt = $conn->prepare("INSERT INTO GroupApplication(idGroup, idMember) VALUES (?, ?)");
    $stmt->execute(array($groupId, $memberId));
}

function answerGroupApplication($appId, $answer)
{
    global $conn;
    $stmt = $conn->prepare("UPDATE GroupApplication SET accepted = :accepted WHERE GroupApplication.id = :id;");
    $converted_answer = ($answer) ? 'true' : 'false';
    $stmt->execute(array($converted_answer, $appId));
}

function updateGroupInfo($groupId, $aboutInfo, $coverImg, $avatarImg)
{
    global $conn;
    $stmt = $conn->prepare('UPDATE TGroup SET about = :about, coverImg = :cover, avatarImg = :avatar WHERE id = :id');
    $stmt->execute(array(':id' => $groupId, ":about" => $aboutInfo, ":cover" => $coverImg, ":avatar" => $avatarImg));
}

function createGroup($creator, $groupName, $aboutInfo, $coverImg, $avatarImg, $visibility)
{
    global $conn;
    $stmt = $conn->prepare("INSERT INTO TGroup(name, about, avatarImg, coverImg, visibility) VALUES (:name, :about, :avatar, :cover, :visibility) RETURNING id AS groupid;");
    $stmt->execute(array(':name' => $groupName, ":about" => $aboutInfo, ":cover" => $coverImg, ":avatar" => $avatarImg, ":visibility" => $visibility));
    $res = $stmt->fetch();

    $stmt = $conn->prepare('INSERT INTO GroupUser(idGroup, idMember, isAdmin) VALUES (:idgroup, :idmem, true);');
    $stmt->execute(array(':idgroup' => $res['groupid'], ':idmem' => $creator));

    return $res['groupid'];
}

function updateGroupUserStatus($groupId, $memberId, $isAdmin)
{
    global $conn;
    $stmt = $conn->prepare("UPDATE GroupUser SET isAdmin = :admin WHERE idMember = :member AND idGroup = :group;");
    $adminValue = ($isAdmin) ? 'true' : 'false';
    $stmt->execute(array(':admin' => $adminValue, ':member' => $memberId, ':group' => $groupId));
}

function removeGroupUser($groupId, $userId)
{
    global $conn;
    $stmt = $conn->prepare("DELETE FROM GroupUser WHERE idGroup = :group AND idMember = :member;");
    $stmt->execute(array(':group' => $groupId, ':member' => $userId));
}

function deleteGroup($groupId)
{
    global $conn;
    $stmt = $conn->prepare('UPDATE TGroup SET deleteDate = now()::timestamp(0) WHERE id = :id');
    $stmt->execute(array(':id' => $groupId));
}

function getMemberLastAccess($idGroup, $idMember)
{
    global $conn;
    $stmt = $conn->prepare('SELECT * FROM GroupUser WHERE idGroup = :id AND idMember = :id2');
    $stmt->execute(array(':id' => $idGroup, ':id2' =>$idMember));
    $result = $stmt->fetch();
    return $result['lastaccess'];
}