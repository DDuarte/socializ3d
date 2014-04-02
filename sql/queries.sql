-------------------------
-- Search results page --
-------------------------

-- Groups --
SELECT name, about, avatarImg, createDate FROM TGroup WHERE visibility = 'public' AND TGroup.name = :modelName;
-- Users --
SELECT name, about, avatarImg, registerDate FROM Member WHERE Member.name = :memberName;
-- Models --
SELECT name, description, FROM Model WHERE Model.name = :name AND visibility = 'public';

---

------------------
-- Gallery page --
------------------
	
-- Thumbnail information for each model --
SELECT DISTINCT Model.name as model, Member.name as author, count(CASE WHEN upVote = 'true' THEN 1 ELSE null END) as upVotes, count(CASE WHEN upVote = 'false' THEN 0 ELSE null END) as downVotes, 
	count(TComment.id) as comments 
	FROM Model JOIN Vote ON Model.id = Vote.idModel 
	JOIN Member ON Member.id = Model.idAuthor 
	JOIN TComment ON TComment.idModel = Model.id
	WHERE Model.id = :id
	GROUP BY Model.name, Member.name, TComment.id;
	
-- List all the members of a group --
SELECT Member.id, Member.name FROM GroupUser 
	JOIN TGroup ON GroupUser.idGroup = :groupId
	JOIN Member ON Member.id = GroupUser.idMember
	ORDER BY Member.name ASC;
	
-- List all the administrators of a group --
SELECT Member.id, Member.name FROM GroupUser 
	JOIN TGroup ON GroupUser.idGroup = :groupId
	JOIN Member ON (Member.id = GroupUser.idMember AND Member.isAdmin = 'true')
	ORDER BY Member.name ASC;
	
-- List all the friends of a user --
SELECT Member.id, Member.name FROM (SELECT FriendShip.idMember1 AS idFriend FROM Friendship WHERE Friendship.idMember2 = :id 
	UNION
	SELECT FriendShip.idMember2 AS idFriend FROM Friendship WHERE Friendship.idMember1 = :id) 
	JOIN Member ON Member.id = idFriend;
	
-- List all the groups of a user --
SELECT TGroup.id, TGroup.name FROM TGroup JOIN GroupUser ON GroupUser.idGroup = TGroup.id AND GroupUser.idMember = :id;

-- List all the models of a group --
SELECT DISTINCT Model.name as model, Member.name as author, count(CASE WHEN upVote = 'true' THEN 1 ELSE null END) as upVotes, count(CASE WHEN upVote = 'false' THEN 0 ELSE null END) as downVotes, 
	count(TComment.id) as comments 
	FROM Model
	JOIN GroupModel ON (GroupModel.idGroup = :id AND GroupModel.idModel = Model.id)
	JOIN Vote ON Model.id = Vote.idModel 
	JOIN Member ON Member.id = Model.idAuthor 
	JOIN TComment ON TComment.idModel = Model.id
	GROUP BY Model.name, Member.name, TComment.id;
-- 