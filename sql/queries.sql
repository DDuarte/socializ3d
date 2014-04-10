DROP TRIGGER IF EXISTS insert_on_user_tags_view_trigger ON user_tags;
DROP TRIGGER IF EXISTS delete_from_user_tags_view_trigger ON user_tags;
DROP TRIGGER IF EXISTS insert_on_model_tags_view_trigger ON model_tags;
DROP TRIGGER IF EXISTS delete_from_model_tags_view_trigger ON model_tags;

DROP FUNCTION IF EXISTS get_group_visibile_models(BIGINT);
DROP FUNCTION IF EXISTS get_all_visibile_models(BIGINT);
DROP FUNCTION IF EXISTS get_thumbnail_information(bigint);
DROP FUNCTION IF EXISTS get_members_of_group(bigint);
DROP FUNCTION IF EXISTS get_administrators_of_group(bigint)
DROP FUNCTION IF EXISTS get_friends_of_member(bigint);
DROP FUNCTION IF EXISTS get_groups_of_member(BIGINT);
DROP FUNCTION IF EXISTS get_top_rated_models(integer, integer, BIGINT);
DROP FUNCTION IF EXISTS get_whats_hot_models(integer, integer, BIGINT);
DROP FUNCTION IF EXISTS get_new_models(INTEGER, INTEGER, BIGINT);
DROP FUNCTION IF EXISTS get_random_models(INTEGER, INTEGER, BIGINT);
DROP FUNCTION IF EXISTS get_model_counts_per_month_year(DATE, DATE)
DROP FUNCTION IF EXISTS get_member_counts_per_month_year(DATE, DATE);
DROP FUNCTION IF EXISTS get_group_counts_per_month_year(DATE, DATE);
DROP FUNCTION IF EXISTS get_counts_per_month_year(DATE, DATE);
DROP FUNCTION IF EXISTS get_notifications(timestamp, integer);
DROP FUNCTION IF EXISTS get_member_notifications(bigint, timestamp, integer);
DROP FUNCTION IF EXISTS get_group_notifications(bigint, timestamp, integer);
DROP FUNCTION IF EXISTS get_model(bigint, timestamp, integer);
DROP FUNCTION IF EXISTS insert_on_user_tags_view();
DROP FUNCTION IF EXISTS delete_from_user_tags_view();
DROP FUNCTION IF EXISTS insert_on_model_tags_view();
DROP FUNCTION IF EXISTS delete_from_model_tags_view();

-------------
-- Helpers --
-------------

DROP VIEW IF EXISTS model_info;
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
    RETURN QUERY SELECT Model.id
    FROM Model
    WHERE visibility = 'public' OR
         (visibility = 'friends' AND idAuthor IN (SELECT memberId FROM get_friends_of_member(userId)))
    UNION SELECT * FROM get_group_visibile_models(userId);
END;
$$ LANGUAGE plpgsql;

-------------------------
-- Search results page --
-------------------------

-- TGroup --
SELECT name, about, avatarImg, createDate FROM TGroup WHERE visibility = 'public' AND TGroup.name = :groupName;

-- Member --
SELECT name, about, registerDate FROM Member WHERE Member.name = :memberName;

-- Model --
SELECT name, description, createDate FROM get_all_visibile_models(:userId) JOIN Model ON get_all_visibile_models.id = Model.id
    WHERE Model.name = :modelName;

---

-- Get thumbnail information for a model --
CREATE OR REPLACE FUNCTION get_thumbnail_information(modelId bigint)
RETURNS TABLE(modelName varchar, authorName varchar, createDate timestamp, fileName varchar, numUpVotes bigint, numDownVotes bigint, numComments bigint) AS $$
    SELECT model_info.name, Member.name, model_info.createDate, fileName, numUpVotes, numDownVotes, count(TComment.id)
        FROM model_info
        JOIN Member ON Member.id = model_info.idAuthor
        LEFT JOIN TComment ON TComment.idModel = model_info.id
        WHERE model_info.id = $1
        GROUP BY model_info.name, Member.name, model_info.createDate, fileName, numUpVotes, numDownVotes
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
RETURNS TABLE(memberId bigint) AS $$
    SELECT 
        CASE $1 WHEN Friendship.idMember1 THEN Friendship.idMember2
               WHEN Friendship.idMember2 THEN Friendship.idMember1
        END AS memberId
    FROM Friendship WHERE $1 IN (Friendship.idMember1, Friendship.idMember2)
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

-- List the new models --
CREATE OR REPLACE FUNCTION get_new_models(max_model_number_limit INTEGER, skip INTEGER, userId BIGINT)
RETURNS TABLE (modelId BIGINT) AS $$
BEGIN
    RETURN QUERY SELECT get_all_visibile_models.id
    FROM get_all_visibile_models(userId) JOIN Model ON get_all_visibile_models.id = Model.id
    ORDER BY (createDate) DESC LIMIT max_model_number_limit OFFSET skip;
END;
$$ LANGUAGE plpgsql;

-- List random models --
CREATE OR REPLACE FUNCTION get_random_models(max_model_number_limit INTEGER, skip INTEGER, userId BIGINT) -- skip is not actually used
/* multiple solutions to select N random model ids were tested
   with "order by rnd" being the most simple and reliable one
   the downside is that it does a full scan + sort on the table,
   which can be slow if the table gets very large.
   an alternative is to implement this logic in PHP */
RETURNS TABLE (modelId BIGINT) AS $$
BEGIN
    RETURN QUERY SELECT id
    FROM get_all_visibile_models(userId)
    ORDER BY RANDOM() LIMIT max_model_number_limit;
END;
$$ LANGUAGE plpgsql;

--------------------
-- Administration --
--------------------

-- Get number of models created per month between two dates
DROP FUNCTION IF EXISTS get_model_counts_per_month_year(DATE, DATE);
CREATE OR REPLACE FUNCTION get_model_counts_per_month_year(startDate DATE, endDate DATE)
RETURNS TABLE (month INTEGER, year INTEGER, models INTEGER) AS $$
BEGIN RETURN QUERY
    SELECT EXTRACT(month FROM ts)::INTEGER as Month, EXTRACT(year FROM ts)::INTEGER as Year, COALESCE(count, 0)::INTEGER as Models FROM
    (
        SELECT EXTRACT(month FROM createDate) as Month,
        EXTRACT(year FROM createDate) as Year,
        COUNT(*)
        FROM Model
        WHERE createDate > startDate AND createDate < endDate
        GROUP BY 1, 2
    ) AS cnt
    RIGHT OUTER JOIN (SELECT * FROM generate_series(startDate::timestamp, endDate - INTERVAL '1 second', '1 month') AS ts) AS dtetable ON EXTRACT(month FROM ts) = cnt.Month AND EXTRACT(year FROM ts) = cnt.Year
    ORDER BY Year, Month ASC;
END;
$$ LANGUAGE plpgsql;

-- Get number of members registered per month between two dates
DROP FUNCTION IF EXISTS get_member_counts_per_month_year(DATE, DATE);
CREATE OR REPLACE FUNCTION get_member_counts_per_month_year(startDate DATE, endDate DATE)
RETURNS TABLE (month INTEGER, year INTEGER, members INTEGER) AS $$
BEGIN RETURN QUERY
    SELECT EXTRACT(month FROM ts)::INTEGER as Month, EXTRACT(year FROM ts)::INTEGER as Year, COALESCE(count, 0)::INTEGER as Members FROM
    (
        SELECT EXTRACT(month FROM registerDate) as Month,
        EXTRACT(year FROM registerDate) as Year,
        COUNT(*)
        FROM Member
        WHERE registerDate > startDate AND registerDate < endDate
        GROUP BY 1, 2
    ) AS cnt
    RIGHT OUTER JOIN (SELECT * FROM generate_series(startDate::timestamp, endDate - INTERVAL '1 second', '1 month') AS ts) AS dtetable ON EXTRACT(month FROM ts) = cnt.Month AND EXTRACT(year FROM ts) = cnt.Year
    ORDER BY Year, Month ASC;
END;
$$ LANGUAGE plpgsql;

-- Get number of groups created per month between two dates
DROP FUNCTION IF EXISTS get_group_counts_per_month_year(DATE, DATE);
CREATE OR REPLACE FUNCTION get_group_counts_per_month_year(startDate DATE, endDate DATE)
RETURNS TABLE (month INTEGER, year INTEGER, groups INTEGER) AS $$
BEGIN RETURN QUERY
    SELECT EXTRACT(month FROM ts)::INTEGER as Month, EXTRACT(year FROM ts)::INTEGER as Year, COALESCE(count, 0)::INTEGER as Groups FROM
    (
        SELECT EXTRACT(month FROM createDate) as Month,
        EXTRACT(year FROM createDate) as Year,
        COUNT(*)
        FROM TGroup
        WHERE createDate > startDate AND createDate < endDate
        GROUP BY 1, 2
    ) AS cnt
    RIGHT OUTER JOIN (SELECT * FROM generate_series(startDate::timestamp, endDate - INTERVAL '1 second', '1 month') AS ts) AS dtetable ON EXTRACT(month FROM ts) = cnt.Month AND EXTRACT(year FROM ts) = cnt.Year
    ORDER BY Year, Month ASC;
END;
$$ LANGUAGE plpgsql;

-- Get number of models, members and groups created per month between two dates
-- Note: startDate = 2014-01-01, endDate = 2015-01-01 should return 12 results. that's why that "-1 second" is required
DROP FUNCTION IF EXISTS get_counts_per_month_year(DATE, DATE);
CREATE OR REPLACE FUNCTION get_counts_per_month_year(startDate DATE, endDate DATE)
RETURNS TABLE (month INTEGER, year INTEGER, models INTEGER, members INTEGER, groups INTEGER) AS $$
BEGIN RETURN QUERY
    SELECT * FROM get_model_counts_per_month_year(startDate, endDate)
        INNER JOIN get_member_counts_per_month_year(startDate, endDate) USING (month, year)
        INNER JOIN get_group_counts_per_month_year(startDate, endDate) USING (month, year);
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
        OR (visibility = 'friends' AND $1 IN (SELECT memberId FROM get_friends_of_member(Model.idAuthor)))
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
INSERT INTO TComment(idMember, idModel, content) VALUES (:authorId, :modelId, :commentContent);

-- Insert new group --
INSERT INTO TGroup(name, about, avatarImg, coverImg, visibility) VALUES (:name, :about, :avatarImg, :coverImg, :visibility);

-- Insert member into group --
INSERT INTO GroupUser(idGroup, idMember, isAdmin) VALUES (:idGroup, :idMember, :isAdmin);

-- Insert model into group --
INSERT INTO GroupModel(idGroup, idModel) VALUES (:idGroup, :idModel);

-- Insert new model --
INSERT INTO Model(idAuthor, name, description, userFileName, fileName, visibility) VALUES (:idAuthor, :name, :description, :userFileName, :fileName, :visibility);

-- Insert new friendship --
INSERT INTO Friendship(idMember1, idMember2) VALUES (:idMember1, :idMember2);

-- Insert vote in model --
INSERT INTO Vote(idMember, idModel, upVote) VALUES (:idMember, :idModel, :upVote);

-- Insert Tag in model (insert into view) --
INSERT INTO model_tags(idModel, name) VALUES (:idModel, :name);

-- Insert registered user --
INSERT INTO RegisteredUser(userName, passwordHash, email, isAdmin) VALUES (:userName, :passwordHash, :email, :isAdmin);

-- Insert tag (interest) in Member --
INSERT INTO user_tags(idMember, name) VALUES (:idMember, :name);

-- Insert friendship invite --
INSERT INTO FriendshipInvite(idReceiver, idSender) VALUES (:idReceiver, :idSender);

-- Insert group application --
INSERT INTO GroupApplication(idGroup, idMember) VALUES (:idGroup, :idMember);

-- Insert group invite --
INSERT INTO GroupInvite(idGroup, idReceiver, idSender) VALUES (:idGroup, :idReceiver, :idSender);

-----------------------
-- Update statements --
-----------------------

-- Update model description --
UPDATE Model SET description = :description WHERE id = :id;

-- Update model's visibility --
UPDATE Model SET visibility = :visibility WHERE id = :id;

-- Update member's about field --
UPDATE Member SET about = :about WHERE id = :id;

-- Update vote --
UPDATE Vote SET upVote = :upVote WHERE Vote.idModel = :idModel AND Vote.idMember = :idMember;

-- Answer friendship invite --
UPDATE FriendshipInvite SET accepted = :accepted WHERE FriendshipInvite.id = :id;

-- Answer group application --
UPDATE GroupApplication SET accepted = :accepted WHERE GroupApplication.id = :id;

-- Answer group invite --
UPDATE GroupInvite SET accepted = :accepted WHERE GroupInvite.id = :id;

-- Remove Tag from Model --
DELETE FROM model_tags WHERE model_tags.idModel = :idModel AND model_tags.name = :name;

-- Remove Tag (interest) from Member --
DELETE FROM user_tags WHERE idMember = :idMember AND name = :tagName;
