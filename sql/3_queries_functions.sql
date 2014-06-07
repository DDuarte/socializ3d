SET search_path TO final;

DROP FUNCTION IF EXISTS get_group_visibile_models(BIGINT);
DROP FUNCTION IF EXISTS get_all_visibile_models(BIGINT);
DROP FUNCTION IF EXISTS get_user_hash(BIGINT);
DROP FUNCTION IF EXISTS get_thumbnail_information(BIGINT);
DROP FUNCTION IF EXISTS get_members_of_group(BIGINT);
DROP FUNCTION IF EXISTS get_administrators_of_group(BIGINT);
DROP FUNCTION IF EXISTS get_friends_of_member(BIGINT);
DROP FUNCTION IF EXISTS get_complete_friends_of_member(BIGINT);
DROP FUNCTION IF EXISTS get_groups_of_member(BIGINT);
DROP FUNCTION IF EXISTS get_complete_groups_of_member(BIGINT);
DROP FUNCTION IF EXISTS get_top_rated_models(INTEGER, INTEGER, BIGINT);
DROP FUNCTION IF EXISTS get_whats_hot_models(INTEGER, INTEGER, BIGINT);
DROP FUNCTION IF EXISTS get_new_models(INTEGER, INTEGER, BIGINT);
DROP FUNCTION IF EXISTS get_random_models(INTEGER, INTEGER, BIGINT);
DROP FUNCTION IF EXISTS get_model_counts_per_month_year(DATE, DATE);
DROP FUNCTION IF EXISTS get_member_counts_per_month_year(DATE, DATE);
DROP FUNCTION IF EXISTS get_group_counts_per_month_year(DATE, DATE);
DROP FUNCTION IF EXISTS get_counts_per_month_year(DATE, DATE);
DROP FUNCTION IF EXISTS get_notifications(TIMESTAMP, INTEGER);
DROP FUNCTION IF EXISTS get_member_notifications(BIGINT, TIMESTAMP, INTEGER);
DROP FUNCTION IF EXISTS get_group_notifications(BIGINT, TIMESTAMP, INTEGER);
DROP FUNCTION IF EXISTS get_model(BIGINT, TIMESTAMP, INTEGER);
DROP FUNCTION IF EXISTS insert_on_user_tags_view();
DROP FUNCTION IF EXISTS delete_from_user_tags_view();
DROP FUNCTION IF EXISTS insert_on_model_tags_view();
DROP FUNCTION IF EXISTS delete_from_model_tags_view();

-------------
-- Helpers --
-------------

-- List all the groups of a user --
CREATE OR REPLACE FUNCTION get_groups_of_member(memberId BIGINT)
RETURNS TABLE(groupId BIGINT) AS $$
    SELECT TGroup.id
    FROM TGroup
    JOIN GroupUser ON GroupUser.idGroup = TGroup.id AND GroupUser.idMember = $1
$$ LANGUAGE SQL;

-- List the id and name of all the groups of a user --
CREATE OR REPLACE FUNCTION get_complete_groups_of_member(memberId BIGINT)
RETURNS TABLE(groupId BIGINT, groupName VARCHAR(70), about VARCHAR, coverimg VARCHAR) AS $$
    SELECT TGroup.id, TGroup.name, TGroup.about, TGroup.coverImg
    FROM TGroup
    JOIN GroupUser ON GroupUser.idGroup = TGroup.id AND GroupUser.idMember = $1 AND TGroup.deleteDate IS NULL
$$ LANGUAGE SQL;

DROP VIEW IF EXISTS model_info;
CREATE VIEW model_info AS SELECT id, idAuthor, name, description, userFileName, fileName, createDate, visibility, numUpVotes, numDownVotes FROM model JOIN modelvote ON model.id = modelvote.idModel;

CREATE OR REPLACE FUNCTION get_group_visibile_models(userId BIGINT)
RETURNS TABLE (id BIGINT) AS $$
BEGIN
    RETURN QUERY SELECT DISTINCT idModel
    FROM GroupModel
    WHERE idGroup IN (SELECT get_groups_of_member(userId));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_all_visibile_models(userId BIGINT)
RETURNS TABLE (id BIGINT) AS $$
BEGIN
    RETURN QUERY SELECT Model.id
    FROM Model
    WHERE idAuthor = userId OR -- my models
          visibility = 'public' OR -- public model
         (visibility = 'friends' AND idAuthor IN (SELECT friendId FROM get_friends_of_member(userId))) -- my friends
    UNION SELECT get_group_visibile_models(userId);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_user_hash(userId BIGINT)
-- hash used to get avatar from email with Gravatar
RETURNS TEXT AS $$
    SELECT md5(lower(btrim(email))) FROM RegisteredUser WHERE id = $1;
$$ LANGUAGE SQL;

---

-- Get thumbnail information for a model --
CREATE OR REPLACE FUNCTION get_thumbnail_information(modelId BIGINT)
RETURNS TABLE(modelName VARCHAR, authorName VARCHAR, createDate TIMESTAMP, fileName VARCHAR, numUpVotes BIGINT, numDownVotes BIGINT, numComments BIGINT) AS $$
    SELECT model_info.name, Member.name, model_info.createDate, fileName, numUpVotes, numDownVotes, count(TComment.id)
        FROM model_info
        JOIN Member ON Member.id = model_info.idAuthor
        LEFT JOIN TComment ON TComment.idModel = model_info.id AND TComment.deleted = false
        WHERE model_info.id = $1
        GROUP BY model_info.name, Member.name, model_info.createDate, fileName, numUpVotes, numDownVotes
$$ LANGUAGE SQL;

-- List all the members of a group --
CREATE OR REPLACE FUNCTION get_members_of_group(groupId BIGINT)
RETURNS TABLE(memberId BIGINT, memberName VARCHAR, isAdmin BOOLEAN, lastAccess TIMESTAMP) AS $$
    SELECT Member.id, Member.name, GroupUser.isAdmin, GroupUser.lastAccess FROM GroupUser
        JOIN TGroup ON GroupUser.idGroup = TGroup.id
        JOIN Member ON Member.id = GroupUser.idMember
        WHERE TGroup.id = $1
        ORDER BY Member.name ASC
$$ LANGUAGE SQL;

-- List all the administrators of a group --
CREATE OR REPLACE FUNCTION get_administrators_of_group(groupId BIGINT)
RETURNS TABLE(memberId BIGINT, memberName VARCHAR) AS $$
    SELECT Member.id, Member.name FROM GroupUser
        JOIN TGroup ON GroupUser.idGroup = $1
        JOIN Member ON (Member.id = GroupUser.idMember AND GroupUser.isAdmin = 'true')
        ORDER BY Member.name ASC
$$ LANGUAGE SQL;

-- List all the friend id's of a user --
CREATE OR REPLACE FUNCTION get_friends_of_member(memberId BIGINT)
RETURNS TABLE(friendId BIGINT) AS $$
    SELECT
        CASE $1 WHEN Friendship.idMember1 THEN Friendship.idMember2
               WHEN Friendship.idMember2 THEN Friendship.idMember1
        END AS memberId
    FROM Friendship WHERE $1 IN (Friendship.idMember1, Friendship.idMember2)
$$ LANGUAGE SQL;

-- List all the friend id's and name of a user --
CREATE OR REPLACE FUNCTION get_complete_friends_of_member(memberId BIGINT)
RETURNS TABLE(memberId BIGINT, memberName VARCHAR, hash VARCHAR, about VARCHAR) AS $$
    SELECT Member.id, Member.name, get_user_hash(Member.id) as hash, Member.about
    FROM get_friends_of_member($1)
    JOIN Member ON Member.id = friendId
$$ LANGUAGE SQL;

-- List the top rated models --
CREATE OR REPLACE FUNCTION get_top_rated_models(max_model_number_limit INTEGER, skip INTEGER, userId BIGINT)
RETURNS TABLE (modelId BIGINT) AS $$
BEGIN
    RETURN QUERY SELECT id
    FROM get_all_visibile_models(userId) JOIN ModelVote ON id = ModelVote.idModel
    ORDER BY (numupvotes - numdownvotes) DESC LIMIT max_model_number_limit OFFSET skip;
END;
$$ LANGUAGE plpgsql;

-- List the what's hot models --
CREATE OR REPLACE FUNCTION get_whats_hot_models(max_model_number_limit INTEGER, skip INTEGER, userId BIGINT)
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
            1::INTEGER END) +
        CASE WHEN (numupvotes - numdownvotes) > 0 THEN
            1::INTEGER WHEN (numupvotes - numdownvotes) = 0 THEN
            0::INTEGER ELSE -1::INTEGER END *
        EXTRACT(epoch FROM (createDate - '2014-01-01 00:00:00'::TIMESTAMP)) / 45000) DESC LIMIT max_model_number_limit OFFSET skip;
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

-- List user models --
CREATE OR REPLACE FUNCTION get_user_models(max_model_number_limit INTEGER, skip INTEGER, userId BIGINT, whoUserId BIGINT)
RETURNS TABLE (modelId BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT get_all_visibile_models.id
    FROM get_all_visibile_models(userId) JOIN Model ON get_all_visibile_models.id = Model.id
    WHERE idAuthor = whoUserId LIMIT max_model_number_limit OFFSET skip;
END;
$$ LANGUAGE plpgsql;

-- List group models --
CREATE OR REPLACE FUNCTION get_group_models(max_model_number_limit INTEGER, skip INTEGER, userId BIGINT, whoGroupId BIGINT)
RETURNS TABLE (modelId BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT idModel
    FROM GroupModel JOIN TGroup ON TGroup.id = whoGroupId
    WHERE idGroup = whoGroupId AND
    (visibility = 'public' OR
     (visibility = 'private' AND userId IN (SELECT idMember FROM GroupUser WHERE idGroup = whoGroupId)));
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
    RIGHT OUTER JOIN (SELECT * FROM generate_series(startDate::TIMESTAMP, endDate - INTERVAL '1 second', '1 month') AS ts) AS dtetable ON EXTRACT(month FROM ts) = cnt.Month AND EXTRACT(year FROM ts) = cnt.Year
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
    RIGHT OUTER JOIN (SELECT * FROM generate_series(startDate::TIMESTAMP, endDate - INTERVAL '1 second', '1 month') AS ts) AS dtetable ON EXTRACT(month FROM ts) = cnt.Month AND EXTRACT(year FROM ts) = cnt.Year
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
    RIGHT OUTER JOIN (SELECT * FROM generate_series(startDate::TIMESTAMP, endDate - INTERVAL '1 second', '1 month') AS ts) AS dtetable ON EXTRACT(month FROM ts) = cnt.Month AND EXTRACT(year FROM ts) = cnt.Year
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
CREATE OR REPLACE FUNCTION get_notifications(oldest_date_limit TIMESTAMP, max_notifications_limit INTEGER) RETURNS TABLE(idNotification BIGINT, notType notification_type, idFriendshipInvite BIGINT, idGroupApplication BIGINT, idGroupInvite BIGINT, idModel BIGINT) AS $$
    SELECT id, notificationType, idFriendshipInvite, idGroupApplication, idGroupInvite, idModel FROM Notification WHERE createDate >= $1 LIMIT $2
$$ LANGUAGE SQL;

-- List the newest member notifications within a given range --
CREATE OR REPLACE FUNCTION get_member_notifications(memberId BIGINT, oldest_date_limit TIMESTAMP, max_notifications_limit INTEGER) RETURNS TABLE(idNotification BIGINT, notType notification_type, idFriendshipInvite BIGINT, idGroupApplication BIGINT, idGroupInvite BIGINT, idModel BIGINT, createDate TIMESTAMP) AS $$
    SELECT Notification.id, Notification.notificationType, Notification.idFriendshipInvite, Notification.idGroupApplication, Notification.idGroupInvite, Notification.idModel, Notification.createDate FROM Notification JOIN UserNotification ON UserNotification.idMember = $1 AND UserNotification.idNotification = Notification.id WHERE createDate >= $2 ORDER BY createDate LIMIT $3
$$ LANGUAGE SQL;

-- List the newest group notifications within a given range --
CREATE OR REPLACE FUNCTION get_group_notifications(groupId BIGINT, oldest_date_limit TIMESTAMP, max_notifications_limit INTEGER) RETURNS TABLE(idNotification BIGINT, notType notification_type, idFriendshipInvite BIGINT, idGroupApplication BIGINT, idGroupInvite BIGINT, idModel BIGINT) AS $$
    SELECT Notification.id, Notification.notificationType, Notification.idFriendshipInvite, Notification.idGroupApplication, Notification.idGroupInvite, Notification.idModel FROM Notification JOIN GroupNotification ON GroupNotification.idGroup = $1 AND GroupNotification.idNotification = Notification.id  WHERE createDate < $2 LIMIT $3
$$ LANGUAGE SQL;

-- List the newest publications for a particular member --
CREATE OR REPLACE FUNCTION get_model(memberId BIGINT, oldest_date_limit TIMESTAMP, max_notifications_limit INTEGER) RETURNS TABLE(idModel BIGINT) AS $$
    SELECT Model.id
    FROM Model
    WHERE Model.createDate < $2
        AND (visibility = 'public' OR (visibility = 'friends' AND $1 IN (SELECT friendId FROM get_friends_of_member(Model.idAuthor))))
    LIMIT $3
$$ LANGUAGE SQL;

-- Get Model Information --
CREATE OR REPLACE FUNCTION get_model_info(modelId BIGINT) RETURNS TABLE(idAuthor BIGINT, nameAuthor VARCHAR(70), name VARCHAR(70), description VARCHAR(255), fileName VARCHAR(255), userFileName VARCHAR(255), createDate TIMESTAMP, numUpVotes BIGINT, numDownVotes BIGINT) AS $$
    SELECT model_info.idAuthor,
           Member.name AS nameAuthor,
           model_info.name,
           model_info.description,
           model_info.fileName,
          model_info.userFileName,
           model_info.createDate,
           model_info.numUpVotes,
           model_info.numDownVotes
    FROM model_info JOIN Member ON model_info.idAuthor = Member.id
    WHERE model_info.id = $1
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION get_model_info(userId BIGINT, modelId BIGINT) RETURNS TABLE(idAuthor BIGINT, nameAuthor VARCHAR(70), name VARCHAR(70), description VARCHAR(255), fileName VARCHAR(255), userFileName VARCHAR(255), createDate TIMESTAMP, numUpVotes BIGINT, numDownVotes BIGINT) AS $$
BEGIN
    IF ($2 IN (SELECT * FROM get_all_visibile_models($1))) THEN
        RETURN QUERY SELECT * FROM get_model_info($2);
    ELSE
        RAISE EXCEPTION 'User % does not have permission to access model %.', $1, $2;
    END IF;
END;
$$ LANGUAGE PLPGSQL;

-- Get Model Comments --
CREATE OR REPLACE FUNCTION get_model_comments(modelId BIGINT) RETURNS TABLE(id BIGINT, idMember BIGINT, name VARCHAR(70), hash TEXT, content VARCHAR(255), createDate TIMESTAMP) as $$
    SELECT TComment.id,
           TComment.idMember,
           Member.name,
           get_user_hash(Member.id) AS hash,
           TComment.content,
           TComment.createDate
    FROM TComment JOIN Model ON Model.id = $1
                  JOIN Member ON Member.id = TComment.idMember
                  JOIN RegisteredUser ON Member.id = RegisteredUser.id
    WHERE TComment.idmodel = $1 AND TComment.deleted = false
    ORDER BY TComment.createDate DESC
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION get_model_comments(userId BIGINT, modelId BIGINT) RETURNS TABLE(idMember BIGINT, name VARCHAR(70), email VARCHAR(254), content VARCHAR(255), createDate TIMESTAMP) as $$
BEGIN
    IF ($2 IN (SELECT * FROM get_all_visibile_models($1))) THEN
        RETURN QUERY SELECT * FROM get_model_comments($2);
    ELSE
        RAISE EXCEPTION 'User % does not have permission to access model % comments.', $1, $2;
    END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION get_group_profile(memberId BIGINT, groupId BIGINT) RETURNS TABLE(name VARCHAR(70), about VARCHAR(255), avatarImg VARCHAR(255), coverImg VARCHAR(255)) AS $$
BEGIN
    IF ('public' NOT IN (SELECT TGroup.visibility FROM TGroup WHERE TGroup.id = $2) AND
        $1 NOT IN (SELECT GroupUser.idMember FROM GroupUser WHERE GroupUser.idGroup = $2)) THEN
        RAISE EXCEPTION 'User % does not have permission to access group % profile.', $1, $2;
    ELSE
        RETURN QUERY SELECT TGroup.name, TGroup.about, TGroup.avatarImg, TGroup.coverImg FROM TGroup WHERE TGroup.id = $2 AND TGroup.deleteDate IS NULL;
    END IF;
END;
$$ LANGUAGE PLPGSQL;

-----------
-- Views --
-----------

CREATE OR REPLACE VIEW user_tags AS
    SELECT UserInterest.idMember AS idMember, Tag.name AS name
    FROM UserInterest INNER JOIN Tag ON Tag.id = UserInterest.idTag;

CREATE OR REPLACE FUNCTION insert_on_user_tags_view() RETURNS TRIGGER AS $$
    DECLARE
        tagid BIGINT;
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

DROP TRIGGER IF EXISTS insert_on_user_tags_view_trigger ON user_tags;

CREATE TRIGGER insert_on_user_tags_view_trigger INSTEAD OF INSERT ON user_tags FOR EACH ROW
    EXECUTE PROCEDURE insert_on_user_tags_view();

CREATE OR REPLACE FUNCTION delete_from_user_tags_view() RETURNS TRIGGER AS $$
    DECLARE
        tagid BIGINT;
    BEGIN
        SELECT Tag.id INTO tagid FROM Tag WHERE Tag.name = OLD.name LIMIT 1;
        DELETE FROM UserInterest WHERE UserInterest.idMember = OLD.idMember AND UserInterest.idTag = tagid;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS delete_from_user_tags_view_trigger ON user_tags;
CREATE TRIGGER delete_from_user_tags_view_trigger INSTEAD OF DELETE ON user_tags FOR EACH ROW
    EXECUTE PROCEDURE delete_from_user_tags_view();

CREATE OR REPLACE VIEW model_tags AS
    SELECT ModelTag.idModel AS idModel, Tag.name AS name
    FROM ModelTag INNER JOIN Tag ON Tag.id = ModelTag.idTag;

CREATE OR REPLACE FUNCTION insert_on_model_tags_view() RETURNS TRIGGER AS $$
    DECLARE
        tagid BIGINT;
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

DROP TRIGGER IF EXISTS insert_on_model_tags_view_trigger ON model_tags;
CREATE TRIGGER insert_on_model_tags_view_trigger INSTEAD OF INSERT ON model_tags FOR EACH ROW
    EXECUTE PROCEDURE insert_on_model_tags_view();

CREATE OR REPLACE FUNCTION delete_from_model_tags_view() RETURNS TRIGGER AS $$
    DECLARE
        tagid BIGINT;
    BEGIN
        SELECT Tag.id INTO tagid FROM TAG WHERE Tag.name = OLD.name LIMIT 1;
        DELETE FROM ModelTag WHERE ModelTag.idModel = OLD.idModel AND ModelTag.idTag = tagid;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS delete_from_model_tags_view_trigger ON model_tags;
CREATE TRIGGER delete_from_model_tags_view_trigger INSTEAD OF DELETE ON model_tags FOR EACH ROW
    EXECUTE PROCEDURE delete_from_model_tags_view();

--

CREATE OR REPLACE FUNCTION add_member(_userName VARCHAR(20), _passwordHash VARCHAR(64), _email VARCHAR(254), _name VARCHAR(70), _about VARCHAR(255), _birthDate DATE) RETURNS void AS $$
DECLARE
    registeredUserId BIGINT;
BEGIN
    INSERT INTO RegisteredUser(userName, passwordHash, email, isAdmin) VALUES ($1, $2, $3, false) RETURNING id INTO registeredUserId;
    INSERT INTO Member(id, name, about, birthDate) VALUES (registeredUserId, $4, $5, $6);
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION add_administrator(_userName VARCHAR(20), _passwordHash VARCHAR(64), _email VARCHAR(254)) RETURNS void AS $$
BEGIN
    INSERT INTO RegisteredUser(userName, passwordHash, email, isAdmin) VALUES ($1, $2, $3, true);
END;
$$ LANGUAGE PLPGSQL;
