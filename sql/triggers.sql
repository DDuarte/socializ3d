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
            FOR friendId IN SELECT idMember1 FROM Friendship WHERE idMember2 = NEW.idAuthor UNION ALL SELECT idMember2 FROM Friendship WHERE idMember1 = NEW.idAuthor
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
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER generate_group_invite_notification_trigger AFTER INSERT ON GroupInvite
FOR EACH ROW EXECUTE PROCEDURE generate_group_invite_notification();

-----------------------
-- GROUP APPLICATION --
-----------------------

-- Event: a member wants to join a public group
-- Database Event: after insert on GroupApplication
-- Condition: N/A
-- Action: Create Notification for all the group admins of a group

CREATE OR REPLACE FUNCTION generate_group_application_notification() RETURNS TRIGGER AS $$
    DECLARE 
        notificationId bigint;
        adminId bigint;
    BEGIN
        INSERT INTO Notification (idGroupApplication, notificationType) VALUES (NEW.id, 'GroupApplication') RETURNING id INTO notificationId;
        FOR adminId IN SELECT idMember FROM GroupUser WHERE idGroup = NEW.idGroup AND isAdmin = TRUE LOOP
            INSERT INTO UserNotification (idMember, idNotification) VALUES (adminId, notificationId);
        END LOOP;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_group_application_notification_trigger AFTER INSERT ON GroupApplication
FOR EACH ROW EXECUTE PROCEDURE generate_group_application_notification();

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
        ELSIF EXISTS(SELECT 1 FROM FriendshipInvite WHERE idReceiver = NEW.idSender AND idSender = NEW.idReceiver) THEN
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

-- FRIENSHIP SYMMETRY RULE --

CREATE OR REPLACE FUNCTION friendship_symmetry() RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO Friendship (idMember1, idMember2, createDate) VALUES (NEW.idMember2, NEW.idMember1, NEW.createDate);
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER friendship_symmetry_trigger BEFORE INSERT ON Friendship
FOR EACH ROW WHEN (NEW.idMember1 > NEW.idMember2) EXECUTE PROCEDURE friendship_symmetry();
