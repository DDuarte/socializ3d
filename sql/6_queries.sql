SET search_path TO proto;

-------------
-- Helpers --
-------------

-------------------------
-- Search results page --
-------------------------

SELECT * FROM (
    SELECT id, 'group', ts_rank_cd(to_tsvector('english', name), lower(:searchTerm)) * 0.7 + ts_rank_cd(to_tsvector('english', about), lower(:searchTerm)) * 0.3 AS score
    FROM TGroup WHERE visibility = 'public'
    UNION ALL
    SELECT id, 'member', ts_rank_cd(to_tsvector('english', name), lower(:searchTerm)) * 0.7 + ts_rank_cd(to_tsvector('english', about), lower(:searchTerm)) * 0.3 AS score
    FROM Member
    UNION ALL
    SELECT Model.id, 'model', ts_rank_cd(to_tsvector('english', name), lower(:searchTerm)) * 0.7 + ts_rank_cd(to_tsvector('english', description), lower(:searchTerm)) * 0.3 AS score
    FROM get_all_visibile_models(:userId) JOIN Model ON get_all_visibile_models.id = Model.id
) AS q ORDER BY score DESC LIMIT :limit;

--------------------
-- Administration --
--------------------

-------------------
-- Notifications --
-------------------

-- Get Model Tags --
SELECT model_tags.name FROM model_tags WHERE model_tags.idModel = :modelId;

-- List groups where model is shared --
SELECT GroupModel.idGroup FROM GroupModel JOIN TGroup ON TGroup.id = GroupModel.idGroup WHERE GroupModel.idModel = :modelId AND TGroup.visibility = 'public';

-- Member profile --
SELECT name, about, birthDate, get_user_hash($1) AS hash FROM Member WHERE id = :userId;

SELECT name FROM user_tags WHERE user_tags.idMember = :userId;

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
-----------
-- Model --
-----------

-- Update model's description --
UPDATE Model SET description = :description WHERE id = :id;

-- Update model's visibility --
UPDATE Model SET visibility = :visibility WHERE id = :id;

-- Update vote --
UPDATE Vote SET upVote = :upVote WHERE Vote.idModel = :idModel AND Vote.idMember = :idMember;

-- Remove Tag from Model --
DELETE FROM model_tags WHERE model_tags.idModel = :idModel AND model_tags.name = :name;

-- Remove comment from Model --
UPDATE TComment SET TComment.deleted = true WHERE TComment.idModel = :idModel AND TComment.id = :idComment;

-- Remove Model --
DELETE FROM Model WHERE Model.id = :id;

------------
-- Member --
------------

-- Update member's about field --
UPDATE Member SET about = :about WHERE id = :id;

-- Remove Tag (interest) from Member --
DELETE FROM user_tags WHERE idMember = :idMember AND name = :tagName;

------------
-- TGroup --
------------

-- Update group's about field --
UPDATE TGroup SET about = :about WHERE id = :id;

-- Update group's cover image --
UPDATE TGroup SET coverImg = :img WHERE id = :id;

-- Update group's avatar image --
UPDATE TGroup SET avatarImg = :img WHERE id = :id;

-- Update group's visibility --
UPDATE TGroup SET visibility = :visibility WHERE id = :id;

--

-- Answer friendship invite --
UPDATE FriendshipInvite SET accepted = :accepted WHERE FriendshipInvite.id = :id;

-- Answer group application --
UPDATE GroupApplication SET accepted = :accepted WHERE GroupApplication.id = :id;

-- Answer group invite --
UPDATE GroupInvite SET accepted = :accepted WHERE GroupInvite.id = :id;
