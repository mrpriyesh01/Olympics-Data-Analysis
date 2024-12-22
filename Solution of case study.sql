#1. How many olympics games have been held?
#@ Write a SQL query to find the total no of OlympicGames held as per the dataset.

select count(distinct games) as total_OlympicGames
from olympics;

#2. List down all Olympics games held so far.
#@Write a SQL query to list down all the Olympic Games held so far.

select distinct year,season,city
    from olympics
    order by year;

#3.Mention the total no of nations who participated in each olympics game?
#question SQL query to fetch total no of countries participated in each olympic games.

SELECT o.games, COUNT(DISTINCT n.region) AS total_countries
FROM olympics o
JOIN olympics_noc n
  ON o.noc = n.noc
GROUP BY o.games;
#another way to sloved this problem

with cte as (
select o.games,n.region from olympics o
join olympics_noc n
on o.noc=n.noc)
select games,count(distinct region) as total_country
from   cte
group by games


#4 Which year saw the highest and lowest no of countries participating in olympics
#question return the Olympic Games which had the highest participating countries and the lowest participating countries.
WITH all_countries AS (
    SELECT games, nr.region
    FROM olympics oh
    JOIN olympics_noc nr ON nr.noc = oh.noc
    GROUP BY games, nr.region
),

tot_countries AS (
    SELECT games, COUNT(DISTINCT region) AS total_countries
    FROM all_countries
    GROUP BY games
)
SELECT 
    -- Lowest participation
    CONCAT(
        (SELECT games FROM tot_countries ORDER BY total_countries ASC LIMIT 1), 
        ' - ', 
        (SELECT total_countries FROM tot_countries ORDER BY total_countries ASC LIMIT 1)
    ) AS Lowest_Countries,
    
    -- Highest participation
    CONCAT(
        (SELECT games FROM tot_countries ORDER BY total_countries DESC LIMIT 1), 
        ' - ', 
        (SELECT total_countries FROM tot_countries ORDER BY total_countries DESC LIMIT 1)
    ) AS Highest_Countries;

#Which nation has participated in all of the olympic games?
#SQL query to return the list of countries who have been part of every Olympics games.


SELECT cg.country
FROM (
    -- Step 1: Count the number of games participated by each country
    SELECT 
        n.region AS country,
        COUNT(DISTINCT o.games) AS games_participated
    FROM olympics o
    JOIN olympics_noc n ON o.noc = n.noc
    GROUP BY n.region
) AS cg
JOIN (
    -- Step 2: Calculate the total number of unique Olympic Games
    SELECT COUNT(DISTINCT games) AS total_games
    FROM olympics
) AS tg
ON cg.games_participated = tg.total_games;


#Identify the sport which was played in all summer olympics.
#SQL query to fetch the list of all sports which have been part of only  summer olympics.

SELECT 
    sport AS sports,
    COUNT(DISTINCT games) AS no_of_games,
    (SELECT COUNT(DISTINCT games) FROM olympics where season='Summer') as total_games 
FROM olympics
where season='Summer'
GROUP BY sport
having  count(distinct games)= (SELECT COUNT(DISTINCT games) FROM olympics WHERE season = 'Summer');


with t1 as
          	(select count(distinct games) as total_games
          	from olympics where season = 'Summer'),
          t2 as
          	(select distinct games, sport
          	from olympics where season = 'Summer'),
          t3 as
          	(select sport, count(1) as no_of_games
          	from t2
          	group by sport)
      select *
      from t3
      join t1 on t1.total_games = t3.no_of_games;



#Which Sports were just played only once in the olympics.
#Identify the sport which were just played once in all of olympics.
SELECT 
    t2.sport, 
    t2.no_of_games, 
    t1.games
FROM 
    (SELECT DISTINCT games, sport FROM olympics) t1
JOIN 
    (SELECT sport, COUNT(Games) AS no_of_games 
     FROM (SELECT DISTINCT Games, sport FROM olympics) t1_sub
     GROUP BY sport) t2
ON 
    t1.sport = t2.sport
WHERE 
    t2.no_of_games = 1
ORDER BY 
    t1.sport;


#8.Fetch the total no of sports played in each olympic games.
#fetch the total no of sports played in each olympics.

WITH each_oly AS (
    SELECT 
        Games, 
        COUNT(DISTINCT Sport) AS no_of_sports  -- Count distinct sports, not games
    FROM olympics
    GROUP BY Games
    ORDER BY no_of_sports desc
)
SELECT Games, no_of_sports
FROM each_oly;

#9.Fetch oldest athletes to win a gold medal
#fetch the details of the oldest athletes to win a gold medal at the olympics.
with temp as
            (select name,sex,cast(case when age = 'NA' then '0' else age end as int) as age
              ,team,games,city,sport, event, medal
            from olympics),
        ranking as
            (select *, rank() over(order by age desc) as rnk
            from temp
            where medal='Gold')
    select *
    from ranking
    where rnk = 1;

10. Find the Ratio of male and female athletes participated in all olympic games.
@ Write a SQL query to get the ratio of male and female participants

select * from olympics
WITH t1 AS (
    SELECT COUNT(*) AS female
    FROM olympics
    WHERE sex = 'F'
),
t2 AS (
    SELECT COUNT(*) AS male
    FROM olympics
    WHERE sex = 'M'
)
SELECT 
    t2.male / t1.female AS male_to_female_ratio
FROM t1 
CROSS JOIN t2;


10. Find the Ratio of male and female athletes participated in all olympic games.
Write a SQL query to get the ratio of male and female participants

WITH t1 AS (
    SELECT COUNT(sex) AS male
    FROM olympics
    WHERE sex = 'M'
), 
t2 AS (
    SELECT COUNT(sex) AS female
    FROM olympics
    WHERE sex = 'F'
)
SELECT t1.male / t2.female AS ratio_of_sex
FROM t1
CROSS JOIN t2;

11. Fetch the top 5 athletes who have won the most gold medals.
SQL query to fetch the top 5 athletes who have won the most gold medals.
select * from olympics
 

with t1 as
            (select name, team, count(1) as total_gold_medals
            from olympics
            where medal = 'Gold'
            group by name, team
            order by total_gold_medals desc),
        t2 as
            (select *, dense_rank() over (order by total_gold_medals desc) as rnk
            from t1)
    select name, team, total_gold_medals
    from t2
    where rnk <= 5;



12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
fetch the top 5 athletes who have won the most medals (Medals include gold, silver and bronze).

WITH t1 AS (
    SELECT name, team, COUNT(medal) AS total_medal
    FROM olympics
    WHERE medal IS NOT NULL
    GROUP BY name, team
),
t2 AS (
    SELECT *, 
           DENSE_RANK() OVER (ORDER BY total_medal DESC) AS rnk
    FROM t1
)
SELECT name,team,total_medal
FROM t2
WHERE rnk <= 5;

13.List down total gold, silver and broze medals won by each country.
SELECT nr.region AS country,
       COUNT(CASE WHEN oh.medal = 'Gold' THEN 1 END) AS gold,
       COUNT(CASE WHEN oh.medal = 'Silver' THEN 1 END) AS silver,
       COUNT(CASE WHEN oh.medal = 'Bronze' THEN 1 END) AS bronze
FROM olympics oh
JOIN olympics_noc nr 
    ON nr.noc = oh.noc
WHERE oh.medal != 'NA'
GROUP BY nr.region
ORDER BY gold DESC, silver DESC, bronze DESC;


14.List down total gold, silver and broze medals won by each country 
corresponding to each olympic games.

SELECT o.games, nr.region AS country, 
       COUNT(CASE WHEN o.medal = 'Gold' THEN 1 END) AS gold_medals,
       COUNT(CASE WHEN o.medal = 'Silver' THEN 1 END) AS silver_medals,
       COUNT(CASE WHEN o.medal = 'Bronze' THEN 1 END) AS bronze_medals
FROM olympics o
JOIN olympics_noc nr
    ON o.noc = nr.noc
WHERE o.medal != 'NA'
GROUP BY o.games, nr.region
ORDER BY o.games ,gold_medals DESC, silver_medals DESC, bronze_medals DESC;


 15.Identify which country won the most gold, most silver and most bronze medals in each olympic games.
 

WITH medal_counts AS (
    SELECT 
         o.games, 
        nr.region AS country,
        COUNT(CASE WHEN o.medal = 'Gold' THEN 1 ELSE NULL END) AS gold_medals,
        COUNT(CASE WHEN o.medal = 'Silver' THEN 1 ELSE NULL END) AS silver_medals,
        COUNT(CASE WHEN o.medal = 'Bronze' THEN 1 ELSE NULL END) AS bronze_medals
    FROM olympics o
    JOIN olympics_noc nr ON o.noc = nr.noc
    WHERE o.medal != 'NA'
    GROUP BY o.games, nr.region
)
SELECT 
     distinct games,
    CONCAT(
        first_value(country) OVER (PARTITION BY games ORDER BY gold_medals DESC),
        ' - ', first_value(gold_medals) OVER (PARTITION BY games ORDER BY gold_medals DESC)
    ) AS Max_Gold,
    CONCAT(
        first_value(country) OVER (PARTITION BY games ORDER BY silver_medals DESC),
        ' - ', first_value(silver_medals) OVER (PARTITION BY games ORDER BY silver_medals DESC)
    ) AS Max_Silver,
    CONCAT(
        first_value(country) OVER (PARTITION BY games ORDER BY bronze_medals DESC),
        ' - ', first_value(bronze_medals) OVER (PARTITION BY games ORDER BY bronze_medals DESC)
    ) AS Max_Bronze
FROM medal_counts
ORDER BY   games;


16 Write a SQL Query to fetch details of countries which have won silver or bronze medal
but never won a gold medal.

select  nr.region AS country,
COUNT(CASE WHEN o.medal = 'Gold' THEN 1 ELSE NULL END) AS gold_medals,
        COUNT(CASE WHEN o.medal = 'Silver' THEN 1 ELSE NULL END) AS silver_medals,
        COUNT(CASE WHEN o.medal = 'Bronze' THEN 1 ELSE NULL END) AS bronze_meda
		 FROM olympics o
    JOIN olympics_noc nr ON o.noc = nr.noc
	group by nr.region
	HAVING COUNT(CASE WHEN o.medal = 'Gold' THEN 1 ELSE NULL END) = 0 -- Never won gold
   AND (COUNT(CASE WHEN o.medal = 'Silver' THEN 1 ELSE NULL END) > 0 
        OR COUNT(CASE WHEN o.medal = 'Bronze' THEN 1 ELSE NULL END) > 0); 

17.In which Sport/event, India has won highest medals.

Problem Statement: Write SQL Query to return the sport which has won India the highest no of medals.


