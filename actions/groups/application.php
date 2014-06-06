<?php

include_once($BASE_DIR . 'database/users.php');
include_once($BASE_DIR . 'database/groups.php');


class ApplicationHandler {
    function post($groupId, $newMemberId) {
        global $BASE_DIR;
        global $smarty;

        if (isPrivateGroup($groupId)) {
            http_response_code(403); //private group
            exit;
        }

        $memberId = getLoggedId();
        if ($memberId == null) {
            http_response_code(403);
            exit;
        }

        if ($memberId !== $newMemberId) { //accept invite if exists
            if (!isGroupAdmin($groupId, $memberId)) {
                http_response_code(403); // Must be admin
                exit;
            }
            $otherMember = getMember($newMemberId, $memberId);
            if ($otherMember == null) {
                http_response_code(404); // Member not found
                exit;
            }

            $otherRequests = getUnansweredGroupApplicationsOfMember($newMemberId);
            $reqId = null;
            foreach ($otherRequests as $key => $value) {
                if ($otherRequests[$key]['idgroup'] == $groupId) {
                    $reqId = $otherRequests[$key]['id'];
                    break;
                }
            }
            if ($reqId == null) {
                http_response_code(404); // Application not found
                exit;
            }

            answerGroupApplication($reqId, true);
            exit;
        }

        $groupMembers = getMembersOfGroup($groupId);
        $thisIsMember = false;
        foreach ($groupMembers as $mem) {
            if ($mem['memberid'] == $memberId) {
                $thisIsMember = true;
                break;
            }
        }

        if (!$thisIsMember) {
            http_response_code(409); //already a member
            exit;
        }

        $otherRequests = getUnansweredGroupApplicationsOfMember($memberId);
        $alreadySent = false;
        foreach ($otherRequests as $key => $value) {
            if ($otherRequests[$key]['idgroup'] == $groupId) {
                $alreadySent = true;
                break;
            }
        }
        if ($alreadySent) {
            http_response_code(409); // Member has already applied to join this group
            exit;
        }

        $otherRequests = getUnansweredGroupInvitesOfMember($newMemberId);
        $reqId = null;
        foreach ($otherRequests as $key => $value) {
            if ($otherRequests[$key]['idgroup'] == $groupId) {
                $reqId = $otherRequests[$key]['id'];
                break;
            }
        }
        if ($reqId !== null) {
            answerGroupInvite($reqId, true); //he had already been invited, no point in applying
            exit;
        }

        createGroupApplication($memberId, $groupId);
    }

    function delete($groupId, $newMemberId) {
        global $BASE_DIR;
        global $smarty;

        if (isPrivateGroup($groupId)) {
            http_response_code(403); //private group
            exit;
        }

        $memberId = getLoggedId();
        if ($memberId == null) {
            http_response_code(403);
            exit;
        }

        if ($memberId !== $newMemberId) { //accept invite if exists
            if (!isGroupAdmin($groupId, $memberId)) {
                http_response_code(403); // Must be admin
                exit;
            }
            $otherMember = getMember($newMemberId, $memberId);
            if ($otherMember == null) {
                http_response_code(404); // Member not found
                exit;
            }

            $otherRequests = getUnansweredGroupApplicationsOfMember($newMemberId);
            $reqId = null;
            foreach ($otherRequests as $key => $value) {
                if ($otherRequests[$key]['idgroup'] == $groupId) {
                    $reqId = $otherRequests[$key]['id'];
                    break;
                }
            }
            if ($reqId == null) {
                http_response_code(404); // Application not found
                exit;
            }

            answerGroupApplication($reqId, false);
            exit;
        }

        http_response_code(403); //can't decline own application
        exit;
    }
}