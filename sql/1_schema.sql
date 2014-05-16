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
    registerDate timestamp NOT NULL DEFAULT now(),
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
    createDate timestamp NOT NULL DEFAULT now(),
    deleteDate timestamp DEFAULT NULL,
    visibility visibility_group NOT NULL
);

ALTER TABLE TGroup ADD CONSTRAINT TGroup_pk PRIMARY KEY (id);
ALTER TABLE TGroup ADD CONSTRAINT TGroup_deleteDate_check CHECK (deleteDate IS NULL OR deleteDate > createDate);

CREATE TABLE IF NOT EXISTS Friendship (
    idMember1 bigint NOT NULL,
    idMember2 bigint NOT NULL,
    createDate timestamp NOT NULL DEFAULT now()
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
    createDate timestamp NOT NULL DEFAULT now(),
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
    createDate timestamp NOT NULL DEFAULT now(),
    deleted boolean NOT NULL DEFAULT false
);

ALTER TABLE TComment ADD CONSTRAINT TComment_pk PRIMARY KEY (id);
ALTER TABLE TComment ADD CONSTRAINT TComment_idMember_fk FOREIGN KEY (idMember) REFERENCES Member (id);
ALTER TABLE TComment ADD CONSTRAINT TComment_idModel_fk FOREIGN KEY (idModel) REFERENCES Model (id);

CREATE TABLE IF NOT EXISTS Vote (
    idMember bigint NOT NULL,
    idModel bigint NOT NULL,
    createDate timestamp NOT NULL DEFAULT now(),
    upVote boolean NOT NULL
);

ALTER TABLE Vote ADD CONSTRAINT Vote_pk PRIMARY KEY (idMember, idModel);
ALTER TABLE Vote ADD CONSTRAINT Vote_idMember_fk FOREIGN KEY (idMember) REFERENCES Member (id);
ALTER TABLE Vote ADD CONSTRAINT Vote_idModel_fk FOREIGN KEY (idModel) REFERENCES Model (id);

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
ALTER TABLE ModelTag ADD CONSTRAINT ModelTag_idModel_fk FOREIGN KEY (idModel) REFERENCES Model (id);

CREATE TABLE IF NOT EXISTS GroupUser (
   idGroup bigint NOT NULL,
   idMember bigint NOT NULL,
   isAdmin boolean NOT NULL DEFAULT false,
   lastAccess timestamp NOT NULL DEFAULT now()
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
ALTER TABLE GroupModel ADD CONSTRAINT GroupModel_idModel_fk FOREIGN KEY (idModel) REFERENCES Model (id);

CREATE TABLE IF NOT EXISTS FriendshipInvite (
    id bigserial NOT NULL,
    idReceiver bigint NOT NULL,
    idSender bigint NOT NULL,
    createDate timestamp NOT NULL DEFAULT now(),
    accepted boolean DEFAULT NULL
);

ALTER TABLE FriendshipInvite ADD CONSTRAINT FriendshipInvite_pk PRIMARY KEY (id);
ALTER TABLE FriendshipInvite ADD CONSTRAINT FriendshipInvite_idReceiver_fk FOREIGN KEY (idReceiver) REFERENCES Member (id);
ALTER TABLE FriendshipInvite ADD CONSTRAINT FriendshipInvite_idSender_fk FOREIGN KEY (idSender) REFERENCES Member (id);

CREATE TABLE IF NOT EXISTS GroupApplication (
    id bigserial NOT NULL,
    idGroup bigint NOT NULL,
    idMember bigint NOT NULL,
    createDate timestamp NOT NULL DEFAULT now(),
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
    createDate timestamp NOT NULL DEFAULT now(),
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
    createDate timestamp NOT NULL DEFAULT now()
);

ALTER TABLE Notification ADD CONSTRAINT Notification_pk PRIMARY KEY (id);
ALTER TABLE Notification ADD CONSTRAINT Notification_idFriendshipInvite_fk FOREIGN KEY (idFriendshipInvite) REFERENCES FriendshipInvite (id);
ALTER TABLE Notification ADD CONSTRAINT Notification_idGroupApplication_fk FOREIGN KEY (idGroupApplication) REFERENCES GroupApplication (id);
ALTER TABLE Notification ADD CONSTRAINT Notification_idGroupInvite_fk FOREIGN KEY (idGroupInvite) REFERENCES GroupInvite (id);
ALTER TABLE Notification ADD CONSTRAINT Notification_idModel_fk FOREIGN KEY (idModel) REFERENCES Model (id);

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
ALTER TABLE UserNotification ADD CONSTRAINT UserNotification_idNotification_fk FOREIGN KEY (idNotification) REFERENCES Notification (id);

CREATE TABLE IF NOT EXISTS GroupNotification (
    idGroup bigint NOT NULL,
    idNotification bigint NOT NULL
);

ALTER TABLE GroupNotification ADD CONSTRAINT GroupNotification_pk PRIMARY KEY (idGroup, idNotification);
ALTER TABLE GroupNotification ADD CONSTRAINT GroupNotification_idGroup_fk FOREIGN KEY (idGroup) REFERENCES TGroup (id);
ALTER TABLE GroupNotification ADD CONSTRAINT GroupNotification_idNotification_fk FOREIGN KEY (idNotification) REFERENCES Notification (id);