DROP TRIGGER IF EXISTS insert_on_user_tags_view_trigger ON user_tags;
DROP TRIGGER IF EXISTS delete_from_user_tags_view_trigger ON user_tags;
DROP TRIGGER IF EXISTS insert_on_model_tags_view_trigger ON model_tags;
DROP TRIGGER IF EXISTS delete_from_model_tags_view_trigger ON model_tags;

-------------------------
-- Search results page --
-------------------------

-- TGroup --
CREATE OR REPLACE FUNCTION get_groups_with_name(name varchar)
RETURNS TABLE(name varchar, about varchar, avatarImg varchar, createDate timestamp) AS $$
	SELECT name, about, avatarImg, createDate 
	FROM TGroup WHERE visibility = 'public' AND TGroup.name = $1
$$ LANGUAGE SQL;

-- Member --
CREATE OR REPLACE FUNCTION get_members_with_name(name varchar)
RETURNS TABLE(name varchar, about varchar, registerDate timestamp) AS $$
	SELECT name, about, registerDate 
	FROM Member WHERE Member.name = $1
$$ LANGUAGE SQL;

-- Model --
CREATE OR REPLACE FUNCTION get_models_with_name(name varchar)
RETURNS TABLE(name varchar, description varchar, createDate timestamp) AS $$
	SELECT name, description, createDate 
	FROM Model WHERE Model.name = $1 AND visibility = 'public'
$$ LANGUAGE SQL;

---

-- Get thumbnail information for a model --
CREATE OR REPLACE FUNCTION get_thumbnail_information(modelId bigint) 
RETURNS TABLE(modelName varchar, authorName varchar, upVotes bigint, downVotes bigint, comments bigint) AS $$
	SELECT DISTINCT Model.name as model, Member.name as author, count(CASE WHEN upVote = 'true' THEN 1 ELSE 0 END) as upVotes, count(CASE WHEN upVote = 'false' THEN 1 ELSE 0 END) as downVotes, count(TComment.id) as comments 
		FROM Model 
		JOIN Member ON Member.id = Model.idAuthor 
		LEFT JOIN Vote ON Model.id = Vote.idModel 
		LEFT JOIN TComment ON TComment.idModel = Model.id
		WHERE Model.id = $1
		GROUP BY Model.id, Member.id
$$ LANGUAGE SQL;
	
-- List all the members of a group --
CREATE OR REPLACE FUNCTION get_members_of_group(groupId bigint)
RETURNS TABLE(memberId bigint, memberName varchar) AS $$
	SELECT Member.id, Member.name FROM GroupUser 
		JOIN TGroup ON GroupUser.idGroup = $1
		JOIN Member ON Member.id = GroupUser.idMember
		ORDER BY Member.name ASC
$$ LANGUAGE SQL;
	
-- List all the administrators of a group --
CREATE OR REPLACE FUNCTION get_administrators_of_group(groupId bigint)
RETURNS TABLE(memberId bigint, memberName varchar) AS $$
	SELECT Member.id, Member.name FROM GroupUser 
		JOIN TGroup ON GroupUser.idGroup = $1
		JOIN Member ON (Member.id = GroupUser.idMember AND GroupUser.isAdmin = 'true')
		ORDER BY Member.name ASC
$$ LANGUAGE SQL;

-- List all the friends of a user --
CREATE OR REPLACE FUNCTION get_friends_of_member(memberId bigint)
RETURNS TABLE(memberId bigint, memberName varchar) AS $$
	SELECT Member.id, Member.name 
	FROM (
		SELECT FriendShip.idMember1 AS idFriend FROM Friendship WHERE Friendship.idMember2 = $1
		UNION ALL
		SELECT FriendShip.idMember2 AS idFriend FROM Friendship WHERE Friendship.idMember1 = $1
	) AS friends JOIN Member ON Member.id = idFriend
$$ LANGUAGE SQL;
	
-- List all the groups of a user --
CREATE OR REPLACE FUNCTION get_groups_of_member(memberId bigint)
RETURNS TABLE(groupId bigint, groupName varchar) AS $$
	SELECT TGroup.id, TGroup.name 
	FROM TGroup 
	JOIN GroupUser ON GroupUser.idGroup = TGroup.id AND GroupUser.idMember = $1
$$ LANGUAGE SQL;

-- List all the models of a group --
CREATE OR REPLACE FUNCTION get_models_of_group(groupId bigint)
RETURNS TABLE(modelName varchar, authorName varchar, upVotes bigint, downVotes bigint, comments bigint) AS $$
	SELECT DISTINCT Model.name as model, Member.name as author, count(CASE WHEN upVote = 'true' THEN 1 ELSE null END) as upVotes, count(CASE WHEN upVote = 'false' THEN 0 ELSE null END) as downVotes, count(TComment.id) as comments 
		FROM Model
		JOIN GroupModel ON (GroupModel.idGroup = $1 AND GroupModel.idModel = Model.id)
		JOIN Vote ON Model.id = Vote.idModel 
		JOIN Member ON Member.id = Model.idAuthor 
		JOIN TComment ON TComment.idModel = Model.id
		GROUP BY Model.id, Member.id
$$ LANGUAGE SQL;

-- List the top rated models --
CREATE OR REPLACE FUNCTION get_top_rated_models(max_model_number_limit integer)
RETURNS TABLE (idModel BIGINT, numUpVotes BIGINT, numDownVotes BIGINT) AS $$
	SELECT idmodel, numupvotes, numdownvotes
	FROM modelvote ORDER BY (numupvotes - numdownvotes) DESC LIMIT $1
$$ LANGUAGE SQL;

-------------------
-- Notifications --
-------------------

-- List the newest notifications within a given range --	
CREATE OR REPLACE FUNCTION get_notifications(oldest_date_limit timestamp, max_notifications_limit integer) RETURNS TABLE(idNotification bigint, notType notification_type, idFriendshipInvite bigint, idGroupApplication bigint, idGroupInvite bigint, idModel bigint) AS $$
	SELECT id, notificationType, idFriendshipInvite, idGroupApplication, idGroupInvite, idModel FROM Notification WHERE createDate < $1 LIMIT $2
$$ LANGUAGE SQL;

-- List the newest member notifications within a given range --
CREATE OR REPLACE FUNCTION get_member_notifications(memberId bigint, oldest_date_limit timestamp, max_notifications_limit integer) RETURNS TABLE(idNotification bigint, notType notification_type, idFriendshipInvite bigint, idGroupApplication bigint, idGroupInvite bigint, idModel bigint) AS $$
	SELECT Notification.id, Notification.notificationType, Notification.idFriendshipInvite, Notification.idGroupApplication, Notification.idGroupInvite, Notification.idModel FROM Notification JOIN UserNotification ON UserNotification.idMember = $1 AND UserNotification.idNotification = Notification.id  WHERE createDate < $2 LIMIT $3
$$ LANGUAGE SQL;

-- List the newest group notifications within a given range --
CREATE OR REPLACE FUNCTION get_group_notifications(groupId bigint, oldest_date_limit timestamp, max_notifications_limit integer) RETURNS TABLE(idNotification bigint, notType notification_type, idFriendshipInvite bigint, idGroupApplication bigint, idGroupInvite bigint, idModel bigint) AS $$
	SELECT Notification.id, Notification.notificationType, Notification.idFriendshipInvite, Notification.idGroupApplication, Notification.idGroupInvite, Notification.idModel FROM Notification JOIN GroupNotification ON GroupNotification.idGroup = $1 AND GroupNotification.idNotification = Notification.id  WHERE createDate < $2 LIMIT $3
$$ LANGUAGE SQL;

-- List the newest publications for a particular member --
CREATE OR REPLACE FUNCTION get_model(memberId bigint, oldest_date_limit timestamp, max_notifications_limit integer) RETURNS TABLE(idModel bigint) AS $$
	SELECT Model.id
    FROM Model 
    WHERE Model.createDate < $2
        AND (   visibility = 'public'
            OR (visibility = 'friends' AND $1 IN (SELECT FriendShip.idMember1 AS idFriend FROM Friendship WHERE Friendship.idMember2 = Model.idAuthor 
                                                        UNION ALL
                                                        SELECT FriendShip.idMember2 AS idFriend FROM Friendship WHERE Friendship.idMember1 = Model.idAuthor)
                )
            )
    LIMIT $3
$$ LANGUAGE SQL;

-----------
-- Views --
-----------

CREATE OR REPLACE VIEW user_tags AS
	SELECT UserInterest.idMember AS idMember, Tag.name AS name
	FROM UserInterest INNER JOIN Tag ON Tag.id = UserInterest.idTag;

CREATE OR REPLACE FUNCTION insert_on_user_tags_view() RETURNS TRIGGER AS $$
	DECLARE
		tagid bigint;
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM Tag WHERE Tag.name = NEW.name LIMIT 1) THEN
			INSERT INTO Tag (name) VALUES (NEW.name) RETURNING Tag.id INTO tagid;
		ELSE
			SELECT Tag.id INTO tagid FROM Tag WHERE Tag.name = NEW.name LIMIT 1;
		END IF;
		
		INSERT INTO UserInterest (idMember, idTag) SELECT NEW.idMember, tagid 
			WHERE NOT EXISTS (SELECT 1 FROM UserInterest WHERE UserInterest.idMember= NEW.idMember AND UserInterest.idTag = tagid);
			
		RETURN NEW;
	END; 
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_on_user_tags_view_trigger INSTEAD OF INSERT ON user_tags FOR EACH ROW
	EXECUTE PROCEDURE insert_on_user_tags_view();
	
	
CREATE OR REPLACE FUNCTION delete_from_user_tags_view() RETURNS TRIGGER AS $$
	DECLARE
		tagid bigint;
	BEGIN
		SELECT Tag.id INTO tagid FROM TAG WHERE Tag.name = OLD.name LIMIT 1;
		DELETE FROM UserInterest WHERE UserInterest.idMember = OLD.idMember AND UserInterest.idTag = tagid;
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_from_user_tags_view_trigger INSTEAD OF DELETE ON user_tags FOR EACH ROW	
	EXECUTE PROCEDURE delete_from_user_tags_view();
	
CREATE OR REPLACE VIEW model_tags AS
	SELECT ModelTag.idModel AS idModel, Tag.name AS name
	FROM ModelTag INNER JOIN Tag ON Tag.id = ModelTag.idTag;
	
CREATE OR REPLACE FUNCTION insert_on_model_tags_view() RETURNS TRIGGER AS $$
	DECLARE
		tagid bigint;
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM Tag WHERE Tag.name = NEW.name LIMIT 1) THEN
			INSERT INTO Tag (name) VALUES (NEW.name) RETURNING Tag.id INTO tagid;
		ELSE
			SELECT Tag.id INTO tagid FROM Tag WHERE Tag.name = NEW.name LIMIT 1;
		END IF;
		
		INSERT INTO ModelTag (idModel, idTag) SELECT NEW.idModel, tagid 
			WHERE NOT EXISTS (SELECT 1 FROM ModelTag WHERE ModelTag.idModel= NEW.idModel AND ModelTag.idTag = tagid);
			
		RETURN NEW;
	END; 
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_on_model_tags_view_trigger INSTEAD OF INSERT ON model_tags FOR EACH ROW
	EXECUTE PROCEDURE insert_on_model_tags_view();
	
	
CREATE OR REPLACE FUNCTION delete_from_model_tags_view() RETURNS TRIGGER AS $$
	DECLARE
		tagid bigint;
	BEGIN
		SELECT Tag.id INTO tagid FROM TAG WHERE Tag.name = OLD.name LIMIT 1;
		DELETE FROM ModelTag WHERE ModelTag.idModel = OLD.idModel AND ModelTag.idTag = tagid;
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_from_model_tags_view_trigger INSTEAD OF DELETE ON model_tags FOR EACH ROW	
	EXECUTE PROCEDURE delete_from_model_tags_view();
	
-- 
-----------------------
-- Update statements --
-----------------------

-- Update model description --
CREATE OR REPLACE FUNCTION set_model_description(modelId bigint, modelDescription varchar)
RETURNS VOID AS $$
	UPDATE Model SET description = $2 WHERE id = $1;
$$ LANGUAGE SQL;

-- Update member's about field --
CREATE OR REPLACE FUNCTION set_member_about(memberId bigint, memberAbout varchar)
RETURNS VOID AS $$
	UPDATE Member SET about = $2 WHERE id = $1;
$$ LANGUAGE SQL;