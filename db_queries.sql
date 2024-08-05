-- How many nodes in each generation of the network?
SELECT generation, count(*)
FROM Entities
GROUP BY 1
ORDER BY 1;


-- QUERYING CHANNEL SIMILARITY
-- List all channels which are ever suggested as "similar", in order by highest number of suggestions
SELECT cs.suggested_entity_id, e.name, e.username, e.member_count, count(*)
FROM `ChannelSuggestions` cs
INNER JOIN Entities e ON cs.suggested_entity_id = e.entity_id
GROUP BY 1,2,3,4
ORDER BY 5 desc;


-- List all similar channels for a particular channel  
SELECT cs.suggested_entity_id, e.name, e.username, e.member_count
FROM `ChannelSuggestions` cs
INNER JOIN Entities e ON cs.suggested_entity_id = e.entity_id
WHERE cs.entity_id = 12345; -- put the channel here that you want to list all "similars" for

  
-- List all entities (left hand side) that were suggesting a particular channel (right hand side)
SELECT cs.entity_id, e.name, e.username, e.member_count
FROM `ChannelSuggestions` cs
INNER JOIN Entities e ON cs.entity_id = e.entity_id
WHERE cs.suggested_entity_id = 12345; -- put the channel here to see which other channels listed it as "similar"


-- CALCULATING DEGREES
-- Calculate node indegree and outdegrees
SELECT e.entity_id, 
       e.username, 
       e.member_count 
      (select count(*) FROM ChannelSuggestions csIn WHERE csIn.suggested_entity_id = e.entity_id) as 'indegree', 
      (select count(*) FROM ChannelSuggestions csOut WHERE csOut.entity_id = e.entity_id) as 'outdegree'
FROM Entities e;


-- Calculate the indegrees and outdegrees and update the table accordingly
UPDATE Entities e
JOIN (
    SELECT 
        e.entity_id,
        (SELECT COUNT(*) FROM ChannelSuggestions csIn WHERE csIn.suggested_entity_id = e.entity_id) AS indegree,
        (SELECT COUNT(*) FROM ChannelSuggestions csOut WHERE csOut.entity_id = e.entity_id) AS outdegree
    FROM Entities e
) AS calculations ON e.entity_id = calculations.entity_id
SET 
    e.indegree = calculations.indegree,
    e.outdegree = calculations.outdegree;

-- Calculate the total degree
UPDATE `Entities`  
SET degree = indegree + outdegree;


-- PRUNING EXPERIMENTS
-- Generation 1: include only nodes with outdegree > 0
SELECT e.entity_id as 'id', left(e.name, 15) as 'name', e.username as 'username', e.member_count as 'size', e.generation as 'gen'
FROM Entities e
WHERE e.generation = 1
AND e.outdegree > 0;

-- Generation 2: include only nodes with outdegree > 0
SELECT e.entity_id as 'id', left(e.name, 15) as 'name', e.username as 'username', e.member_count as 'size', e.generation as 'gen'
FROM Entities e
WHERE e.generation = 2
AND e.outdegree > 0;

-- Generation 3: include only nodes with indegree > 2
SELECT e.entity_id as 'id', left(e.name, 15) as 'name', e.username as 'username', e.member_count as 'size', e.generation as 'gen'
FROM Entities e 
WHERE e.generation = 3
AND e.indegree > 2; -- adjust this number as you wish



-- GENERATING NODES AND EDGES LISTS
-- generate nodes list
SELECT e.entity_id as 'id', left(e.name, 15) as 'name', e.username as 'username', e.member_count as 'size', e.generation as 'gen'
FROM Entities e;

-- generate nodes list with some pruning (exclude nodes with 0 degree (banned, etc))
SELECT e.entity_id as 'id', left(e.name, 15) as 'name', e.username as 'username', e.member_count as 'size', e.generation as 'gen'
FROM Entities e 
WHERE e.degree > 0; # fiddle with the different degree values to produce different pruned lists

-- generate edges list
select c.entity_id as 'source', c.suggested_entity_id as 'target', '1' as 'weight', 'directed' as 'type'
from ChannelSuggestions c;

