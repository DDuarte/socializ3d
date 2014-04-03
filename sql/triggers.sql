DROP TRIGGER IF EXISTS generate_publication_notification_trigger ON model;
DROP TRIGGER IF EXISTS generate_publication_notification_trigger_on_change ON model;
DROP TRIGGER IF EXISTS generate_group_publication_notification_trigger ON groupmodel;
DROP TRIGGER IF EXISTS generate_groupinvite_notification_trigger ON groupinvite;
DROP TRIGGER IF EXISTS generate_groupapplication_notification_trigger ON groupapplication;
DROP TRIGGER IF EXISTS generate_friendshipinvite_notification_trigger ON friendshipinvite;
DROP TRIGGER IF EXISTS generate_groupinviteaccepted_notification_trigger ON groupinvite;
DROP TRIGGER IF EXISTS generate_groupapplication_notificationaccepted_trigger ON groupapplication;
DROP TRIGGER IF EXISTS generate_friendshipinvite_notificationaccepted_trigger ON friendshipinvite;
DROP TRIGGER IF EXISTS check_not_existent_friendship_trigger ON friendshipInvite;
DROP TRIGGER IF EXISTS check_not_existent_friendship_invite_trigger ON friendshipInvite;

-- evento, condição e código

------------------------------
-- PUBLICATION NOTIFICATION --
------------------------------

-- Event: model is published
-- Database Event: after insert on model table
-- Condition: none
-- Action: create publication notification and associate it with author's friends if model's visibility is public or friends 

CREATE OR REPLACE FUNCTION generate_publication_notification() RETURNS TRIGGER AS $$
    DECLARE
        notificationId bigint;
        friendId bigint;
    BEGIN
        IF (NOT EXISTS(SELECT notification.id FROM notification WHERE idmodel = NEW.id LIMIT 1)) THEN
            INSERT INTO notification (idmodel, notificationtype) VALUES (NEW.id, 'Publication'::notification_type) RETURNING id INTO notificationId;
        ELSE
            SELECT notification.id INTO notificationId FROM notification WHERE idmodel = NEW.id LIMIT 1;
        END IF;

        IF NEW.visibility IN ('public', 'friends') THEN 
            FOR friendId IN SELECT idmember1 FROM friendship WHERE idmember2 = NEW.idAuthor UNION SELECT idmember2 FROM friendship WHERE idmember1 = NEW.idAuthor
            LOOP
                INSERT INTO usernotification (idnotification, idmember) SELECT notificationId, friendId WHERE NOT EXISTS ( 
                    SELECT * FROM usernotification 
                    WHERE idnotification = notificationId AND 
                          idmember = friendId 
                );
            END LOOP;
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_publication_notification_trigger AFTER INSERT ON model
FOR EACH ROW EXECUTE PROCEDURE generate_publication_notification();

-- Event: model visibility is changed
-- Database Event: after update on model table
-- Condition: visibility changes and new visibility is public or friends
-- Action: associate publication notification with author's friends

CREATE TRIGGER generate_publication_notification_trigger_on_change 
AFTER UPDATE ON model
FOR EACH ROW 
WHEN (old.visibility = 'private' AND NEW.visibility IN ('public', 'friends'))  
EXECUTE PROCEDURE generate_publication_notification();

-- Event: model is shared with group
-- Database Event: after insert on groupmodel table
-- Condition: none
-- Action: associate publication notification with group

CREATE OR REPLACE FUNCTION generate_group_publication_notification() RETURNS TRIGGER AS $$
    BEGIN    
        INSERT INTO groupnotification(idgroup, idnotification) 
            SELECT NEW.idgroup, notification.id 
            FROM notification 
            WHERE notification.idmodel = NEW.idmodel;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_group_publication_notification_trigger AFTER INSERT ON groupmodel
FOR EACH ROW EXECUTE PROCEDURE generate_group_publication_notification();

------------------
-- GROUP INVITE --
------------------

-- Event: a member is invited to join a group
-- Database Event: after insert on groupinvite
-- Condition: N/A
-- Action: Create notification for the invited member

CREATE OR REPLACE FUNCTION generate_groupinvite_notification() RETURNS TRIGGER AS $example_table$
    DECLARE 
        notificationId bigint;
    BEGIN
        INSERT INTO notification (idgroupinvite, notificationtype) VALUES (NEW.id, 'GroupInvite'::notification_type) RETURNING id INTO notificationId;
        INSERT INTO usernotification (idmember, idnotification) VALUES (NEW.idreceiver, notificationId);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER generate_groupinvite_notification_trigger AFTER INSERT ON groupinvite
FOR EACH ROW EXECUTE PROCEDURE generate_groupinvite_notification();

-----------------------
-- GROUP APPLICATION --
-----------------------

-- Event: a member wants to join a public group
-- Database Event: after insert on groupapplication
-- Condition: N/A
-- Action: Create notification for all the group admins of a group

CREATE OR REPLACE FUNCTION generate_groupapplication_notification() RETURNS TRIGGER AS $example_table$
    DECLARE 
        notificationId bigint;
        adminId bigint;
    BEGIN
        INSERT INTO notification (idgroupapplication, notificationtype) VALUES (NEW.id, 'GroupApplication'::notification_type) RETURNING id INTO notificationId;
        FOR adminId IN SELECT idmember FROM GroupUser WHERE idgroup = NEW.idgroup AND isAdmin = TRUE LOOP
            INSERT INTO usernotification (idmember, idnotification) VALUES (adminId, notificationId);
        END LOOP;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_groupapplication_notification_trigger AFTER INSERT ON groupapplication
FOR EACH ROW EXECUTE PROCEDURE generate_groupapplication_notification();

-----------------------
-- FRIENDSHIP INVITE --
-----------------------

-- Event: a member sends a friendship invite to another member
-- Database Event: after insert on friendshipinvite
-- Condition: N/A
-- Action: Create notification for the invited member

CREATE OR REPLACE FUNCTION generate_friendshipinvite_notification() RETURNS TRIGGER AS $example_table$
    DECLARE 
        notificationId bigint;
    BEGIN
        INSERT INTO notification (idfriendshipinvite, notificationtype) VALUES (NEW.id, 'FriendshipInvite'::notification_type) RETURNING id INTO notificationId;
        INSERT INTO usernotification (idmember, idnotification) VALUES (NEW.idreceiver, notificationId);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_friendshipinvite_notification_trigger AFTER INSERT ON friendshipinvite
FOR EACH ROW EXECUTE PROCEDURE generate_friendshipinvite_notification();


---------------------------
-- GROUP INVITE ACCEPTED --
---------------------------

-- Event: an invited member accepts the invite to join a group
-- Database Event: after update on groupinvite
-- Condition: when accepted is changed to true
-- Action: create a notification for the group admin that invited the member and for the group

CREATE OR REPLACE FUNCTION generate_groupinviteaccepted_notification() RETURNS TRIGGER AS $example_table$
    DECLARE 
        notificationId bigint;
    BEGIN
        INSERT INTO notification (idgroupinvite, notificationtype) VALUES (NEW.id, 'GroupInviteAccepted'::notification_type) RETURNING id INTO notificationId;
        INSERT INTO usernotification (idmember, idnotification) VALUES (NEW.idsender, notificationId);
        INSERT INTO groupnotification (idgroup, idnotification) VALUES (NEW.idgroup, notificationId);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER generate_groupinviteaccepted_notification_trigger AFTER UPDATE ON groupinvite
FOR EACH ROW 
WHEN (old.accepted IS NULL AND NEW.accepted = true)
EXECUTE PROCEDURE generate_groupinviteaccepted_notification();

--------------------------------
-- GROUP APPLICATION ACCEPTED --
--------------------------------

-- Event: a group admin accepts the application of a member
-- Database Event: after update on groupapplication
-- Condition: when accepted is changed to true
-- Action: create notification for the accepted user and for the group

CREATE OR REPLACE FUNCTION generate_groupapplicationaccepted_notification() RETURNS TRIGGER AS $example_table$
    DECLARE 
        notificationId bigint;
        adminId bigint;
    BEGIN
        INSERT INTO notification (idgroupapplication, notificationtype) VALUES (NEW.id, 'GroupApplicationAccepted'::notification_type) RETURNING id INTO notificationId;
        INSERT INTO usernotification (idmember, idnotification) VALUES (NEW.idmember, notificationId);
        INSERT INTO groupnotification (idgroup, idnotification) VALUES (NEW.idgroup, notificationId);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_groupapplication_notificationaccepted_trigger AFTER UPDATE ON groupapplication
FOR EACH ROW 
WHEN (old.accepted IS NULL AND NEW.accepted = true)
EXECUTE PROCEDURE generate_groupapplicationaccepted_notification();

--------------------------------
-- FRIENDSHIP INVITE ACCEPTED --
--------------------------------

-- Event: a members accepts the friendship of another member
-- Database Event: after update on friendshipinvite
-- Condition: when accepted is changed to true
-- Action: create notification and usernotification

CREATE OR REPLACE FUNCTION generate_friendshipinviteaccepted_notification() RETURNS TRIGGER AS $example_table$
    DECLARE 
        notificationId bigint;
    BEGIN
        INSERT INTO notification (idfriendshipinvite, notificationtype) VALUES (NEW.id, 'FriendshipInviteAccepted'::notification_type) RETURNING id INTO notificationId;
        INSERT INTO usernotification (idmember, idnotification) VALUES (NEW.idsender, notificationId);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_friendshipinvite_notificationaccepted_trigger AFTER UPDATE ON friendshipinvite
FOR EACH ROW WHEN (old.accepted IS NULL AND NEW.accepted = true)
EXECUTE PROCEDURE generate_friendshipinviteaccepted_notification();

-- Event: a member sends a friendship invitation to other
-- Database Event: before insert on friendishInvite table
-- Condition: none
-- Action: raise exception if both members are already friends or if one has already sent an invitation to the other

CREATE OR REPLACE FUNCTION check_not_existent_friendship() RETURNS TRIGGER AS $$
    DECLARE
        minId bigint;
        maxId bigint;
    BEGIN
        minId := LEAST(NEW.idreceiver, NEW.idsender);
        maxId := GREATEST(NEW.idreceiver, NEW.idsender);
        
        IF EXISTS(SELECT 1 FROM friendship WHERE idmember1 = minId AND idmember2 = maxId) THEN
            RAISE EXCEPTION 'Cannot re-invite friends (friendship). (%, %)', NEW.idreceiver, NEW.idsender;
        ELSIF EXISTS(SELECT 1 FROM friendshipInvite WHERE idreceiver = NEW.idsender AND idsender = NEW.idreceiver) THEN
            RAISE EXCEPTION 'Cannot re-invite friends (friendshipInvite). (%, %)', NEW.idreceiver, NEW.idsender;
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_not_existent_friendship_trigger BEFORE INSERT ON friendshipInvite
FOR EACH ROW EXECUTE PROCEDURE check_not_existent_friendship();

------------------------------
-- FRIENDSHIP INVITE ACCEPT --
------------------------------

CREATE OR REPLACE FUNCTION create_friendship_on_invite_acceptance() RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO Friendship (idMember1, idMember2) VALUES (NEW.idReceiver, NEW.idSender);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_friendship_on_invite_acceptance_trigger AFTER UPDATE ON friendshipInvite
FOR EACH ROW WHEN (OLD.accepted IS NULL AND NEW.accepted = True) EXECUTE PROCEDURE create_friendship_on_invite_acceptance();

-- FRIENSHIP SYMMETRY RULE --

CREATE RULE friendship_symmetry_rule AS
    ON INSERT TO Friendship
    WHERE NEW.idMember1 > NEW.idMember2
    DO INSTEAD 
        INSERT INTO Friendship (idMember1, idMember2, createDate) VALUES (NEW.idMember2, NEW.idMember1, NEW.createDate);
