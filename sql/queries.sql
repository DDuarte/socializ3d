-------------------------
-- Search results page --
-------------------------

-- Groups --
SELECT name, about, avatarImg, createDate FROM TGroup WHERE visibility = 'public' AND TGroup.name = :modelName;
-- Users --
SELECT name, about, avatarImg, registerDate FROM Member WHERE Member.name = :memberName;
-- Models --
SELECT name, description, FROM Model WHERE Model.name = :name AND visibility = 'public';
