-- DROP SCHEMA final CASCADE;
-- CREATE SCHEMA final;
SET search_path TO final;

DROP TYPE IF EXISTS visibility_group CASCADE;
DROP TYPE IF EXISTS visibility_model CASCADE;
DROP TYPE IF EXISTS notification_type CASCADE;

DROP TABLE IF EXISTS RegisteredUser CASCADE;
DROP TABLE IF EXISTS Member CASCADE;
DROP TABLE IF EXISTS TGroup CASCADE;
DROP TABLE IF EXISTS Friendship CASCADE;
DROP TABLE IF EXISTS Model CASCADE;
DROP TABLE IF EXISTS ModelVote CASCADE;
DROP TABLE IF EXISTS TComment CASCADE;
DROP TABLE IF EXISTS Vote CASCADE;
DROP TABLE IF EXISTS Tag CASCADE;
DROP TABLE IF EXISTS UserInterest CASCADE;
DROP TABLE IF EXISTS ModelTag CASCADE;
DROP TABLE IF EXISTS GroupUser CASCADE;
DROP TABLE IF EXISTS GroupModel CASCADE;
DROP TABLE IF EXISTS FriendshipInvite CASCADE;
DROP TABLE IF EXISTS GroupApplication CASCADE;
DROP TABLE IF EXISTS GroupInvite CASCADE;
DROP TABLE IF EXISTS Notification CASCADE;
DROP TABLE IF EXISTS UserNotification CASCADE;
DROP TABLE IF EXISTS GroupNotification CASCADE;

CREATE TABLE IF NOT EXISTS RegisteredUser (
    id bigserial NOT NULL,
    userName varchar(20) NOT NULL,
    passwordHash varchar(64) NOT NULL,
    email varchar(254) NOT NULL,
    isAdmin boolean NOT NULL DEFAULT FALSE
);

ALTER TABLE RegisteredUser ADD CONSTRAINT RegisteredUser_pk PRIMARY KEY (id);
ALTER TABLE RegisteredUser ADD CONSTRAINT RegisteredUser_userName_uk UNIQUE (userName);
ALTER TABLE RegisteredUser ADD CONSTRAINT RegisteredUser_email_uk UNIQUE (email);
ALTER TABLE RegisteredUser ADD CONSTRAINT RegisteredUser_email_check CHECK (email LIKE '%@%.%');
ALTER TABLE RegisteredUser ADD CONSTRAINT RegisteredUser_passwordHash_check CHECK (length(passwordHash) = 64);

CREATE TABLE IF NOT EXISTS Member (
    id bigint NOT NULL,
    name varchar(70) NOT NULL,
    about varchar(1024) NOT NULL DEFAULT '',
    birthDate date NOT NULL,
    registerDate timestamp NOT NULL DEFAULT now()::timestamp(0),
    deleteDate timestamp DEFAULT NULL
);

ALTER TABLE Member ADD CONSTRAINT Member_pk PRIMARY KEY (id);
ALTER TABLE Member ADD CONSTRAINT Member_id_fk FOREIGN KEY (id) REFERENCES RegisteredUser (id) ON DELETE CASCADE;
ALTER TABLE Member ADD CONSTRAINT Member_registerDate_check CHECK (registerDate > birthDate::timestamp);
ALTER TABLE Member ADD CONSTRAINT Member_deleteDate_check CHECK (deleteDate IS NULL OR deleteDate >= registerDate);

CREATE TYPE visibility_group AS ENUM ('private', 'public');

CREATE TABLE IF NOT EXISTS TGroup (
    id bigserial NOT NULL,
    name varchar(70) NOT NULL,
    about varchar(1024) NOT NULL DEFAULT '',
    avatarImg varchar(255) DEFAULT NULL,
    coverImg varchar(255) DEFAULT NULL,
    createDate timestamp NOT NULL DEFAULT now()::timestamp(0),
    deleteDate timestamp DEFAULT NULL,
    visibility visibility_group NOT NULL
);

ALTER TABLE TGroup ADD CONSTRAINT TGroup_pk PRIMARY KEY (id);
ALTER TABLE TGroup ADD CONSTRAINT TGroup_deleteDate_check CHECK (deleteDate IS NULL OR deleteDate > createDate);

CREATE TABLE IF NOT EXISTS Friendship (
    idMember1 bigint NOT NULL,
    idMember2 bigint NOT NULL,
    createDate timestamp NOT NULL DEFAULT now()::timestamp(0)
);

ALTER TABLE Friendship ADD CONSTRAINT Friendship_pk PRIMARY KEY (idMember1, idMember2);
ALTER TABLE Friendship ADD CONSTRAINT Friendship_idMember1_fk FOREIGN KEY (idMember1) REFERENCES Member (id) ON DELETE CASCADE;
ALTER TABLE Friendship ADD CONSTRAINT Friendship_idMember2_fk FOREIGN KEY (idMember2) REFERENCES Member (id) ON DELETE CASCADE;
ALTER TABLE Friendship ADD CONSTRAINT Friendship_check CHECK (idMember1 < idMember2);

CREATE TYPE visibility_model AS ENUM ('private', 'public', 'friends');

CREATE TABLE IF NOT EXISTS Model (
    id bigserial NOT NULL,
    idAuthor bigint NOT NULL,
    name varchar(70) NOT NULL,
    description varchar(1024) NOT NULL DEFAULT '',
    userFileName varchar(255) NOT NULL,
    fileName varchar(255) NOT NULL,
    createDate timestamp NOT NULL DEFAULT now()::timestamp(0),
    visibility visibility_model NOT NULL
);

ALTER TABLE Model ADD CONSTRAINT Model_pk PRIMARY KEY (id);
ALTER TABLE Model ADD CONSTRAINT Model_idAuthor_fk FOREIGN KEY (idAuthor) REFERENCES Member (id);

CREATE TABLE IF NOT EXISTS ModelVote (
    idModel bigint NOT NULL,
    numUpVotes bigint NOT NULL DEFAULT 0,
    numDownVotes bigint NOT NULL DEFAULT 0
);

ALTER TABLE ModelVote ADD CONSTRAINT ModelVote_pk PRIMARY KEY (idModel);
ALTER TABLE ModelVote ADD CONSTRAINT ModelVote_idModel_fk FOREIGN KEY (idModel) REFERENCES Model (id) ON DELETE CASCADE;

CREATE TABLE IF NOT EXISTS TComment (
    id bigserial NOT NULL,
    idMember bigint NOT NULL,
    idModel bigint NOT NULL,
    content varchar(1024) NOT NULL,
    createDate timestamp NOT NULL DEFAULT now()::timestamp(0),
    deleted boolean NOT NULL DEFAULT false
);

ALTER TABLE TComment ADD CONSTRAINT TComment_pk PRIMARY KEY (id);
ALTER TABLE TComment ADD CONSTRAINT TComment_idMember_fk FOREIGN KEY (idMember) REFERENCES Member (id);
ALTER TABLE TComment ADD CONSTRAINT TComment_idModel_fk FOREIGN KEY (idModel) REFERENCES Model (id)  ON DELETE CASCADE;

CREATE TABLE IF NOT EXISTS Vote (
    idMember bigint NOT NULL,
    idModel bigint NOT NULL,
    createDate timestamp NOT NULL DEFAULT now()::timestamp(0),
    upVote boolean NOT NULL
);

ALTER TABLE Vote ADD CONSTRAINT Vote_pk PRIMARY KEY (idMember, idModel);
ALTER TABLE Vote ADD CONSTRAINT Vote_idMember_fk FOREIGN KEY (idMember) REFERENCES Member (id);7
ALTER TABLE Vote ADD CONSTRAINT Vote_idModel_fk FOREIGN KEY (idModel) REFERENCES Model (id)  ON DELETE CASCADE;

CREATE TABLE IF NOT EXISTS Tag (
    id bigserial NOT NULL,
    name varchar(20) NOT NULL
);

ALTER TABLE Tag ADD CONSTRAINT Tag_pk PRIMARY KEY (id);
ALTER TABLE Tag ADD CONSTRAINT Tag_name_uk UNIQUE (name);

CREATE TABLE IF NOT EXISTS UserInterest (
    idTag bigint NOT NULL,
    idMember bigint NOT NULL
);

ALTER TABLE UserInterest ADD CONSTRAINT UserInterest_pk PRIMARY KEY (idTag, idMember);
ALTER TABLE UserInterest ADD CONSTRAINT UserInterest_idTag_fk FOREIGN KEY (idTag) REFERENCES Tag (id);
ALTER TABLE UserInterest ADD CONSTRAINT UserInterest_idMember_fk FOREIGN KEY (idMember) REFERENCES Member (id);

CREATE TABLE IF NOT EXISTS ModelTag (
    idTag bigint NOT NULL,
    idModel bigint NOT NULL
);

ALTER TABLE ModelTag ADD CONSTRAINT ModelTag_pk PRIMARY KEY (idTag, idModel);
ALTER TABLE ModelTag ADD CONSTRAINT ModelTag_idTag_fk FOREIGN KEY (idTag) REFERENCES Tag (id);
ALTER TABLE ModelTag ADD CONSTRAINT ModelTag_idModel_fk FOREIGN KEY (idModel) REFERENCES Model (id)  ON DELETE CASCADE;

CREATE TABLE IF NOT EXISTS GroupUser (
   idGroup bigint NOT NULL,
   idMember bigint NOT NULL,
   isAdmin boolean NOT NULL DEFAULT false,
   lastAccess timestamp NOT NULL DEFAULT now()::timestamp(0)
);

ALTER TABLE GroupUser ADD CONSTRAINT GroupUser_pk PRIMARY KEY (idGroup, idMember);
ALTER TABLE GroupUser ADD CONSTRAINT GroupUser_idGroup FOREIGN KEY (idGroup) REFERENCES TGroup (id);
ALTER TABLE GroupUser ADD CONSTRAINT GroupUser_idMember FOREIGN KEY (idMember) REFERENCES Member (id);

CREATE TABLE IF NOT EXISTS GroupModel (
    idGroup bigint NOT NULL,
    idModel bigint NOT NULL
);

ALTER TABLE GroupModel ADD CONSTRAINT GroupModel_pk PRIMARY KEY (idGroup, idModel);
ALTER TABLE GroupModel ADD CONSTRAINT GroupModel_idGroup_fk FOREIGN KEY (idGroup) REFERENCES TGroup (id);
ALTER TABLE GroupModel ADD CONSTRAINT GroupModel_idModel_fk FOREIGN KEY (idModel) REFERENCES Model (id) ON DELETE CASCADE;

CREATE TABLE IF NOT EXISTS FriendshipInvite (
    id bigserial NOT NULL,
    idReceiver bigint NOT NULL,
    idSender bigint NOT NULL,
    createDate timestamp NOT NULL DEFAULT now()::timestamp(0),
    accepted boolean DEFAULT NULL
);

ALTER TABLE FriendshipInvite ADD CONSTRAINT FriendshipInvite_pk PRIMARY KEY (id);
ALTER TABLE FriendshipInvite ADD CONSTRAINT FriendshipInvite_idReceiver_fk FOREIGN KEY (idReceiver) REFERENCES Member (id);
ALTER TABLE FriendshipInvite ADD CONSTRAINT FriendshipInvite_idSender_fk FOREIGN KEY (idSender) REFERENCES Member (id);

CREATE TABLE IF NOT EXISTS GroupApplication (
    id bigserial NOT NULL,
    idGroup bigint NOT NULL,
    idMember bigint NOT NULL,
    createDate timestamp NOT NULL DEFAULT now()::timestamp(0),
    accepted boolean DEFAULT NULL
);

ALTER TABLE GroupApplication ADD CONSTRAINT GroupApplication_pk PRIMARY KEY (id);
ALTER TABLE GroupApplication ADD CONSTRAINT GroupApplication_idGroup_fk FOREIGN KEY (idGroup) REFERENCES TGroup (id);
ALTER TABLE GroupApplication ADD CONSTRAINT GroupApplication_idMember_fk FOREIGN KEY (idMember) REFERENCES Member (id);

CREATE TABLE IF NOT EXISTS GroupInvite (
    id bigserial NOT NULL,
    idGroup bigint NOT NULL,
    idReceiver bigint NOT NULL,
    idSender bigint NOT NULL,
    createDate timestamp NOT NULL DEFAULT now()::timestamp(0),
    accepted boolean DEFAULT NULL
);

ALTER TABLE GroupInvite ADD CONSTRAINT GroupInvite_pk PRIMARY KEY (id);
ALTER TABLE GroupInvite ADD CONSTRAINT GroupInvite_idGroup_fk FOREIGN KEY (idGroup) REFERENCES TGroup (id);
ALTER TABLE GroupInvite ADD CONSTRAINT GroupInvite_idReceiver_fk FOREIGN KEY (idReceiver) REFERENCES Member (id);
ALTER TABLE GroupInvite ADD CONSTRAINT GroupInvite_idSender_fk FOREIGN KEY (idSender) REFERENCES Member (id);

CREATE TYPE notification_type AS ENUM ('Publication', 'GroupInvite', 'GroupInviteAccepted', 'GroupApplication', 'GroupApplicationAccepted', 'FriendshipInvite', 'FriendshipInviteAccepted');

CREATE TABLE IF NOT EXISTS Notification (
    id bigserial NOT NULL,
    idFriendshipInvite bigint DEFAULT NULL,
    idGroupApplication bigint DEFAULT NULL,
    idGroupInvite bigint DEFAULT NULL,
    idModel bigint DEFAULT NULL,
    notificationType notification_type NOT NULL,
    createDate timestamp NOT NULL DEFAULT now()::timestamp(0)
);

ALTER TABLE Notification ADD CONSTRAINT Notification_pk PRIMARY KEY (id);
ALTER TABLE Notification ADD CONSTRAINT Notification_idFriendshipInvite_fk FOREIGN KEY (idFriendshipInvite) REFERENCES FriendshipInvite (id);
ALTER TABLE Notification ADD CONSTRAINT Notification_idGroupApplication_fk FOREIGN KEY (idGroupApplication) REFERENCES GroupApplication (id);
ALTER TABLE Notification ADD CONSTRAINT Notification_idGroupInvite_fk FOREIGN KEY (idGroupInvite) REFERENCES GroupInvite (id);
ALTER TABLE Notification ADD CONSTRAINT Notification_idModel_fk FOREIGN KEY (idModel) REFERENCES Model (id)  ON DELETE CASCADE;

ALTER TABLE Notification ADD CONSTRAINT Notification_check CHECK((
    (notificationType IN ('FriendshipInvite', 'FriendshipInviteAccepted') AND idFriendshipInvite IS NOT NULL)::INTEGER + 
    (notificationType IN ('GroupApplication', 'GroupApplicationAccepted') AND idGroupApplication IS NOT NULL)::INTEGER + 
    (notificationType IN ('GroupInvite', 'GroupInviteAccepted') AND idGroupInvite IS NOT NULL)::INTEGER + 
    (notificationType IN ('Publication') AND idModel IS NOT NULL)::INTEGER) = 1 AND
    ((idFriendshipInvite IS NOT NULL)::INTEGER + (idGroupApplication IS NOT NULL)::INTEGER +
     (idGroupInvite IS NOT NULL)::INTEGER + (idModel IS NOT NULL)::INTEGER) = 1
);

CREATE TABLE IF NOT EXISTS UserNotification (
    idMember bigint NOT NULL,
    idNotification bigint NOT NULL,
    seen boolean NOT NULL DEFAULT false
);

ALTER TABLE UserNotification ADD CONSTRAINT UserNotification_pk PRIMARY KEY (idMember, idNotification);
ALTER TABLE UserNotification ADD CONSTRAINT UserNotification_idMember_fk FOREIGN KEY (idMember) REFERENCES Member (id);
ALTER TABLE UserNotification ADD CONSTRAINT UserNotification_idNotification_fk FOREIGN KEY (idNotification) REFERENCES Notification (id) ON DELETE CASCADE;

CREATE TABLE IF NOT EXISTS GroupNotification (
    idGroup bigint NOT NULL,
    idNotification bigint NOT NULL
);

ALTER TABLE GroupNotification ADD CONSTRAINT GroupNotification_pk PRIMARY KEY (idGroup, idNotification);
ALTER TABLE GroupNotification ADD CONSTRAINT GroupNotification_idGroup_fk FOREIGN KEY (idGroup) REFERENCES TGroup (id);
ALTER TABLE GroupNotification ADD CONSTRAINT GroupNotification_idNotification_fk FOREIGN KEY (idNotification) REFERENCES Notification (id) ON DELETE CASCADE;

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
RETURNS TABLE(groupId BIGINT, groupName VARCHAR(70), about VARCHAR, avatarimg VARCHAR) AS $$
    SELECT TGroup.id, TGroup.name, TGroup.about, TGroup.avatarImg
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
  IF (userId IN (SELECT registeredUser.id FROM registeredUser WHERE isAdmin = TRUE)) THEN
    RETURN QUERY SELECT Model.id FROM Model;
  ELSE
    RETURN QUERY SELECT Model.id
    FROM Model
    WHERE idAuthor = userId OR -- my models
          visibility = 'public' OR -- public model
         (visibility = 'friends' AND idAuthor IN (SELECT friendId FROM get_friends_of_member(userId))) -- my friends
    UNION SELECT get_group_visibile_models(userId);
  END IF;
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
    SELECT model_info.name, RegisteredUser.username, model_info.createDate, fileName, numUpVotes, numDownVotes, count(TComment.id)
        FROM model_info
        JOIN RegisteredUser ON RegisteredUser.id = model_info.idAuthor
        LEFT JOIN TComment ON TComment.idModel = model_info.id AND TComment.deleted = false
        WHERE model_info.id = $1
        GROUP BY model_info.name, RegisteredUser.username, model_info.createDate, fileName, numUpVotes, numDownVotes
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
CREATE OR REPLACE FUNCTION get_member_notifications(memberId BIGINT, oldest_date_limit TIMESTAMP, max_notifications_limit INTEGER) RETURNS TABLE(idNotification BIGINT, notType notification_type, idFriendshipInvite BIGINT, idGroupApplication BIGINT, idGroupInvite BIGINT, idModel BIGINT, createDate TIMESTAMP, seen boolean) AS $$
    SELECT Notification.id, Notification.notificationType, Notification.idFriendshipInvite, Notification.idGroupApplication, Notification.idGroupInvite, Notification.idModel, Notification.createDate, UserNotification.seen FROM Notification JOIN UserNotification ON UserNotification.idMember = $1 AND UserNotification.idNotification = Notification.id WHERE createDate >= $2 ORDER BY createDate DESC LIMIT $3
$$ LANGUAGE SQL;

-- List the newest member notifications within a given range with the required data --
CREATE OR REPLACE FUNCTION get_complete_member_notifications (in memberid int8, in oldest_date_limit timestamp, in max_notifications_limit int4)
  RETURNS TABLE(idNotification BIGINT, notType notification_type, idFriendshipInvite BIGINT, idGroupApplication BIGINT, idGroupInvite BIGINT, idModel BIGINT, createDate TIMESTAMP, seen boolean, idMember BIGINT, modelName VARCHAR(70), modelDescription VARCHAR(1024), accepted BOOLEAN, idGroup BIGINT, username VARCHAR(20), groupName VARCHAR(70), groupAbout VARCHAR(1024))
AS
  $BODY$
  SELECT q.*, registeredUser.username, tgroup.name AS groupName, tgroup.about AS groupAbout FROM
    (SELECT
       notification.*,
       (CASE WHEN notification.nottype = 'Publication' THEN model.idAuthor
        WHEN notification.nottype = 'GroupInvite' THEN gInvite.idSender
        WHEN notification.nottype = 'GroupInviteAccepted' THEN gInvite.idReceiver
        WHEN notification.nottype = 'GroupApplication' OR notification.nottype = 'GroupApplicationAccepted' THEN gapplication.idMember
        WHEN notification.nottype = 'FriendshipInvite' THEN fInvite.idSender
        WHEN notification.nottype = 'FriendshipInviteAccepted' THEN fInvite.idReceiver END) AS idMember,
       model.name AS modelName, model.description AS modelDescription,
       (CASE WHEN notification.nottype = 'FriendshipInvite' OR  notification.nottype = 'FriendshipInviteAccepted' THEN fInvite.accepted
        WHEN notification.nottype = 'GroupInvite' OR  notification.nottype = 'GroupInviteAccepted' THEN gInvite.accepted
        WHEN notification.nottype = 'GroupApplication' OR  notification.nottype = 'GroupApplicationAccepted' THEN gApplication.accepted
        ELSE NULL END) AS accepted,
       (CASE WHEN notification.nottype = 'GroupInvite' OR  notification.nottype = 'GroupInviteAccepted' THEN gInvite.idGroup
        WHEN notification.nottype = 'GroupApplication' OR  notification.nottype = 'GroupApplicationAccepted' THEN gapplication.idGroup
        ELSE NULL END) AS idGroup
     FROM get_member_notifications($1, $2, $3) AS notification
       LEFT JOIN (SELECT * FROM model) AS model on idmodel = model.id
       LEFT JOIN (SELECT * FROM friendshipinvite) as fInvite on idfriendshipinvite = fInvite.id
       LEFT JOIN (SELECT * FROM groupinvite) as gInvite on idgroupinvite = gInvite.id
       LEFT JOIN (SELECT * FROM groupapplication) as gapplication on idgroupapplication = gapplication.id) AS q
    JOIN registeredUser ON idMember = registeredUser.id
    LEFT JOIN tgroup ON idGroup = tgroup.id;
$BODY$
LANGUAGE sql VOLATILE;

-- List the newest group notifications within a given range --
CREATE OR REPLACE FUNCTION get_group_notifications(groupId BIGINT, oldest_date_limit TIMESTAMP, max_notifications_limit INTEGER) RETURNS TABLE(idNotification BIGINT, notType notification_type, idFriendshipInvite BIGINT, idGroupApplication BIGINT, idGroupInvite BIGINT, idModel BIGINT, createDate TIMESTAMP) AS $$
    SELECT Notification.id, Notification.notificationType, Notification.idFriendshipInvite, Notification.idGroupApplication, Notification.idGroupInvite, Notification.idModel, Notification.createDate FROM Notification JOIN GroupNotification ON GroupNotification.idGroup = $1 AND GroupNotification.idNotification = Notification.id  WHERE createDate >= $2 ORDER BY createDate DESC LIMIT $3
$$ LANGUAGE SQL;

-- List the newest group notifications within a given range with the required data --
CREATE OR REPLACE FUNCTION get_complete_group_notifications (groupId BIGINT, oldest_date_limit TIMESTAMP, max_notifications_limit INTEGER)
  RETURNS TABLE(idNotification BIGINT, notType notification_type, idFriendshipInvite BIGINT, idGroupApplication BIGINT, idGroupInvite BIGINT, idModel BIGINT, createDate TIMESTAMP, idMember BIGINT, modelName VARCHAR(70), modelDescription VARCHAR(1024),
  accepted BOOLEAN, idGroup BIGINT, idSender BIGINT, username VARCHAR(20), hash TEXT, senderUsername VARCHAR(20))
AS
  $BODY$
  SELECT
    q.*, registeredUser.username, get_user_hash(idMember), senderUser.username AS senderUsername
  FROM
    (SELECT
       notification.*,
       (CASE WHEN notification.nottype = 'Publication' THEN model.idAuthor
        WHEN notification.nottype = 'GroupInvite' THEN gInvite.idReceiver
        WHEN notification.nottype = 'GroupInviteAccepted' THEN gInvite.idReceiver
        WHEN notification.nottype = 'GroupApplication' OR notification.nottype = 'GroupApplicationAccepted' THEN gapplication.idMember
        WHEN notification.nottype = 'FriendshipInvite' THEN fInvite.idSender
        WHEN notification.nottype = 'FriendshipInviteAccepted' THEN fInvite.idReceiver END) AS idMember,
       model.name, model.description,
       (CASE WHEN notification.nottype = 'FriendshipInvite' OR  notification.nottype = 'FriendshipInviteAccepted' THEN fInvite.accepted
        WHEN notification.nottype = 'GroupInvite' OR  notification.nottype = 'GroupInviteAccepted' THEN gInvite.accepted
        WHEN notification.nottype = 'GroupApplication' OR  notification.nottype = 'GroupApplicationAccepted' THEN gApplication.accepted
        ELSE NULL END) AS accepted,
       (CASE WHEN notification.nottype = 'GroupInvite' OR  notification.nottype = 'GroupInviteAccepted' THEN gInvite.idGroup
        WHEN notification.nottype = 'GroupApplication' OR  notification.nottype = 'GroupApplicationAccepted' THEN gapplication.idGroup
        ELSE NULL END) AS idGroup,
       (CASE WHEN notification.nottype = 'GroupInvite' THEN gInvite.idSender
        WHEN notification.nottype = 'GroupInviteAccepted' THEN gInvite.idSender END) AS idSender
     FROM
       get_group_notifications($1, $2, $3) AS notification
       LEFT JOIN model on idmodel = model.id
       LEFT JOIN friendshipinvite as fInvite on idfriendshipinvite = fInvite.id
       LEFT JOIN groupinvite as gInvite on idgroupinvite = gInvite.id
       LEFT JOIN groupapplication as gapplication on idgroupapplication = gapplication.id) AS q
    JOIN registeredUser ON idMember = registeredUser.id
    LEFT JOIN registeredUser AS senderUser ON idSender = senderUser.id;
$BODY$
LANGUAGE sql VOLATILE;

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


DROP TRIGGER IF EXISTS generate_publication_notification_trigger ON Model;
DROP TRIGGER IF EXISTS generate_publication_notification_trigger_on_change ON Model;
DROP TRIGGER IF EXISTS generate_group_publication_notification_trigger ON GroupModel;
DROP TRIGGER IF EXISTS generate_group_invite_notification_trigger ON GroupInvite;
DROP TRIGGER IF EXISTS generate_group_application_notification_trigger ON GroupApplication;
DROP TRIGGER IF EXISTS generate_frienship_invite_notification_trigger ON FriendshipInvite;
DROP TRIGGER IF EXISTS generate_group_invite_accepted_notification_trigger ON GroupInvite;
DROP TRIGGER IF EXISTS generate_group_application_notification_accepted_trigger ON GroupApplication;
DROP TRIGGER IF EXISTS generate_frienship_invite_notification_accepted_trigger ON FriendshipInvite;
DROP TRIGGER IF EXISTS check_not_existent_friendship_trigger ON FriendshipInvite;
DROP TRIGGER IF EXISTS add_to_group_on_invite_acceptance_trigger ON GroupInvite;
DROP TRIGGER IF EXISTS add_to_group_on_application_acceptance_trigger ON GroupApplication;
DROP TRIGGER IF EXISTS create_friendship_on_invite_acceptance_trigger ON FriendshipInvite;
DROP TRIGGER IF EXISTS friendship_symmetry_trigger ON Friendship;
DROP TRIGGER IF EXISTS insert_model_insert_model_vote_trigger ON Model;
DROP TRIGGER IF EXISTS insert_vote_update_model_vote_trigger ON Vote;
DROP TRIGGER IF EXISTS update_vote_update_model_vote_trigger ON Vote;
DROP TRIGGER IF EXISTS delete_vote_update_model_vote_trigger ON Vote;

------------------------------
-- PUBLICATION NOTIFICATION --
------------------------------

-- Event: Model is published
-- Database Event: after insert on Model table
-- Condition: none
-- Action: create publication notification and associate it with author's friends if Model's visibility is public or friends

CREATE OR REPLACE FUNCTION generate_publication_Notification() RETURNS TRIGGER AS $$
    DECLARE
        notificationId bigint;
        friendId bigint;
    BEGIN
        IF (NOT EXISTS(SELECT Notification.id FROM Notification WHERE idModel = NEW.id LIMIT 1)) THEN
            INSERT INTO Notification (idModel, Notificationtype) VALUES (NEW.id, 'Publication'::Notification_type) RETURNING id INTO NotificationId;
        ELSE
            SELECT Notification.id INTO notificationId FROM Notification WHERE idModel = NEW.id LIMIT 1;
        END IF;

        IF NEW.visibility IN ('public', 'friends') THEN
            FOR friendId IN SELECT friends_of_member.friendId FROM get_friends_of_member(NEW.idAuthor) AS friends_of_member
            LOOP
                INSERT INTO UserNotification (idNotification, idMember) SELECT notificationId, friendId WHERE NOT EXISTS (
                    SELECT 1 FROM UserNotification
                    WHERE idNotification = notificationId AND
                          idMember = friendId
                );
            END LOOP;
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_publication_notification_trigger AFTER INSERT ON Model
FOR EACH ROW EXECUTE PROCEDURE generate_publication_notification();

-- Event: Model visibility is changed
-- Database Event: after update on Model table
-- Condition: visibility changes and NEW visibility is public or friends
-- Action: associate publication Notification with author's friends

CREATE TRIGGER generate_publication_notification_trigger_on_change
AFTER UPDATE ON Model
FOR EACH ROW
WHEN (OLD.visibility = 'private' AND NEW.visibility IN ('public', 'friends'))
EXECUTE PROCEDURE generate_publication_notification();

-- Event: Model is shared with group
-- Database Event: after insert on GroupModel table
-- Condition: none
-- Action: associate publication Notification with group

CREATE OR REPLACE FUNCTION generate_group_publication_notification() RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO GroupNotification (idGroup, idNotification)
            SELECT NEW.idGroup, Notification.id
            FROM Notification
            WHERE Notification.idModel = NEW.idModel;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_group_publication_notification_trigger AFTER INSERT ON GroupModel
FOR EACH ROW EXECUTE PROCEDURE generate_group_publication_notification();

------------------
-- GROUP INVITE --
------------------

-- Event: a member is invited to join a group
-- Database Event: after insert on GroupInvite
-- Condition: N/A
-- Action: Create Notification for the invited member

CREATE OR REPLACE FUNCTION generate_group_invite_notification() RETURNS TRIGGER AS $$
    DECLARE
        notificationId bigint;
    BEGIN
        INSERT INTO Notification (idGroupInvite, notificationtype) VALUES (NEW.id, 'GroupInvite') RETURNING id INTO notificationId;
        INSERT INTO UserNotification (idMember, idNotification) VALUES (NEW.idReceiver, notificationId);
        INSERT INTO GroupNotification (idGroup, idNotification) VALUES (NEW.idGroup, notificationId);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER generate_group_invite_notification_trigger AFTER INSERT ON GroupInvite
FOR EACH ROW EXECUTE PROCEDURE generate_group_invite_notification();

-----------------------
-- FRIENDSHIP INVITE --
-----------------------

-- Event: a member sends a friendship invite to another member
-- Database Event: after insert on FriendshipInvite
-- Condition: N/A
-- Action: Create Notification for the invited member

CREATE OR REPLACE FUNCTION generate_frienship_invite_notification() RETURNS TRIGGER AS $$
    DECLARE
        notificationId bigint;
    BEGIN
        INSERT INTO Notification (idFriendshipInvite, notificationType) VALUES (NEW.id, 'FriendshipInvite') RETURNING id INTO notificationId;
        INSERT INTO UserNotification (idMember, idNotification) VALUES (NEW.idReceiver, notificationId);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_frienship_invite_notification_trigger AFTER INSERT ON FriendshipInvite
FOR EACH ROW EXECUTE PROCEDURE generate_frienship_invite_notification();


---------------------------
-- GROUP INVITE ACCEPTED --
---------------------------

-- Event: an invited member accepts the invite to join a group
-- Database Event: after update on GroupInvite
-- Condition: when accepted is changed to true
-- Action: create a Notification for the group admin that invited the member and for the group

CREATE OR REPLACE FUNCTION generate_group_invite_accepted_notification() RETURNS TRIGGER AS $$
    DECLARE
        notificationId bigint;
    BEGIN
        INSERT INTO Notification (idGroupInvite, notificationtype) VALUES (NEW.id, 'GroupInviteAccepted') RETURNING id INTO notificationId;
        INSERT INTO UserNotification (idMember, idNotification) VALUES (NEW.idSender, notificationId);
        INSERT INTO GroupNotification (idGroup, idNotification) VALUES (NEW.idGroup, notificationId);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER generate_group_invite_accepted_notification_trigger AFTER UPDATE ON GroupInvite
FOR EACH ROW
WHEN (OLD.accepted IS NULL AND NEW.accepted = true)
EXECUTE PROCEDURE generate_group_invite_accepted_notification();

--------------------------------
-- GROUP APPLICATION ACCEPTED --
--------------------------------

-- Event: a group admin accepts the application of a member
-- Database Event: after update on GroupApplication
-- Condition: when accepted is changed to true
-- Action: create Notification for the accepted user and for the group

CREATE OR REPLACE FUNCTION generate_group_application_accepted_notification() RETURNS TRIGGER AS $$
    DECLARE
        notificationId bigint;
        adminId bigint;
    BEGIN
        INSERT INTO Notification (idGroupApplication, notificationType) VALUES (NEW.id, 'GroupApplicationAccepted') RETURNING id INTO notificationId;
        INSERT INTO UserNotification (idMember, idNotification) VALUES (NEW.idMember, notificationId);
        INSERT INTO GroupNotification (idGroup, idNotification) VALUES (NEW.idGroup, notificationId);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_group_application_notification_accepted_trigger AFTER UPDATE ON GroupApplication
FOR EACH ROW
WHEN (OLD.accepted IS NULL AND NEW.accepted = true)
EXECUTE PROCEDURE generate_group_application_accepted_notification();

--------------------------------
-- GROUP APPLICATION REQUESTES --
--------------------------------

-- Event: a member applied to a group
-- Database Event: after insert on GroupApplication
-- Condition: N/A
-- Action: create Notification for the group

CREATE OR REPLACE FUNCTION generate_group_application_notification() RETURNS TRIGGER AS $$
    DECLARE
        notificationId bigint;
        adminId bigint;
    BEGIN
        INSERT INTO Notification (idGroupApplication, notificationType) VALUES (NEW.id, 'GroupApplication') RETURNING id INTO notificationId;
        FOR adminId IN SELECT idMember FROM GroupUser WHERE idGroup = NEW.idGroup AND isAdmin = TRUE LOOP
          INSERT INTO UserNotification (idMember, idNotification) VALUES (adminId, notificationId);
        END LOOP;
        INSERT INTO UserNotification (idMember, idNotification) VALUES (NEW.idMember, notificationId);
        INSERT INTO GroupNotification (idGroup, idNotification) VALUES (NEW.idGroup, notificationId);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_group_application_notification_trigger AFTER INSERT ON GroupApplication
FOR EACH ROW
EXECUTE PROCEDURE generate_group_application_notification();

--------------------------------
-- FRIENDSHIP INVITE ACCEPTED --
--------------------------------

-- Event: a members accepts the friendship of another member
-- Database Event: after update on FriendshipInvite
-- Condition: when accepted is changed to true
-- Action: create Notification and userNotification

CREATE OR REPLACE FUNCTION generate_frienship_invite_accepted_notification() RETURNS TRIGGER AS $$
    DECLARE
        notificationId bigint;
    BEGIN
        INSERT INTO Notification (idFriendshipInvite, notificationType) VALUES (NEW.id, 'FriendshipInviteAccepted') RETURNING id INTO notificationId;
        INSERT INTO UserNotification (idMember, idNotification) VALUES (NEW.idSender, notificationId);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_frienship_invite_notification_accepted_trigger AFTER UPDATE ON FriendshipInvite
FOR EACH ROW WHEN (OLD.accepted IS NULL AND NEW.accepted = true)
EXECUTE PROCEDURE generate_frienship_invite_accepted_notification();

-- Event: a member sends a friendship invitation to other
-- Database Event: before insert on friendishInvite table
-- Condition: none
-- Action: raise exception if both members are already friends or if one has already sent an invitation to the other

CREATE OR REPLACE FUNCTION check_not_existent_friendship() RETURNS TRIGGER AS $$
    DECLARE
        minId bigint;
        maxId bigint;
    BEGIN
        minId := LEAST(NEW.idReceiver, NEW.idSender);
        maxId := GREATEST(NEW.idReceiver, NEW.idSender);

        IF EXISTS(SELECT 1 FROM Friendship WHERE idMember1 = minId AND idMember2 = maxId) THEN
            RAISE EXCEPTION 'Cannot re-invite friends (friendship). (%, %)', NEW.idReceiver, NEW.idSender;
        ELSIF EXISTS(SELECT 1 FROM FriendshipInvite WHERE
          ((idReceiver = NEW.idSender AND idSender = NEW.idReceiver) OR (idReceiver = NEW.idReceiver AND idSender = NEW.idSender))
          AND accepted IS NULL) THEN
            RAISE EXCEPTION 'Cannot re-invite friends (FriendshipInvite). (%, %)', NEW.idReceiver, NEW.idSender;
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_not_existent_friendship_trigger BEFORE INSERT ON FriendshipInvite
FOR EACH ROW EXECUTE PROCEDURE check_not_existent_friendship();

-----------------------------------
-- ADD TO GROUP ON INVITE ACCEPT --
-----------------------------------

CREATE OR REPLACE FUNCTION add_to_group_on_invite_acceptance() RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO GroupUser (idGroup, idMember) VALUES (NEW.idGroup, NEW.idReceiver);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER add_to_group_on_invite_acceptance_trigger AFTER UPDATE ON GroupInvite
FOR EACH ROW
WHEN (OLD.accepted IS NULL AND NEW.accepted = true)
EXECUTE PROCEDURE add_to_group_on_invite_acceptance();

---------------------------------------
-- ADD TO GROUP ON APLICATION ACCEPT --
---------------------------------------

CREATE OR REPLACE FUNCTION add_to_group_on_application_acceptance() RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO GroupUser (idGroup, idMember) VALUES (NEW.idGroup, NEW.idMember);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER add_to_group_on_application_acceptance_trigger AFTER UPDATE ON GroupApplication
FOR EACH ROW
WHEN (OLD.accepted IS NULL AND NEW.accepted = true)
EXECUTE PROCEDURE add_to_group_on_application_acceptance();

-- FRIENSHIP SYMMETRY RULE --

CREATE OR REPLACE FUNCTION friendship_symmetry() RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO Friendship (idMember1, idMember2, createDate) VALUES (NEW.idMember2, NEW.idMember1, NEW.createDate);
        RETURN NULL;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER friendship_symmetry_trigger BEFORE INSERT ON Friendship
FOR EACH ROW WHEN (NEW.idMember1 > NEW.idMember2) EXECUTE PROCEDURE friendship_symmetry();

------------------------------
-- FRIENDSHIP INVITE ACCEPT --
------------------------------

CREATE OR REPLACE FUNCTION create_friendship_on_invite_acceptance() RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO Friendship (idMember1, idMember2) VALUES (NEW.idReceiver, NEW.idSender);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_friendship_on_invite_acceptance_trigger AFTER UPDATE ON FriendshipInvite
FOR EACH ROW WHEN (OLD.accepted IS NULL AND NEW.accepted = True) EXECUTE PROCEDURE create_friendship_on_invite_acceptance();



-- Model Vote --

CREATE OR REPLACE FUNCTION insert_model_insert_model_vote() RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO ModelVote (idModel) VALUES (NEW.id);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_model_insert_model_vote_trigger AFTER INSERT ON Model
FOR EACH ROW EXECUTE PROCEDURE insert_model_insert_model_vote();

-- Model Vote Update --

CREATE OR REPLACE FUNCTION insert_vote_update_model_vote() RETURNS TRIGGER AS $$
    BEGIN
        IF NEW.upvote = TRUE THEN
            UPDATE ModelVote SET numUpVotes = numUpVotes + 1 WHERE idModel = NEW.idModel;
        ELSE
            UPDATE ModelVote SET numDownVotes = numDownVotes + 1 WHERE idModel = NEW.idModel;
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_vote_update_model_vote_trigger AFTER INSERT ON Vote
FOR EACH ROW EXECUTE PROCEDURE insert_vote_update_model_vote();

CREATE OR REPLACE FUNCTION update_vote_update_model_vote() RETURNS TRIGGER AS $$
    BEGIN
        IF NEW.upVote = TRUE THEN
            UPDATE ModelVote SET (numUpVotes, numDownVotes) = (numUpVotes + 1, numDownVotes - 1) WHERE idModel = NEW.idModel;
        ELSE
            UPDATE ModelVote SET (numUpVotes, numDownVotes) = (numUpVotes - 1, numDownVotes + 1) WHERE idModel = NEW.idModel;
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_vote_update_model_vote_trigger AFTER UPDATE ON Vote
FOR EACH ROW WHEN (OLD.upVote <> NEW.upVote) EXECUTE PROCEDURE update_vote_update_model_vote();

CREATE OR REPLACE FUNCTION delete_vote_update_model_vote() RETURNS TRIGGER AS $$
    BEGIN
        IF OLD.upvote = TRUE THEN
            UPDATE ModelVote SET numUpVotes = numUpVotes - 1 WHERE idModel = NEW.idModel;
        ELSE
            UPDATE ModelVote SET numDownVotes = numDownVotes - 1 WHERE idModel = NEW.idModel;
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_vote_update_model_vote_trigger AFTER DELETE ON Vote
FOR EACH ROW EXECUTE PROCEDURE delete_vote_update_model_vote();
