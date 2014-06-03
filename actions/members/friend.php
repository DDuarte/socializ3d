<?php

include_once($BASE_DIR . 'database/users.php');


class FriendsHandler {
    function post($otherMemberId) {
        global $BASE_DIR;
        global $smarty;

        $memberId = getLoggedId();
        if ($memberId == null) {
            http_response_code(403);
            return;
        }

        $otherMember = getMember($otherMemberId, $memberId);
        if ($otherMember['myFriend']) {
            http_response_code(409); // Already a friend
            return;
        }

        $myRequests = getUnansweredFriendRequestsOfMember($memberId);
        $requestId = null;
        foreach ($myRequests as $key => $value) {
            if ($myRequests[$key]['idsender'] == $otherMemberId) {
                $requestId = $myRequests[$key]['id'];
                break;
            }
        }
        if ($requestId !== null) {
            answerFriendshipInvite($requestId, true);
            exit;
        }

        $otherRequests = getUnansweredFriendRequestsOfMember($otherMemberId);
        $alreadySent = false;
        foreach ($otherRequests as $key => $value) {
            if ($otherRequests[$key]['idsender'] == $memberId) {
                $alreadySent = true;
                break;
            }
        }
        if ($alreadySent) {
            http_response_code(409); // Already sent request
            return;
        }

        createFriendRequest($memberId, $otherMemberId);
    }

    function delete($otherMemberId) {
        global $BASE_DIR;
        global $smarty;

        $memberId = getLoggedId();
        if ($memberId == null) {
            http_response_code(403);
            return;
        }

        $otherRequests = getUnansweredFriendRequestsOfMember($memberId);
        $requestId = null;
        foreach ($otherRequests as $key => $value) {
            if ($otherRequests[$key]['idsender'] == $otherMemberId) {
                $requestId = $otherRequests[$key]['id'];
                break;
            }
        }
        if ($requestId !== null) {
            answerFriendshipInvite($requestId, false);
            exit;
        }

        $otherMember = getMember($otherMemberId, $memberId);
        if (!$otherMember['myFriend']) {
            http_response_code(409); // This member is not your friend
            return;
        }

        deleteFriendship($memberId, $otherMemberId);
    }
}