DROP TRIGGER IF EXISTS insert_on_user_tags_view_trigger ON user_tags;
DROP TRIGGER IF EXISTS delete_from_user_tags_view_trigger ON user_tags;
DROP TRIGGER IF EXISTS insert_on_model_tags_view_trigger ON model_tags;
DROP TRIGGER IF EXISTS delete_from_model_tags_view_trigger ON model_tags;

DROP FUNCTION IF EXISTS get_groups_with_name(varchar);
DROP FUNCTION IF EXISTS get_members_with_name(varchar);
DROP FUNCTION IF EXISTS get_models_with_name(varchar);
DROP FUNCTION IF EXISTS get_thumbnail_information(bigint);
DROP FUNCTION IF EXISTS get_members_of_group(bigint);
DROP FUNCTION IF EXISTS get_administrators_of_group(bigint);
DROP FUNCTION IF EXISTS get_friends_of_member(bigint);
DROP FUNCTION IF EXISTS get_groups_of_member(bigint);
DROP FUNCTION IF EXISTS get_top_rated_models(integer, integer);
DROP FUNCTION IF EXISTS get_whats_hot_models(integer, integer);

DROP VIEW IF EXISTS model_info;

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
RETURNS TABLE(modelName varchar, authorName varchar, createDate timestamp, fileName varchar, numUpVotes bigint, numDownVotes bigint, numComments bigint) AS $$
    SELECT DISTINCT model_info.name, Member.name, model_info.createDate, fileName, numUpVotes, numDownVotes, count(TComment.id)
        FROM model_info
        JOIN Member ON Member.id = model_info.idAuthor
        LEFT JOIN TComment ON TComment.idModel = model_info.id
        WHERE model_info.id = $1
        GROUP BY model_info.name, Member.name, numUpVotes, numDownVotes
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
CREATE OR REPLACE FUNCTION get_groups_of_member(memberId BIGINT)
RETURNS TABLE(groupId BIGINT) AS $$
    SELECT TGroup.id
    FROM TGroup
    JOIN GroupUser ON GroupUser.idGroup = TGroup.id AND GroupUser.idMember = $1
$$ LANGUAGE SQL;

-- List the top rated models --
CREATE OR REPLACE FUNCTION get_top_rated_models(max_model_number_limit integer, skip integer, userId BIGINT)
RETURNS TABLE (modelId BIGINT) AS $$
BEGIN
    RETURN QUERY SELECT id
    FROM get_all_visibile_models(userId) JOIN ModelVote ON id = ModelVote.idModel
    ORDER BY (numupvotes - numdownvotes) DESC LIMIT max_model_number_limit OFFSET skip;
END;
$$ LANGUAGE plpgsql;

-- List the what's hot models --
CREATE OR REPLACE FUNCTION get_whats_hot_models(max_model_number_limit integer, skip integer, userId BIGINT)
-- ranking based on Reddit's algorithm
-- ts = createDate - 2014-01-01 00:00:00 // s
-- x = upvotes - downvotes
-- y = { 1 <- x > 0; 0 <- x = 0; -1 <- x < 0 }
-- z = { |x| <- |x| >= 1; 1 <- |x| < 1 } // for ints, |x| < 1 implies x = 0
-- points = log10(z) + y * ts / 45000 // order by; 12.5 hours is 45000 seconds
RETURNS TABLE (modelId BIGINT) AS $$
BEGIN
    RETURN QUERY SELECT get_all_visibile_models.id
    FROM get_all_visibile_models(userId) JOIN model_info ON get_all_visibile_models.id = model_info.id
    ORDER BY (log(CASE WHEN (numupvotes - numdownvotes) != 0 THEN
            @(numupvotes - numdownvotes) ELSE
            1::integer END) +
        CASE WHEN (numupvotes - numdownvotes) > 0 THEN
            1::integer WHEN (numupvotes - numdownvotes) = 0 THEN
            0::integer ELSE -1::integer END *
        EXTRACT(epoch FROM (createDate - '2014-01-01 00:00:00'::timestamp)) / 45000) DESC LIMIT max_model_number_limit OFFSET skip;
END;
$$ LANGUAGE plpgsql;

CREATE VIEW model_info AS SELECT id, idAuthor, name, description, userFileName, fileName, createDate, visibility, numUpVotes, numDownVotes FROM model JOIN modelvote ON model.id = modelvote.idModel;

CREATE OR REPLACE FUNCTION get_group_visibile_models(userId BIGINT)
RETURNS TABLE (id BIGINT) AS $$
BEGIN
    RETURN QUERY SELECT idModel
    FROM GroupModel
    WHERE idGroup IN (SELECT get_groups_of_member(userId));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_all_visibile_models(userId BIGINT)
RETURNS TABLE (id BIGINT) AS $$
BEGIN
    RETURN QUERY SELECT model_info.id
    FROM model_info
    WHERE visibility = 'public' OR
         (visibility = 'friends' AND idAuthor IN (SELECT memberId FROM get_friends_of_member(userId)))
    UNION SELECT * FROM get_group_visibile_models(userId);
END;
$$ LANGUAGE plpgsql;

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
        BEGIN;
        IF NOT EXISTS(SELECT 1 FROM Tag WHERE Tag.name = NEW.name LIMIT 1) THEN
            INSERT INTO Tag (name) VALUES (NEW.name) RETURNING Tag.id INTO tagid;
        ELSE
            SELECT Tag.id INTO tagid FROM Tag WHERE Tag.name = NEW.name LIMIT 1;
        END IF;

        INSERT INTO UserInterest (idMember, idTag) SELECT NEW.idMember, tagid
            WHERE NOT EXISTS (SELECT 1 FROM UserInterest WHERE UserInterest.idMember= NEW.idMember AND UserInterest.idTag = tagid);
        COMMIT;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_on_user_tags_view_trigger INSTEAD OF INSERT ON user_tags FOR EACH ROW
    EXECUTE PROCEDURE insert_on_user_tags_view();


CREATE OR REPLACE FUNCTION delete_from_user_tags_view() RETURNS TRIGGER AS $$
    DECLARE
        tagid bigint;
    BEGIN
        BEGIN;
        SELECT Tag.id INTO tagid FROM Tag WHERE Tag.name = OLD.name LIMIT 1;
        DELETE FROM UserInterest WHERE UserInterest.idMember = OLD.idMember AND UserInterest.idTag = tagid;
        COMMIT;
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
        BEGIN;
        IF NOT EXISTS(SELECT 1 FROM Tag WHERE Tag.name = NEW.name LIMIT 1) THEN
            INSERT INTO Tag (name) VALUES (NEW.name) RETURNING Tag.id INTO tagid;
        ELSE
            SELECT Tag.id INTO tagid FROM Tag WHERE Tag.name = NEW.name LIMIT 1;
        END IF;

        INSERT INTO ModelTag (idModel, idTag) SELECT NEW.idModel, tagid
            WHERE NOT EXISTS (SELECT 1 FROM ModelTag WHERE ModelTag.idModel= NEW.idModel AND ModelTag.idTag = tagid);
        COMMIT;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_on_model_tags_view_trigger INSTEAD OF INSERT ON model_tags FOR EACH ROW
    EXECUTE PROCEDURE insert_on_model_tags_view();


CREATE OR REPLACE FUNCTION delete_from_model_tags_view() RETURNS TRIGGER AS $$
    DECLARE
        tagid bigint;
    BEGIN
        BEGIN;
        SELECT Tag.id INTO tagid FROM TAG WHERE Tag.name = OLD.name LIMIT 1;
        DELETE FROM ModelTag WHERE ModelTag.idModel = OLD.idModel AND ModelTag.idTag = tagid;
        COMMIT;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_from_model_tags_view_trigger INSTEAD OF DELETE ON model_tags FOR EACH ROW
    EXECUTE PROCEDURE delete_from_model_tags_view();

--
-----------------------
-- Insert Statements --
-----------------------

-- Insert comments into model --
CREATE OR REPLACE FUNCTION insert_comment(authorId bigint, modelId bigint, commentContent bigint)
RETURNS VOID AS $$
	INSERT INTO TComment(idMember, idModel, content) VALUES ($1, $2, $3);
$$ LANGUAGE SQL;

-- Insert new group --
CREATE OR REPLACE FUNCTION insert_group(name varchar, about varchar, avatarImg varchar, coverImg varchar, visibility visibility_group)
RETURNS VOID AS $$
	INSERT INTO TGroup(name, about, avatarImg, coverImg, visibility) VALUES ($1, $2, $3, $4, $5);
$$ LANGUAGE SQL;

-- Insert member into group --
CREATE OR REPLACE FUNCTION insert_member_into_group(idGroup bigint, idMember bigint, isAdmin boolean default false)
RETURNS VOID AS $$
	INSERT INTO GroupUser(idGroup, idMember, isAdmin) VALUES ($1, $2, $3);
$$ LANGUAGE SQL;

-- Insert model into group --
CREATE OR REPLACE FUNCTION insert_model_into_group(idGroup bigint, idModel bigint)
RETURNS VOID AS $$
	INSERT INTO GroupModel(idGroup, idModel) VALUES ($1, $2);
$$ LANGUAGE SQL;

-- Insert new model --
CREATE OR REPLACE FUNCTION insert_model(idAuthor bigint, name varchar, description varchar, userFileName varchar, fileName varchar, visibility visibility_model)
RETURNS VOID AS $$
	INSERT INTO Model(idAuthor, name, description, userFileName, fileName, visibility) VALUES ($1, $2, $3, $4, $5, $6);
$$ LANGUAGE SQL;

-- Insert new friendship --
CREATE OR REPLACE FUNCTION insert_friendship(idMember1 bigint, idMember2 bigint)
RETURNS VOID AS $$
	INSERT INTO Friendship(idMember1, idMember2) VALUES ($1, $2);
$$ LANGUAGE SQL;

-- Insert vote in model --
CREATE OR REPLACE FUNCTION insert_vote(idAuthor bigint, idModel bigint, upVote boolean)
RETURNS VOID AS $$
	INSERT INTO Vote(idMember, idModel, upVote) VALUES($1, $2, $3);
$$ LANGUAGE SQL;

-- Insert registered user --
CREATE OR REPLACE FUNCTION insert_user(username varchar, passwordHash varchar, email varchar, isAdmin boolean default false)
RETURNS VOID AS $$
	INSERT INTO RegisteredUser(userName, passwordHash, email, isAdmin) VALUES ($1, $2, $3, $4);
$$ LANGUAGE SQL;

-- Insert friendship invite --
CREATE OR REPLACE FUNCTION insert_friendship_invite(idReceiver bigint, idSender bigint)
RETURNS VOID AS $$
	INSERT INTO FriendshipInvite(idReceiver, idSender) VALUES ($1, $2);
$$ LANGUAGE SQL;

-- Insert group application --
CREATE OR REPLACE FUNCTION insert_group_application(idGroup bigint, idMember bigint)
RETURNS VOID AS $$
	INSERT INTO GroupApplication(idGroup, idMember) VALUES ($1, $2);
$$ LANGUAGE SQL;

-- Insert group invite --
CREATE OR REPLACE FUNCTION insert_group_invite(idGroup bigint, idReceiver bigint, idSender bigint)
RETURNS VOID AS $$
	INSERT INTO GroupInvite(idGroup, idReceiver, idSender) VALUES ($1, $2, $3);
$$ LANGUAGE SQL;
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
