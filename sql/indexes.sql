DROP INDEX IF EXISTS notification_idx;
DROP INDEX IF EXISTS group_invite_createDate_idx;
DROP INDEX IF EXISTS group_invite_accepted_idx;
DROP INDEX IF EXISTS group_application_idGroup_idx;
DROP INDEX IF EXISTS group_application_createDate_idx;
DROP INDEX IF EXISTS group_application_accepted_idx;
DROP INDEX IF EXISTS friendship_invite_idReceiver_idx;
DROP INDEX IF EXISTS friendship_invite_createDate_idx;
DROP INDEX IF EXISTS friendship_invite_accepted_idx;
DROP INDEX IF EXISTS model_name_idx;
DROP INDEX IF EXISTS model_visibility_idx;
DROP INDEX IF EXISTS group_idx;
DROP INDEX IF EXISTS member_idx;
DROP INDEX IF EXISTS friendship_idx;
	
-- Notification --
CREATE INDEX notification_idx ON Notification(createDate);

-- GroupInvite -- 
CREATE INDEX group_invite_createDate_idx ON GroupInvite(createDate);
CREATE INDEX group_invite_accepted_idx ON GroupInvite(accepted);

-- GroupApplication --
CREATE INDEX group_application_idGroup_idx ON GroupApplication(idGroup);
CREATE INDEX group_application_createDate_idx ON GroupApplication(createDate);
CREATE INDEX group_application_accepted_idx ON GroupApplication(accepted);

-- FriendshipInvite --
CREATE INDEX friendship_invite_idReceiver_idx ON FriendshipInvite(idReceiver);
CREATE INDEX friendship_invite_createDate_idx ON FriendshipInvite(createDate);
CREATE INDEX friendship_invite_accepted_idx ON FriendshipInvite(accepted);

-- Model --
CREATE INDEX model_name_idx ON Model(name);
CREATE INDEX model_visibility_idx ON Model(visibility);

-- TGroup --
CREATE INDEX group_idx ON TGroup(name);

-- Member --
CREATE INDEX member_idx ON Member(name);

-- Friendship --
CREATE INDEX friendship_idx ON Friendship(idMember2);