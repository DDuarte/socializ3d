SET search_path TO final;

DROP INDEX IF EXISTS notification_idx;
DROP INDEX IF EXISTS group_invite_idGroup_idx;
DROP INDEX IF EXISTS group_invite_idReceiver_idx;
DROP INDEX IF EXISTS group_invite_createDate_idx;
DROP INDEX IF EXISTS group_invite_accepted_idx;
DROP INDEX IF EXISTS group_application_idGroup_idx;
DROP INDEX IF EXISTS group_application_idMember_idx;
DROP INDEX IF EXISTS group_application_createDate_idx;
DROP INDEX IF EXISTS group_application_accepted_idx;
DROP INDEX IF EXISTS friendship_invite_idReceiver_idx;
DROP INDEX IF EXISTS friendship_invite_idSender_idx;
DROP INDEX IF EXISTS friendship_invite_createDate_idx;
DROP INDEX IF EXISTS friendship_invite_accepted_idx;
DROP INDEX IF EXISTS model_name_idx;
DROP INDEX IF EXISTS model_description_idx;
DROP INDEX IF EXISTS model_idAuthor_idx;
DROP INDEX IF EXISTS model_createDate_idx;
DROP INDEX IF EXISTS model_visibility_idx;
DROP INDEX IF EXISTS group_name_idx;
DROP INDEX IF EXISTS group_about_idx;
DROP INDEX IF EXISTS group_visibility_idx;
DROP INDEX IF EXISTS member_name_idx;
DROP INDEX IF EXISTS member_about_idx;
DROP INDEX IF EXISTS friendship_member2_idx;
DROP INDEX IF EXISTS comment_idModel_idx;
DROP INDEX IF EXISTS comment_createDate_idx;
DROP INDEX IF EXISTS vote_idModel_idx;
DROP INDEX IF EXISTS tag_name_idx;
DROP INDEX IF EXISTS userInterest_idMember_idx;
DROP INDEX IF EXISTS modelTag_idModel_idx;
DROP INDEX IF EXISTS groupUser_idMember_idx;
DROP INDEX IF EXISTS groupModel_idModel_idx;
DROP INDEX IF EXISTS modelVote_numVotes_idx;

-- Notification --
CREATE INDEX notification_idx ON Notification(createDate);
CLUSTER Notification USING notification_idx;

-- GroupInvite -- 
CREATE INDEX group_invite_idGroup_idx ON GroupInvite(idGroup);
CREATE INDEX group_invite_idReceiver_idx ON GroupInvite(idReceiver);
CREATE INDEX group_invite_createDate_idx ON GroupInvite(createDate DESC);
CREATE INDEX group_invite_accepted_idx ON GroupInvite(accepted);
CLUSTER GroupInvite USING group_invite_createDate_idx;

-- GroupApplication --
CREATE INDEX group_application_idGroup_idx ON GroupApplication(idGroup);
CREATE INDEX group_application_idMember_idx ON GroupApplication(idMember);
CREATE INDEX group_application_createDate_idx ON GroupApplication(createDate DESC);
CREATE INDEX group_application_accepted_idx ON GroupApplication(accepted);
CLUSTER GroupApplication USING group_application_createDate_idx;

-- FriendshipInvite --
CREATE INDEX friendship_invite_idReceiver_idx ON FriendshipInvite(idReceiver);
CREATE INDEX friendship_invite_idSender_idx ON FriendshipInvite(idSender);
CREATE INDEX friendship_invite_createDate_idx ON FriendshipInvite(createDate DESC);
CREATE INDEX friendship_invite_accepted_idx ON FriendshipInvite(accepted);
CLUSTER FriendshipInvite USING friendship_invite_createDate_idx;

-- Model --
CREATE INDEX model_name_idx ON Model USING gin(to_tsvector('english', name));
CREATE INDEX model_description_idx ON Model USING gin(to_tsvector('english', description));
CREATE INDEX model_idAuthor_idx ON Model(idAuthor);
CREATE INDEX model_createDate_idx ON Model(createDate DESC);
CREATE INDEX model_visibility_idx ON Model(visibility);
CLUSTER Model USING model_createDate_idx;

-- TGroup --
CREATE INDEX group_name_idx ON TGroup USING gin(to_tsvector('english', name));
CREATE INDEX group_about_idx ON TGroup USING gin(to_tsvector('english', about));
CREATE INDEX group_visibility_idx ON TGroup(visibility);

-- Member --
CREATE INDEX member_name_idx ON Member USING gin(to_tsvector('english', name));
CREATE INDEX member_about_idx ON Member USING gin(to_tsvector('english', about));

-- Friendship --
CREATE INDEX friendship_member2_idx ON Friendship(idMember2);

-- TComment --
CREATE INDEX comment_idModel_idx ON TComment(idModel);
CREATE INDEX comment_createDate_idx ON TComment(createDate DESC);
CLUSTER TComment USING comment_createDate_idx;

-- Vote --
CREATE INDEX vote_idModel_idx ON Vote(idModel);

-- Tag --
CREATE INDEX tag_name_idx ON Tag(lower(name) ASC);

-- UserInterest --
CREATE INDEX userInterest_idMember_idx ON UserInterest(idMember);

-- ModelTag --
CREATE INDEX modelTag_idModel_idx ON ModelTag(idModel);

-- GroupUser --
CREATE INDEX groupUser_idMember_idx ON GroupUser(idMember);

-- GroupModel -- 
CREATE INDEX groupModel_idModel_idx ON GroupModel(idModel);

-- ModelVote --
CREATE INDEX modelVote_numVotes_idx ON ModelVote((numUpVotes - numDownVotes) DESC);
