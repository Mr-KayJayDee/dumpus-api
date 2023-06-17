-- SQLite (v3.34 or higher required)

SELECT COUNT(DISTINCT dm_user_id) as network_size
FROM dm_channels_data;

/* (network size)

|network_size|
|------------|
|2832        |

*/

SELECT SUM(a.occurence_count) as join_count
FROM activity a
WHERE a.event_name = 'guild_joined'
AND a.day BETWEEN '2021-06-01' AND '2021-06-10';

/* (guild join count)

|join_count|
|----------|
|606       |

*/

SELECT d.dm_user_id,
    d.user_name,
    d.user_avatar_url,
    SUM(a.occurence_count) AS message_count,
    d.channel_id
FROM activity a
JOIN dm_channels_data d ON a.associated_channel_id = d.channel_id
WHERE a.event_name = 'message_sent' 
AND a.day BETWEEN '2021-06-01' AND '2021-06-10'
GROUP BY d.dm_user_id
ORDER BY message_count DESC;

/* (dm channels top graph)

Result

|dm_user_id        |user_name                 |user_avatar_url                                                                           |message_count|channel_id        |
|------------------|--------------------------|------------------------------------------------------------------------------------------|-------------|------------------|
|364481003479105537|Eddroid#1589              |https://cdn.discordapp.com/avatars/364481003479105537/5317bc70474e5dca6de35260f3e6fdee.jpg|2308         |558695545531662337|
|236952680201715714|KaKi87#2368               |https://cdn.discordapp.com/avatars/236952680201715714/9f8f56730a097338968b19016b43e58c.jpg|867          |557458819463118861|
|480933736276426763|Deleted User a7674088#7292|NULL                                                                                      |420          |668038290347261953|
|689926296318509139|Mene#4179                 |https://cdn.discordapp.com/avatars/689926296318509139/ec87c758b8cc0910197cd74a0819af61.jpg|341          |752798142709366854|
|456500252048883714|Clem's#4013               |https://cdn.discordapp.com/avatars/456500252048883714/5046d6c3774832074f658f99e79c05b2.jpg|306          |557601710210809856|
|365942020923064340|Hunam#6067                |https://cdn.discordapp.com/avatars/365942020923064340/7bdf0094f6c645502b99cc92985fd463.jpg|303          |558310926411890689|

*/

SELECT guild_name,
    SUM(a.occurence_count) AS message_count
FROM guilds
JOIN activity a ON a.associated_guild_id = guilds.guild_id
WHERE a.event_name = 'message_sent'
AND a.day BETWEEN '2021-06-01' AND '2021-06-10'
GROUP BY guild_name
ORDER BY message_count DESC;

/* (guilds top graph)

Result

|guild_name           |message_count|
|---------------------|-------------|
|AndrozDev            |28           |
|ManageInvite's Lounge|9            |
|ManageInvite Staff   |4            |
|Visio                |1            |
|TechCord             |1            |

*/

SELECT channel_name,
    SUM(a.occurence_count) AS message_count    
FROM guild_channels_data channels
JOIN activity a ON a.associated_channel_id = channels.channel_id
WHERE a.event_name = 'message_sent'
AND a.day BETWEEN '2021-06-01' AND '2021-06-10'
GROUP BY channel_name
ORDER BY message_count DESC;

/*

Result (channels top graph)

|channel_name         |message_count|
|---------------------|-------------|
|chat                 |19           |
|general-chat         |4            |
|pronote-notifications|3            |
|💬》chat              |2            |
|👑》premium-chat      |2            |
|private-commands     |2            |
|chat-n-questions     |2            |
|🗞》news              |1            |
|testing-2            |1            |
|testing-1            |1            |
|premium-logs         |1            |
|offtopic             |1            |
|général              |1            |
|general-support      |1            |
|general              |1            |
|commands-staff       |1            |

*/

/*

NOTE 

Use

  SELECT MIN(day) AS start FROM activity
  UNION ALL
  SELECT date(day, '+1 day')
  FROM dates
  WHERE day < (SELECT MAX(day) FROM activity)

if you want to generate a list of dates between the first and last activity day

*/

WITH hours AS (
    SELECT value AS hour FROM generate_series(0,23)
)
SELECT 
    hours.hour,
    IFNULL(SUM(a.occurence_count), 0) AS message_count
FROM 
    hours
LEFT JOIN 
    activity a ON hours.hour = a.hour 
    AND a.event_name = 'message_sent' 
    AND a.day BETWEEN '2021-06-01' AND '2021-06-10'
GROUP BY 
    hours.hour
ORDER BY 
    hours.hour ASC;

/* (hours graph)

Result

|hour|message_count|
|----|-------------|
|0   |224          |
|1   |52           |
|2   |5            |
|3   |7            |
|4   |165          |
|5   |2049         |
|6   |3977         |
|7   |5929         |
|8   |7820         |
|9   |8698         |
|10  |7089         |
|11  |6211         |
|12  |8547         |
|13  |8386         |
|14  |9159         |
|15  |11080        |
|16  |13999        |
|17  |12942        |
|18  |10500        |
|19  |10993        |
|20  |8576         |
|21  |4287         |
|22  |2012         |
|23  |767          |

*/

SELECT hour,
    SUM(occurence_count) AS message_count
FROM 
    activity
WHERE event_name = 'message_sent' 
    AND day BETWEEN '2021-06-01' AND '2021-06-10'
GROUP BY hour
ORDER BY occurence_count DESC
LIMIT 1

/* (best hour)

Result

|hour|message_count|
|----|-------------|
|15  |30           |

*/

WITH RECURSIVE dates(day) AS (
  VALUES('2021-06-01')
  UNION ALL
  SELECT date(day, '+1 day')
  FROM dates
  WHERE date(day, '+1 day') <= '2021-06-10'
)
SELECT 
    dates.day,
    IFNULL(SUM(a.occurence_count),0) AS message_count
FROM 
    dates
LEFT JOIN 
    activity a ON dates.day = a.day 
    AND a.event_name = 'message_sent'
GROUP BY 
    dates.day
ORDER BY 
    dates.day ASC;

/* (days graph)

|day|message_count|
|---|-------------|
|2021-06-01|102          |
|2021-06-02|78           |
|2021-06-03|36           |
|2021-06-04|12           |
|2021-06-05|85           |
|2021-06-06|88           |
|2021-06-07|96           |
|2021-06-08|23           |
|2021-06-09|52           |
|2021-06-10|75           |

*/

SELECT SUM(payment_amount) / 100 as total_spent FROM payments

/*

Result (total spent)

|total_spent|
|-----------|
|8          |

*/
