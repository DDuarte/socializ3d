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

-------------------------
-- Gallery page --
-------------------------
	
-- Thumbnail information for each model --
SELECT DISTINCT Model.name as model, Member.name as author, count(CASE WHEN upVote = 'true' THEN 1 ELSE null END) as upVotes, count(CASE WHEN upVote = 'false' THEN 0 ELSE null END) as downVotes, 
	count(TComment.id) as comments 
	FROM Model JOIN Vote ON Model.id = Vote.idModel 
	JOIN Member ON Member.id = Model.idAuthor 
	JOIN TComment ON TComment.idModel = Model.id
	WHERE Model.id = :id
	GROUP BY Model.name, Member.name, TComment.id;

