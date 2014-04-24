<?php

function getMember($id)
{
    global $conn;
    $stmt = $conn->prepare("SELECT Member.name,
                                   Member.about,
                                   Member.birthDate,
                                   get_user_hash(:id) AS hash
                            FROM Member
                            WHERE Member.id = :id");
    $stmt->execute(array(':id' => $id));
    $result = $stmt->fetch();
    $result['models'] = getMemberModels($id);
    $result['friends'] = getFriendsOfMember($id);
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
    global $conn;
    $stmt = $conn->prepare("SELECT *, (get_thumbnail_information(Model.id)).*, get_user_hash(Model.idAuthor) AS authorHash FROM Model WHERE idAuthor = :id");
    $stmt->execute(array(':id' => $id));
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

function getUserSidebarInfo($id) {
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

    $result['userId'] = $id;
    $result['username'] = $username;
    $result['userHash'] = $userHash;
    $result['friends'] = $friends;
    $result['groups'] = $groups;

    return $result;
}

function getUserNavbarInfo($id) {
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
    $stmt = $conn->prepare("SELECT id
                            FROM RegisteredUser JOIN Member USING(id)
                            WHERE deleteDate IS NULL AND username = ? AND passwordHash = ?");
    $stmt->execute(array($username, hash('sha256', $password)));
    $result = $stmt->fetch();

    if ($result == false){
        return false;
    } else {
        return $result['id'];
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