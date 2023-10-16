/*
1) Написать функцию, возвращающую таблицу TransferredPoints в более человекочитаемом виде
Ник пира 1, ник пира 2, количество переданных пир поинтов.
Количество отрицательное, если пир 2 получил от пира 1 больше поинтов.

Пример вывода:

Peer1	Peer2	PointsAmount
Aboba	Amogus	5
Amogus	Sus	-2
Sus	Aboba	0
*/

CREATE OR REPLACE FUNCTION fnc_transferred_points_human_readable() RETURNS TABLE (Peer1 VARCHAR, Peer2 VARCHAR, PointsAmount INTEGER) AS $$
	WITH sum_of_prp AS(SELECT
    CheckingPeer AS Peer1,
    CheckedPeer AS Peer2,
    SUM(PointsAmount) AS PointsAmount
     FROM TransferredPoints
	 GROUP BY Peer1, Peer2)

	 SELECT sop1.Peer1, sop1.Peer2,
	 COALESCE(sop1.PointsAmount, 0) - COALESCE(sop2.PointsAmount, 0) AS PointsAmount
	 FROM sum_of_prp sop1
	 FULL JOIN sum_of_prp sop2 ON sop1.Peer1 = sop2.Peer2 AND sop1.Peer2 = sop2.Peer1
	 WHERE sop1.Peer1 IS NOT NULL AND sop1.Peer2 IS NOT NULL
$$ LANGUAGE sql;
/*для проверки использовать:*/
-- SELECT * FROM fnc_transferred_points_human_readable() ORDER by 1,2;

---------------------------------------------------------------------------------------
/*
2) Написать функцию, которая возвращает таблицу вида: ник пользователя, 
название проверенного задания, 
кол-во полученного XP
В таблицу включать только задания, успешно прошедшие проверку 
(определять по таблице Checks).
Одна задача может быть успешно выполнена несколько раз. 
В таком случае в таблицу включать все успешные проверки.

Пример вывода:

Peer	Task	XP
Aboba	C8	800
Aboba	CPP3	750
Amogus	DO5	175
Sus	A4	325
*/

CREATE OR REPLACE FUNCTION fnc_peer_task_xp() RETURNS TABLE (Peer VARCHAR, Task VARCHAR, XP INTEGER) AS $$
    SELECT ch.Peer AS Peer,
        ch.Task AS Task,
        XP.XPAmount AS XP
    FROM XP
    JOIN Checks ch ON XP."Check" = ch.id
$$ LANGUAGE SQL;

-- SELECT *
-- FROM fnc_peer_task_xp()
--------------------------------------------------------------------------------------
/*
3) Написать функцию, определяющую пиров, 
которые не выходили из кампуса в течение всего дня
Параметры функции: день, например 12.05.2022.
Функция возвращает только список пиров.
*/
CREATE OR REPLACE FUNCTION fnc_full_day(target_date Date) RETURNS TABLE (Peer VARCHAR) AS $$
	With exits AS (    
		SELECT Peer
		FROM TimeTracking
		WHERE state = 2 AND date = target_date)
		
	SELECT Peer
	FROM (
			(SELECT Nickname AS Peer
			 FROM Peers)
		  EXCEPT
			(SELECT Peer
			 FROM exits)) AS list
	GROUP BY peer
$$ LANGUAGE SQL;

-- SELECT *
-- FROM fnc_full_day('2023-08-02');
---------------------------------------------------------------------------------------

/*
4) Посчитать изменение в количестве пир поинтов каждого пира по таблице TransferredPoints
Результат вывести отсортированным по изменению числа поинтов.
Формат вывода: ник пира, изменение в количество пир поинтов

Пример вывода:

Peer	PointsChange
Aboba	8
Amogus	1
Sus	-3
*/

CREATE OR REPLACE PROCEDURE proc_count_points(IN c refcursor)
LANGUAGE plpgsql AS $$
    BEGIN
        OPEN c FOR
	WITH earnings AS
	  (SELECT CheckingPeer,
			  SUM(PointsAmount) AS earned
	   FROM TransferredPoints
	   GROUP BY CheckingPeer),
		 loses AS
	  (SELECT CheckedPeer,
			  SUM(PointsAmount) AS lost
	   FROM TransferredPoints
	   GROUP BY CheckedPeer)
	
	SELECT Nickname AS Peer,
		   earned - lost AS PointsChange
	FROM Peers
	JOIN earnings ON CheckingPeer = Nickname
	JOIN loses ON CheckedPeer = Nickname
	ORDER BY PointsChange DESC;

    END;
$$;

-- CALL proc_count_points('my_cursor');
-- FETCH ALL FROM my_cursor;

------------------------------------------------------------------------------------------------
/*
5) Посчитать изменение в количестве пир поинтов каждого пира по таблице, 
возвращаемой первой функцией из Part 3
Результат вывести отсортированным по изменению числа поинтов.
Формат вывода: ник пира, изменение в количество пир поинтов

Пример вывода:

Peer	PointsChange
Aboba	8
Amogus	1
Sus	-3
*/

CREATE OR REPLACE PROCEDURE proc_count_prp_balance_from_ex01(IN c refcursor) AS $$
BEGIN
OPEN c FOR
	WITH earnings AS
	  (SELECT Peer1 AS CheckingPeer,
			  SUM(PointsAmount) AS earned
	   FROM fnc_transferred_points_human_readable()
	   GROUP BY Peer1),
		 loses AS
	  (SELECT Peer2 AS CheckedPeer,
			  SUM(PointsAmount) AS lost
	   FROM fnc_transferred_points_human_readable()
	   GROUP BY CheckedPeer)
	
	SELECT Nickname AS Peer,
		   earned - lost AS PointsChange
	FROM Peers
	JOIN earnings ON CheckingPeer = Nickname
	JOIN loses ON CheckedPeer = Nickname
	ORDER BY PointsChange DESC;
END;
$$ LANGUAGE plpgsql;

-- CALL proc_count_prp_balance_from_ex01('my_cursor');
-- FETCH ALL FROM my_cursor;
------------------------------------------------------------------------------------------------
/*
6) Определить самое часто проверяемое задание за каждый день
При одинаковом количестве проверок каких-то заданий в определенный день, вывести их все.
Формат вывода: день, название задания

Пример вывода:

Day	Task
12.05.2022	A1
17.04.2022	CPP3
23.12.2021	C5
*/

CREATE OR REPLACE PROCEDURE proc_get_most_checked_task_for_every_day(IN c refcursor) AS $$
BEGIN
OPEN c FOR
	WITH counts AS (
		  SELECT DISTINCT date, SUBSTRING(task
		  FROM '^(.*?)_') AS task,
		  COUNT(*) AS num
		  FROM Checks
		  GROUP BY date, task),
	
	maxis AS (SELECT c1.date, c1.task FROM counts c1 WHERE c1.num = (SELECT MAX(c2.num) FROM counts c2 WHERE c2.date = c1.date))
	SELECT date, task FROM maxis  ORDER BY date;
END;
$$ LANGUAGE plpgsql;

-- CALL proc_get_most_checked_task_for_every_day('my_cursor');
-- FETCH ALL FROM my_cursor;
/*"2023-08-22"	"C4"*/
------------------------------------------------------------------------------------------------
/*
8) Определить, к какому пиру стоит идти на проверку каждому обучающемуся
Определять нужно исходя из рекомендаций друзей пира, т.е. нужно найти пира, 
проверяться у которого рекомендует наибольшее число друзей.
Формат вывода: ник пира, ник найденного проверяющего

Пример вывода:

Peer	RecommendedPeer
Aboba	Sus
Amogus	Aboba
Sus	Aboba
*/

CREATE OR REPLACE PROCEDURE proc_get_recomended_reviewers(IN c refcursor) AS $$
BEGIN
OPEN c FOR
	WITH recomendations_for_peer1 AS (
		SELECT  
			Peer1 AS Peer,
			RecommendedPeer
		FROM Friends 
		JOIN Recommendations ON Peer = Peer2 AND RecommendedPeer != peer1
		),
		recomendations_for_peer2 AS (
		SELECT  
			Peer2 AS Peer,
			RecommendedPeer
		FROM Friends 
		JOIN Recommendations ON Peer = Peer1 AND RecommendedPeer != peer2
		),
		count_recommendations AS (
			SELECT 
			Peer,
			RecommendedPeer,
			COUNT(*) AS counter
			FROM ((SELECT * FROM recomendations_for_peer1) 
				UNION ALL
				(SELECT * FROM recomendations_for_peer2)) AS list
				GROUP BY Peer, RecommendedPeer
			ORDER BY 1),
	get_max_recommendations AS (SELECT cr1.Peer, cr1.RecommendedPeer, MAX(counter)
							   FROM count_recommendations cr1
								WHERE counter = (SELECT MAX(counter) FROM count_recommendations cr2 WHERE cr2.Peer = cr1.Peer )
							   GROUP BY Peer, RecommendedPeer)
	SELECT Peer, RecommendedPeer FROM get_max_recommendations;
END;
$$ LANGUAGE plpgsql;

-- CALL proc_get_recomended_reviewers('my_cursor');
-- FETCH ALL FROM my_cursor;
------------------------------------------------------------------------------------------------
/*
9) Определить процент пиров, которые:
Приступили только к блоку 1
Приступили только к блоку 2
Приступили к обоим
Не приступили ни к одному
Пир считается приступившим к блоку, 
если он проходил хоть одну проверку любого задания из этого блока (по таблице Checks)

Параметры процедуры: название блока 1, например SQL, название блока 2, например A.
Формат вывода: процент приступивших только к первому блоку, процент приступивших 
только ко второму блоку, процент приступивших к обоим, процент не приступивших ни к одному

Пример вывода:

StartedBlock1	StartedBlock2	StartedBothBlocks	DidntStartAnyBlock
20	20	5	55
*/

CREATE OR REPLACE PROCEDURE proc_get_partition_of_blocks_in_progress(IN c refcursor) AS $$
BEGIN
OPEN c FOR
	WITH get_all_blocks_in_checks AS (SELECT peer, SUBSTRING(task, '^(\D+)\d') AS task_block 
									  FROM Checks
									 GROUP BY peer, task_block),
		 count_blocks AS (SELECT peer, COUNT(peer) AS counter FROM get_all_blocks_in_checks GROUP BY peer),
		 
		 get_StartedBlock1 AS (SELECT DISTINCT count_blocks.peer AS StartedBlock1
							FROM count_blocks 
							JOIN get_all_blocks_in_checks ON count_blocks.peer = get_all_blocks_in_checks.peer
							WHERE counter = 1 AND task_block = 'C'),
		 get_StartedBlock2 AS (SELECT DISTINCT count_blocks.peer AS StartedBlock2
							FROM count_blocks 
							JOIN get_all_blocks_in_checks ON count_blocks.peer = get_all_blocks_in_checks.peer
							WHERE counter = 1 AND task_block = 'DO'),
		 get_StartedBothBlocks AS (SELECT DISTINCT count_blocks.peer AS StartedBothBlocks
							FROM count_blocks 
							JOIN get_all_blocks_in_checks ON count_blocks.peer = get_all_blocks_in_checks.peer
							WHERE counter = 2 ),
		 get_DidntStartAnyBlock AS (SELECT DISTINCT Peer AS DidntStartAnyBlock FROM ((SELECT Nickname AS Peer FROM Peers) 
																					 EXCEPT (SELECT Peer FROM count_blocks )) AS list),
									 
		count_peers AS (SELECT
			COUNT(StartedBlock1) AS num
		FROM get_StartedBlock1
		UNION ALL
		SELECT
			COUNT(StartedBlock2) AS num
		FROM get_StartedBlock2
		UNION ALL
		SELECT
			COUNT(StartedBothBlocks) AS num
		FROM get_StartedBothBlocks
		UNION ALL
		SELECT
			COUNT(DidntStartAnyBlock) AS num
		FROM get_DidntStartAnyBlock
		UNION ALL
		SELECT
			COUNT(*) AS num
		FROM Peers)
	
	SELECT
		ROUND(MAX(CASE WHEN row_number = 1 THEN num END)*100.0/MAX(CASE WHEN row_number = 5 THEN num END) ) AS "StartedBlock1",
		ROUND(MAX(CASE WHEN row_number = 2 THEN num END)*100.0/MAX(CASE WHEN row_number = 5 THEN num END) ) AS "StartedBlock2",
		ROUND(MAX(CASE WHEN row_number = 3 THEN num END)*100.0/MAX(CASE WHEN row_number = 5 THEN num END) ) AS "StartedBothBlocks",
		ROUND(MAX(CASE WHEN row_number = 4 THEN num END)*100.0/MAX(CASE WHEN row_number = 5 THEN num END) ) AS "DidntStartAnyBlock"
	FROM
		(
			SELECT num, ROW_NUMBER() OVER () AS row_number
			FROM count_peers
		) AS subquery;
END;
$$ LANGUAGE plpgsql;

-- CALL proc_get_partition_of_blocks_in_progress('my_cursor');
-- FETCH ALL FROM my_cursor;
/*
7	0	1	2
*/
------------------------------------------------------------------------------------------------
/*
10) Определить процент пиров, которые 
когда-либо успешно проходили проверку в свой день рождения
Также определите процент пиров, которые 
хоть раз проваливали проверку в свой день рождения.
Формат вывода: процент пиров, успешно прошедших проверку в 
день рождения, процент пиров, проваливших проверку в день рождения

Пример вывода:

SuccessfulChecks	UnsuccessfulChecks
60	40
*/
-- INSERT INTO Checks (id, peer, task, date)
-- VALUES 
-- (31, 'fiirkont', 'C3_s21_string+', '2022-04-22');

-- INSERT INTO P2P (id, "Check", CheckingPeer, State, Time)
-- VALUES (61, 31, 'fiirkont', 'Start', '16:00:00'),
--        (62, 31, 'fiirkont', 'Failure', '17:00:00');

CREATE OR REPLACE PROCEDURE proc_get_birthday_check_status(IN c refcursor) AS $$
BEGIN
OPEN c FOR
	WITH total_bd_checks AS (SELECT COUNT(*) AS num,
			   state
		FROM Peers
		JOIN Checks ON extract(
		DAY FROM date) = EXTRACT(DAY FROM Birthday)
		JOIN P2P ON "Check" = Checks.id
		AND state != 'Start'
		AND EXTRACT(MONTH
					FROM date) = EXTRACT(MONTH
										 FROM Birthday)
		GROUP BY state)
	
	SELECT ROUND(MAX(CASE
				   WHEN state = 'Success' THEN num
			   END)* 100.0/ COUNT(num)) AS SuccessfulChecks,
		   ROUND(MAX(CASE
				   WHEN state = 'Failure' THEN num
			   END)*100.0/ COUNT(num)) AS UnsuccessfulChecks
	FROM total_bd_checks;
	
	
END; 
$$ LANGUAGE plpgsql;

-- CALL proc_get_birthday_check_status('my_cursor');
-- FETCH ALL FROM my_cursor;
/*
50	50
*/
------------------------------------------------------------------------------------------------
/*
11) Определить всех пиров, которые сдали заданные задания 1 и 2, но не сдали задание 3
Параметры процедуры: названия заданий 1, 2 и 3.
Формат вывода: список пиров

*/

CREATE OR REPLACE PROCEDURE proc_three_task_check(IN c refcursor, task_1 VARCHAR, task_2 VARCHAR, task_3 VARCHAR) AS $$
BEGIN
OPEN c FOR
	WITH success_1_2 AS (SELECT Nickname
	FROM Peers
	JOIN Checks check1 ON check1.peer = Nickname AND check1.task = task_1
	JOIN Checks check2 ON check2.peer = Nickname AND check2.task = task_2
	JOIN P2P p1 ON p1."Check" = check1.id AND p1.State = 'Success'
	JOIN P2P p2 ON p2."Check" = check2.id AND p2.State = 'Success'),

	success_3 AS (SELECT Nickname
	FROM Peers
	JOIN Checks ON peer = Nickname and task = task_3
	JOIN P2P ON "Check" = Checks.id and State = 'Success')

	SELECT Nickname
	FROM ((SELECT * FROM success_1_2) except (SELECT * FROM success_3)) AS list;
END; 
$$ LANGUAGE plpgsql;

-- CALL proc_three_task_check('my_cursor', 'C2_SimpleBashUtils', 'C3_s21_string+', 'DO1_Linux');
-- FETCH ALL FROM my_cursor;
/*
"zuzannad"
"feermaka"
"lorikorn"
*/
------------------------------------------------------------------------------------------------
/*
12) Используя рекурсивное обобщенное табличное выражение, 
для каждой задачи вывести кол-во предшествующих ей задач
То есть сколько задач нужно выполнить, исходя из условий 
входа, чтобы получить доступ к текущей.
Формат вывода: название задачи, количество предшествующих

Пример вывода:

Task	PrevCount
CPP3	7
A1		9
C5		1

*/

CREATE OR REPLACE PROCEDURE proc_get_num_of_parental(IN c refcursor) AS $$
BEGIN
OPEN c FOR
	WITH RECURSIVE TaskHierarchy AS (
	  SELECT Title, ParentTask
	  FROM Tasks
	  WHERE ParentTask IS NOT NULL
	  UNION ALL
	  SELECT t.Title, t.ParentTask
	  FROM Tasks t
	  INNER JOIN TaskHierarchy th ON th.Title = t.ParentTask
	)
	
	SELECT substring(Tasks.Title, '^(\D+\d+)_') AS Task, COUNT(Tasks.ParentTask) AS PrevCount
	FROM Tasks
	JOIN TaskHierarchy ON TaskHierarchy.Title = tasks.title
	GROUP BY Tasks.Title
	ORDER BY Task;
END; 
$$ LANGUAGE plpgsql;

-- CALL proc_get_num_of_parental('my_cursor', 'C2_SimpleBashUtils', 'C3_s21_string+', 'DO1_Linux');
-- FETCH ALL FROM my_cursor;	
/*
"A1"	10
"A2"	11
"A3"	12
"A4"	12
"A5"	12
"A6"	12
"A7"	12
"A8"	12
"C3"	1
"C4"	1
"C5"	2
"C6"	3
"C7"	4
"C8"	5
"CPP1"	6
"CPP2"	7
"CPP3"	8
"CPP4"	9
"CPP5"	10
"CPP6"	10
"CPP7"	10
"CPP8"	10
"CPP9"	10
"DO1"	2
"DO2"	3
"DO3"	4
"DO4"	5
"DO5"	5
"DO6"	6
"SQL1"	6
"SQL2"	7
"SQL3"	8
*/
------------------------------------------------------------------------------------------------
/*
13) Найти "удачные" для проверок дни. День считается "удачным", 
если в нем есть хотя бы N идущих подряд успешных проверки
Параметры процедуры: количество идущих подряд успешных проверок N.
Временем проверки считать время начала P2P этапа.
Под идущими подряд успешными проверками подразумеваются 
успешные проверки, между которыми нет неуспешных.
При этом кол-во опыта за каждую из этих проверок должно быть не меньше 80% от максимального.
Формат вывода: список дней
*/

CREATE OR REPLACE PROCEDURE proc_lucky_days(IN c refcursor, N INTEGER) AS $$
DECLARE 
runner RECORD;
counter INTEGER DEFAULT 0;
prev_date date DEFAULT '1970-01-01';
BEGIN

    CREATE TEMPORARY TABLE temp_table
    (
        date_list date
    ) ON COMMIT DROP;
	
    FOR runner IN SELECT * FROM (SELECT * 
		FROM checks
		JOIN P2P ON "Check" = checks.id AND state != 'Start'
		JOIN tasks ON tasks.title = checks.task
		JOIN XP ON XP."Check" = checks.id  
		GROUP BY checks.date, checks.id, p2p.id, tasks.title, XP.id
		ORDER BY checks.date, P2P.time) AS list
    LOOP
		if runner.date != prev_date then
			counter = 0;
		end if;
        IF runner.state = 'Success' AND runner.XPAmount > runner.MaxXP * 0.8 Then
			counter:= counter + 1;
		else
			counter:=0;
		end if;
		if counter = N then
			insert INTO temp_table(date_list) values(runner.date);
		end if;
		prev_date = runner.date;
    END LOOP;
	OPEN c FOR
		SELECT * FROM temp_table;
END; 
$$ LANGUAGE plpgsql;

-- CALL proc_lucky_days('my_cursor', 2);
-- FETCH ALL FROM my_cursor;
/*
"2023-08-05"
"2023-08-12"
"2023-08-20"
"2023-08-22"
"2023-08-23"
"2023-08-28"
*/
------------------------------------------------------------------------------------------------
/*
14) Определить пира с наибольшим количеством XP
Формат вывода: ник пира, количество XP

Пример вывода:

Peer	XP
Amogus	15000

*/
CREATE OR REPLACE PROCEDURE proc_get_best_peer(IN c refcursor) AS $$
BEGIN
OPEN c FOR
	WITH xp_per_peer AS (SELECT 
		nickname,
		sum(XP.xpamount) AS XP
	FROM peers
	JOIN Checks ON Checks.peer = Nickname
	JOIN XP ON XP."Check" = Checks.id
	GROUP BY nickname)
	
	SELECT 
	nickname,
	XP
	FROM xp_per_peer
	WHERE XP = (SELECT max(Xp) FROM xp_per_peer);
END;
$$ LANGUAGE plpgsql;

-- CALL proc_get_best_peer('my_cursor');
-- FETCH ALL FROM my_cursor;
/*
"paqunada"	3800
*/
------------------------------------------------------------------------------------------------
/*
15) Определить пиров, приходивших раньше заданного времени не менее 
N раз за всё время
Параметры процедуры: время, количество раз N.
Формат вывода: список пиров

*/
CREATE OR REPLACE PROCEDURE proc_early_bird(IN c refcursor, visit time, N INTEGER) AS $$
BEGIN
	OPEN c FOR
	WITH common_table AS (SELECT Peer,
		COUNT(*) AS COUNT
		FROM TimeTracking
		WHERE TimeTracking.Time < visit 
		and State = 1
		GROUP BY Peer)
	
		SELECT peer FROM common_table WHERE COUNT >= N;
END;
$$ LANGUAGE plpgsql;

-- CALL proc_early_bird('my_cursor', '11:45:00', 1);
-- FETCH ALL FROM my_cursor;
/*
"feermaka"
"furetrgr"
"lorikorn"
"pipkomag"
*/
------------------------------------------------------------------------------------------------
/*
16) Определить пиров, выходивших за последние N дней из кампуса больше M раз
Параметры процедуры: количество дней N, количество раз M.
Формат вывода: список пиров
*/
CREATE OR REPLACE PROCEDURE proc_exit_frequency(IN c refcursor, N INTEGER, M INTEGER) AS $$
BEGIN
	OPEN c FOR
	WITH last_N_days AS (SELECT date AS N_day FROM TimeTracking GROUP by  TimeTracking.date ORDER by date DESC limit N),
	count_of_exits AS (SELECT peer, COUNT(*) FROM TimeTracking JOIN last_N_days ON TimeTracking.date = last_N_days.N_day WHERE state = 2 GROUP by peer  )
	SELECT peer FROM count_of_exits WHERE COUNT > M ;
END;
$$ LANGUAGE plpgsql;

-- CALL proc_exit_frequency('my_cursor', 2, 1);
-- FETCH ALL FROM my_cursor;
/*
"sanitell"
*/
------------------------------------------------------------------------------------------------
/*
17) Определить для каждого месяца процент ранних входов
Для каждого месяца посчитать, сколько раз люди, родившиеся в этот месяц, приходили в кампус за всё время (будем называть это общим числом входов).
Для каждого месяца посчитать, сколько раз люди, родившиеся в этот месяц, приходили в кампус раньше 12:00 за всё время (будем называть это числом ранних входов).
Для каждого месяца посчитать процент ранних входов в кампус относительно общего числа входов.
Формат вывода: месяц, процент ранних входов

Пример вывода:

Month	EarlyEntries
January	15
February	35
March	45
*/

-- INSERT INTO TimeTracking (id, Peer, Date, Time, State)
-- VALUES (17, 'bozerrks', '2023-08-02', '07:32:00', 1);
CREATE OR REPLACE PROCEDURE proc_early_visit_per_month(IN c refcursor) AS $$
BEGIN
	
	CREATE TEMPORARY TABLE months (id INTEGER, month VARCHAR) ON COMMIT DROP;
	insert into months(id,month) values(1, 'January'),(2, 'February'),(3, 'March'), 
	(4, 'April'), (5, 'May'), (6, 'June'), 
	(7, 'July'), (8, 'August'), (9, 'September'), 
	(10, 'October'), (11, 'November'), (12,'December');
	OPEN c FOR
	
	SELECT  month AS month_name, COUNT(Nickname)
	FROM months
	LEFT JOIN TimeTracking ON EXTRACT(MONTH FROM date) = months.id and state = 1 and Time < '12:00:00'
	LEFT JOIN Peers ON Nickname = Peer AND EXTRACT(MONTH FROM birthday) = EXTRACT(MONTH FROM date) 
	GROUP BY month_name, months.id
	ORDER BY months.id;
	
END;
$$ LANGUAGE plpgsql;

-- CALL proc_early_visit_per_month('my_cursor');
-- FETCH ALL FROM my_cursor;
/*
"January"	0
"February"	0
"March"	0
"April"	0
"May"	0
"June"	0
"July"	0
"August"	1
"September"	0
"October"	0
"November"	0
"December"	0
*/
---------------------------------------------------------------------------------------------------------------------------------