select *
from athlete_events;
-- The number of Olympic Games group by season
select season, count(distinct(Year)) as Total_olympic_game 
from  athlete_events
group by Season;
-- List of  Olympics games held so far
select Year, season, city 
from athlete_events
order by year asc; 
-- The total number of nations who participated in each olympics game 
  select Games, count(distinct(NOC)) as Total_countries
  from athlete_events
  group by Games;
  -- the highest and lowest no of countries participating in olympics
  with CountryParticipation as (
  select
	Games,
    count(distinct(NOC)) as total_countries
    from athlete_events
    group by Games), 
MaxMinParticipation AS (
    SELECT
        MAX(total_countries) AS max_countries,
        MIN(total_countries) AS min_countries
    FROM
        CountryParticipation
)
select cp.games, cp.total_countries
from CountryParticipation cp
join MaxMinParticipation mmp on cp.total_countries = mmp.max_countries 

union all 

select cp.games, cp.total_countries
from CountryParticipation cp
join MaxMinParticipation mmp on cp.total_countries = mmp.min_countries; 
  
-- Which nation has participated in all of the olympic games
with TotalGames as(
	select count(distinct(games)) as total_games
    from athlete_events),
    NationParticipation as (
    select team, count(distinct(games)) as games_participated 
    from athlete_events
    group by team)
    select np.team, np.games_participated 
    from NationParticipation np 
    join TotalGames tg
    on np.games_participated = tg.total_games;
-- The sports were played in all summer olympics.
 with t1 as
          	(select count(distinct games) as total_games
          	from athlete_events where season = 'Summer'),
          t2 as
          	(select distinct games, sport
          	from athlete_events where season = 'Summer'),
          t3 as
          	(select sport, count(1) as no_of_games
          	from t2
          	group by sport)
      select *
      from t3
      join t1 on t1.total_games = t3.no_of_games;
--    The sports were just played only once in the olympics. 
SELECT
    sport, count(distinct(Games)) as no_of_games
FROM
    athlete_events
GROUP BY
    sport
HAVING
    COUNT(DISTINCT games) = 1;
-- The total of number of sport played in each olympic games.
 with t1 as
      	(select distinct games, sport
      	from athlete_events),
        t2 as
      	(select games, count(1) as no_of_sports
      	from t1
      	group by games)
      select * from t2
      order by no_of_sports desc;
-- The oldest athletes to win a gold medal
select *
from athlete_events
WHERE
    Medal = 'Gold'
    AND age = (
        SELECT
            MAX(age)
        FROM
            athlete_events
        WHERE
            medal = 'Gold'
    );
-- Top 5 athletes who have won the most gold medals.
with t1 as 
	(select team, Medal, Name
    from athlete_events
    where Medal = 'Gold'), 
    t2 as
      	(select row_number() over (order by count(Medal) desc) as rnk,
        name,team, count(Medal) as Total_gold_medals
      	from t1
      group by name,team)
      select * from t2
      where rnk <=5
      order by Total_gold_medals desc
      ;
-- The top 5 athletes who have won the most medals (gold/silver/bronze).
with t1 as 
	(select team, Medal, Name
    from athlete_events
     where medal in ('Gold', 'Silver', 'Bronze')),
    t2 as
      	(select row_number() over (order by count(Medal) desc) as rnk,
        name,team, count(Medal) as Total_medals
      	from t1
      group by name,team)
      select * from t2
      where rnk <=5
      order by Total_medals desc
      ;
-- which country won the most gold, most silver and most bronze medals in each olympic games.
with t1 as (
select
	games, team,
    count(Case when Medal = 'Gold' then 1 end) as Gold_count,
    count(Case when Medal = 'Silver' then 1 end) as Silver_count,
    count(Case when Medal = 'bronze' then 1 end) as Bronze_count,
    ROw_Number() over (partition by games order by count(Case when Medal = 'Gold' THEN 1 END) DESC) AS Gold_Rank,
	ROw_Number() over (partition by games order by count(Case when Medal = 'Silver' THEN 1 END) DESC) AS Silver_Rank,
    ROw_Number() over (partition by games order by count(Case when Medal = 'Bronze' THEN 1 END) DESC) AS Bronze_Rank
    from 
    athlete_events
    where medal in ('Gold', 'Silver', 'Bronze')
    group by games, team)
    
    SELECT
    games,
    MAX(CASE WHEN Gold_Rank = 1 THEN team END) AS Country_with_most_gold,
    MAX(CASE WHEN Silver_Rank = 1 THEN team END) AS Country_with_most_silver,
    MAX(CASE WHEN Bronze_Rank = 1 THEN team END) AS Country_with_most_bronze
FROM
    t1
GROUP BY
    games
ORDER BY
    games;
-- Identify which sport United States has worn highest medals, and where USA won and how many medals in each olympic games
select sport, count(*) as total_medales
from athlete_events
where medal in ('Gold','Silver','Brone')
	and team = 'United States'
group by sport 
order by total_medales desc
limit 1;
select sport, games, count(*) as Total_Medals
from athlete_events
where medal in ('Gold','Silver','Brone')
	and team = 'United States'
    and sport = 'Swimming'
group by games
order by games;




