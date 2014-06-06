<?php

include_once($BASE_DIR . 'database/users.php');
include_once($BASE_DIR . 'database/groups.php');


class InvitationHandler {
    function post($groupId, $newMemberId) {
        global $BASE_DIR;
        global $smarty;

        $memberId = getLoggedId();
        if ($memberId == null) {
            http_response_code(403);
            exit;
        }

        if ($memberId == $newMemberId) { //accept invite if exists
            $otherRequests = getUnansweredGroupInvitesOfMember($newMemberId);
            $reqId = null;
            foreach ($otherRequests as $key => $value) {
                if ($otherRequests[$key]['idgroup'] == $groupId) {
                    $reqId = $otherRequests[$key]['id'];
                    break;
                }
            }
            if ($reqId == null) {
                http_response_code(404); // Request not found
                exit;
            }

            answerGroupInvite($reqId, true);
            exit;
        }

        $otherMember = getMember($newMemberId, $memberId);
        if ($otherMember == null) {
            http_response_code(404); // Member not found
            exit;
        }

        $groupMembers = getMembersOfGroup($groupId);
        $thisIsMember = false;
        $otherIsMember = false;
        foreach ($groupMembers as $mem) {
            if ($mem['memberid'] == $memberId)
                $thisIsMember = true;
            if ($mem['memberid'] == $newMemberId)
                $otherIsMember = true;
        }

        if (!$thisIsMember) {
            http_response_code(403);
            exit;
        }
        if ($otherIsMember) {
            http_response_code(409); //other is member
            exit;
        }


        $otherRequests = getUnansweredGroupInvitesOfMember($newMemberId);
        $alreadySent = false;
        foreach ($otherRequests as $key => $value) {
            if ($otherRequests[$key]['idgroup'] == $groupId) {
                $alreadySent = true;
                break;
            }
        }
        if ($alreadySent) {
            http_response_code(409); // Member has already received a request to join this group
            exit;
        }

        createGroupInvite($memberId, $newMemberId, $groupId);
    }

    function delete($groupId, $newMemberId) {
        global $BASE_DIR;
        global $smarty;

        $memberId = getLoggedId();
        if ($memberId == null) {
            http_response_code(403);
            exit;
        }


        $otherRequests = getUnansweredGroupInvitesOfMember($newMemberId);
        $invId = null;
        foreach ($otherRequests as $key => $value) {
            if ($otherRequests[$key]['idgroup'] == $groupId) {
                $invId = $otherRequests[$key]['id'];
                break;
            }
        }
        if ($invId == null) {
            http_response_code(404); // No request found
            exit;
        }

        answerGroupInvite($invId, false);
    }
}