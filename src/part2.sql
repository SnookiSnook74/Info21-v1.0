CREATE OR REPLACE PROCEDURE AddP2PCheck(
    _Peer VARCHAR, 
    _CheckingPeer VARCHAR, 
    _TaskTitle VARCHAR, 
    _State check_status, 
    _Time TIME
)
LANGUAGE plpgsql
AS $$
DECLARE
    new_check_id BIGINT;
    existing_check_id BIGINT;
    max_check_id BIGINT;
    max_p2p_id BIGINT;
    completed_check_id BIGINT;
BEGIN
    -- Находим максимальные id в таблицах
    SELECT MAX(id) INTO max_check_id FROM Checks;
    SELECT MAX(id) INTO max_p2p_id FROM P2P;

    -- Проверяем, завершена ли уже P2P проверка
    SELECT Checks.id INTO completed_check_id
    FROM P2P
    JOIN Checks ON P2P."Check" = Checks.id
    WHERE Checks.Peer = _Peer AND Checks.Task = _TaskTitle AND P2P.CheckingPeer = _CheckingPeer AND (P2P.State = 'Success' OR P2P.State = 'Failure');

    IF completed_check_id IS NOT NULL THEN
        RAISE EXCEPTION 'Этот проект уже завершился проверкой от данного пира. Повторная проверка от данного пира невозможна.';
    END IF;

    -- Если статус "начало", проверяем, есть ли незавершенная P2P проверка
    IF _State = 'Start' THEN
        SELECT Checks.id INTO existing_check_id
        FROM P2P
        JOIN Checks ON P2P."Check" = Checks.id
        WHERE Checks.Peer = _Peer AND Checks.Task = _TaskTitle AND P2P.CheckingPeer = _CheckingPeer AND P2P.State = 'Start';

        IF existing_check_id IS NOT NULL THEN
            RAISE EXCEPTION 'Проветка этого проекта для данного пира уже началась.';
        END IF;
    ELSE
        -- Если статус "Success" или "Failure", находим существующую запись со статусом "Start"
        SELECT Checks.id INTO existing_check_id
        FROM P2P
        JOIN Checks ON P2P."Check" = Checks.id
        WHERE Checks.Peer = _Peer AND Checks.Task = _TaskTitle AND P2P.CheckingPeer = _CheckingPeer AND P2P.State = 'Start';

        IF existing_check_id IS NULL THEN
            RAISE EXCEPTION 'Провека данного проекта еще не началсь, завершить такую проверку невозможно.';
        END IF;
    END IF;

    -- Если статус "начало", добавляем запись в таблицу Checks
    IF _State = 'Start' THEN
        new_check_id := max_check_id + 1;
        INSERT INTO Checks (id, Peer, Task, Date)
        VALUES (new_check_id, _Peer, _TaskTitle, CURRENT_DATE);
    END IF;

    INSERT INTO P2P (id, "Check", CheckingPeer, State, Time)
    -- Если new_check_id не NULL (то есть, если была добавлена новая запись в таблицу Checks), 
    -- то будет использовано это значение. В противном случае будет использовано значение existing_check_id(уже существующей записи).
    VALUES (max_p2p_id + 1, COALESCE(new_check_id, existing_check_id), _CheckingPeer, _State, _Time);

END;
$$;

CREATE OR REPLACE PROCEDURE AddVerterCheck(
    _Peer VARCHAR, 
    _TaskTitle VARCHAR, 
    _State check_status, 
    _Time TIME
)
LANGUAGE plpgsql
AS $$
DECLARE
    latest_successful_p2p_id BIGINT;
    max_verter_id BIGINT;
    existing_start_id BIGINT;
    existing_end_id BIGINT;
BEGIN
    -- Находим максимальный id в таблице Verter
    SELECT MAX(id) INTO max_verter_id FROM Verter;
    
    -- Находим последнюю успешную P2P проверку
    SELECT Checks.id INTO latest_successful_p2p_id
    FROM P2P
    JOIN Checks ON P2P."Check" = Checks.id
    WHERE Checks.Peer = _Peer AND Checks.Task = _TaskTitle AND P2P.State = 'Success'
    ORDER BY P2P.Time DESC
    LIMIT 1;
    
    IF latest_successful_p2p_id IS NULL THEN
        RAISE EXCEPTION 'Нет успешных P2P проверок для данного задания и пользователя.';
    END IF;
    
    -- Проверяем, начата ли уже проверка (Start)
    SELECT "Check" INTO existing_start_id
    FROM Verter
    WHERE "Check" = latest_successful_p2p_id AND State = 'Start';
    
    -- Проверяем, завершена ли уже проверка (Success или Failure)
    SELECT "Check" INTO existing_end_id
    FROM Verter
    WHERE "Check" = latest_successful_p2p_id AND (State = 'Success' OR State = 'Failure');
    
    IF _State = 'Start' AND existing_start_id IS NOT NULL THEN
        RAISE EXCEPTION 'Проверка для данного задания и пользователя уже начата.';
    END IF;

    IF (_State = 'Success' OR _State = 'Failure') AND existing_start_id IS NULL THEN
        RAISE EXCEPTION 'Проверка не может быть завершена без начальной стадии.';
    END IF;
    
    IF (_State = 'Success' OR _State = 'Failure') AND existing_end_id IS NOT NULL THEN
        RAISE EXCEPTION 'Проверка для данного задания и пользователя уже завершена.';
    END IF;
    
    INSERT INTO Verter (id, "Check", State, Time)
    VALUES (max_verter_id + 1, latest_successful_p2p_id, _State, _Time);
    
END;
$$;

CREATE OR REPLACE FUNCTION update_transferred_points()
RETURNS TRIGGER AS $$
DECLARE
    checked_peer_name varchar;
    existing_points integer;
BEGIN
    -- Получение имени проверяемого пира из таблицы Checks по ID проверки ("Check"), связанной с P2P
    SELECT Peer INTO checked_peer_name FROM Checks WHERE id = NEW."Check";
    
    -- Проверяем, существует ли уже такая пара в TransferredPoints
    SELECT PointsAmount INTO existing_points 
    FROM TransferredPoints 
    WHERE CheckingPeer = NEW.CheckingPeer AND CheckedPeer = checked_peer_name;
    
    IF NEW.State = 'Start' THEN
        -- Если такая пара существует, увеличиваем количество переданных пир-поинтов на 1
        IF existing_points IS NOT NULL THEN
            UPDATE TransferredPoints
            SET PointsAmount = PointsAmount + 1
            WHERE CheckingPeer = NEW.CheckingPeer AND CheckedPeer = checked_peer_name;
        -- Если такой пары нет, создаем новую запись
        ELSE
            INSERT INTO TransferredPoints (CheckingPeer, CheckedPeer, PointsAmount)
            VALUES (NEW.CheckingPeer, checked_peer_name, 1);
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_points
AFTER INSERT ON P2P
FOR EACH ROW 
EXECUTE FUNCTION update_transferred_points();

CREATE OR REPLACE FUNCTION validate_xp_entry()
RETURNS TRIGGER AS $$
DECLARE
    max_xp_for_task INTEGER;
    check_status check_status;
BEGIN
    -- Получаем максимальное количество XP для задачи, указанной в поле "Check"
    SELECT MaxXP INTO max_xp_for_task 
	FROM Tasks
    JOIN Checks ON Checks.Task = Tasks.Title
    WHERE Checks.id = NEW."Check";

    IF max_xp_for_task IS NULL THEN
        RAISE EXCEPTION 'Задача не найдена для ID %', NEW."Check";
    END IF;
    
    -- Получаем статус проверки
    SELECT State INTO check_status 
	FROM P2P
    WHERE "Check" = NEW."Check"
    AND State = 'Success'
    LIMIT 1;

    -- Проверяем, что количество XP не превышает максимальное и проверка успешна
    IF NEW.XPAmount > max_xp_for_task OR check_status != 'Success' THEN
        RAISE EXCEPTION 'Превышено максимальное значение XP или проверка не завершилась успехом';
    END IF;
    
    -- Если все проверки пройдены, возвращаем новую запись для вставки
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER validate_xp_entry_trigger
BEFORE INSERT ON XP
FOR EACH ROW EXECUTE FUNCTION validate_xp_entry();

-------------------------
--        TEST         --
-------------------------

CALL AddP2PCheck('fiirkont', 'prichmul', 'DO1_Linux', 'Start', '19:00');
CALL AddP2PCheck('fiirkont', 'prichmul', 'DO1_Linux', 'Success', '19:00');

CALL AddP2PCheck('fiirkont', 'prichmul', 'CPP2_s21_containers', 'Start', '20:00');
CALL AddP2PCheck('fiirkont', 'prichmul', 'CPP2_s21_containers', 'Success', '20:00');

CALL addvertercheck('fiirkont', 'DO1_Linux', 'Start', '20:03:00');
CALL addvertercheck('fiirkont', 'DO1_Linux', 'Failure', '20:05:00');

CALL addvertercheck('fiirkont', 'CPP2_s21_containers', 'Start', '21:03:00');
CALL addvertercheck('fiirkont', 'CPP2_s21_containers', 'Failure', '21:05:00');

INSERT INTO XP (id, "Check", XPAmount) VALUES ((SELECT MAX(id) + 1 FROM xp), 31, 150);
-- Пытаемся записать больше экспы чем возможно
--INSERT INTO XP (id, "Check", XPAmount) VALUES ((SELECT MAX(id) + 1 FROM xp), 31, 500);
-- Нет успешной проверки в таблице p2p
--INSERT INTO XP (id, "Check", XPAmount) VALUES ((SELECT MAX(id) + 1 FROM xp), 32, 150);