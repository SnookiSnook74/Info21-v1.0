-- Active: 1693889407428@@127.0.0.1@5432@postgres@public
-----------------------------------------------
--                  PEERS                    --
----------------------------------------------- 
CREATE TABLE IF NOT EXISTS Peers
(
    Nickname VARCHAR NOT NULL PRIMARY KEY,
    Birthday DATE NOT NULL
);

INSERT INTO Peers (Nickname, Birthday)
VALUES 
    ('lorikorn', '1988-06-16'),
    ('paqunada', '1986-11-11'),
    ('feermaka', '1991-03-21'),
    ('zuzannad', '1981-11-18'),
    ('furetrgr', '1981-05-14'), 
    ('pipkomag', '1970-10-04'),
    ('sanitell', '1990-03-02'),
    ('prichmul', '1969-12-09'),
    ('fiirkont', '2000-04-22'),
    ('bozerrks', '1971-08-25');

-----------------------------------------------
--                  TASKS                    --
----------------------------------------------- 
CREATE TABLE IF NOT EXISTS Tasks
(
    Title varchar PRIMARY KEY ,
    ParentTask varchar,
    MaxXP INTEGER NOT NULL,
    FOREIGN KEY (ParentTask) REFERENCES Tasks (Title)
);

INSERT INTO Tasks
VALUES 
    ('C2_SimpleBashUtils', NULL, 250),
    ('C3_s21_string+', 'C2_SimpleBashUtils', 500),
    ('C4_s21_math', 'C2_SimpleBashUtils', 300),
    ('C5_s21_decimal', 'C4_s21_math', 350),
    ('C6_s21_matrix', 'C5_s21_decimal', 200),
    ('C7_SmartCalc_v1.0', 'C6_s21_matrix', 500),
    ('C8_3DViewer_v1.0', 'C7_SmartCalc_v1.0', 750),
    ('DO1_Linux', 'C3_s21_string+', 300),
    ('DO2_Linux_Network', 'DO1_Linux', 250),
    ('DO3_LinuxMonitoring_v1.0', 'DO2_Linux_Network', 350),
    ('DO4_LinuxMonitoring_v2.0', 'DO3_LinuxMonitoring_v1.0', 350),
    ('DO5_SimpleDocker', 'DO3_LinuxMonitoring_v1.0', 300),
    ('DO6_CICD', 'DO5_SimpleDocker', 300),
    ('CPP1_s21_matrix+', 'C8_3DViewer_v1.0', 300),
    ('CPP2_s21_containers', 'CPP1_s21_matrix+', 350),
    ('CPP3_SmartCalc_v2.0', 'CPP2_s21_containers', 600),
    ('CPP4_3DViewer_v2.0', 'CPP3_SmartCalc_v2.0', 750),
    ('CPP5_3DViewer_v2.1', 'CPP4_3DViewer_v2.0', 600),
    ('CPP6_3DViewer_v2.2', 'CPP4_3DViewer_v2.0', 800),
    ('CPP7_MLP', 'CPP4_3DViewer_v2.0', 700),
    ('CPP8_PhotoLab_v1.0', 'CPP4_3DViewer_v2.0', 450),
    ('CPP9_MonitoringSystem', 'CPP4_3DViewer_v2.0', 1000),
    ('A1_Maze', 'CPP4_3DViewer_v2.0', 300),
    ('A2_SimpleNavigator_v1.0', 'A1_Maze', 400),
    ('A3_Parallels', 'A2_SimpleNavigator_v1.0', 300),
    ('A4_Crypto', 'A2_SimpleNavigator_v1.0', 350),
    ('A5_s21_memory', 'A2_SimpleNavigator_v1.0', 400),
    ('A6_Transactions', 'A2_SimpleNavigator_v1.0', 700),
    ('A7_DNA_Analyzer', 'A2_SimpleNavigator_v1.0', 800),
    ('A8_Algorithmic_trading', 'A2_SimpleNavigator_v1.0', 800),
    ('SQL1_Bootcamp', 'C8_3DViewer_v1.0', 1500),
    ('SQL2_Info21_v1.0', 'SQL1_Bootcamp', 500),
    ('SQL3_RetailAnalitycs_v1.0', 'SQL2_Info21_v1.0', 600);

-----------------------------------------------
--                  STATUS                   --
----------------------------------------------- 
CREATE TYPE check_status 
AS ENUM ('Start', 'Success', 'Failure');

-----------------------------------------------
--                 CHECKS                    --
----------------------------------------------- 
CREATE TABLE IF NOT EXISTS Checks
(
    id BIGINT PRIMARY KEY,
    Peer varchar NOT NULL,
    Task varchar NOT NULL,
    Date date NOT NULL,
    FOREIGN KEY (Peer) REFERENCES Peers (Nickname),
    FOREIGN KEY (Task) REFERENCES Tasks (Title)
);

INSERT INTO Checks (id, peer, task, date)
VALUES 
(1, 'lorikorn', 'C2_SimpleBashUtils', '2023-08-01'),
(2, 'paqunada', 'C2_SimpleBashUtils', '2023-08-02'),
(3, 'lorikorn', 'C3_s21_string+', '2023-08-05'),
(4, 'paqunada', 'C3_s21_string+', '2023-08-05'),
(5, 'paqunada', 'C4_s21_math', '2023-08-06'),
(6, 'lorikorn', 'C4_s21_math', '2023-08-07'),
(7, 'lorikorn', 'C5_s21_decimal', '2023-08-11'),
(8, 'paqunada', 'C5_s21_decimal', '2023-08-12'),
(9, 'feermaka', 'C2_SimpleBashUtils', '2023-08-12'),
(10, 'lorikorn', 'C6_s21_matrix', '2023-08-15'),
(11, 'feermaka', 'C3_s21_string+', '2023-08-18'),
(12, 'lorikorn', 'C7_SmartCalc_v1.0', '2023-08-19'), -- FAIL
(13, 'paqunada', 'C6_s21_matrix', '2023-08-20'),
(14, 'zuzannad', 'C2_SimpleBashUtils', '2023-08-20'),
(15, 'zuzannad', 'C3_s21_string+', '2023-08-22'),
(16, 'zuzannad', 'C4_s21_math', '2023-08-22'), -- FAIL
(17, 'lorikorn', 'C8_3DViewer_v1.0', '2023-08-22'),
(18, 'feermaka', 'C4_s21_math', '2023-08-22'),
(19, 'paqunada', 'C7_SmartCalc_v1.0', '2023-08-23'),
(20, 'zuzannad', 'C5_s21_decimal', '2023-08-23'),
(21, 'feermaka', 'C5_s21_decimal', '2023-08-25'),
(22, 'feermaka', 'C6_s21_matrix', '2023-08-28'),
(23, 'paqunada', 'C8_3DViewer_v1.0', '2023-08-28'),
(24, 'pipkomag', 'C2_SimpleBashUtils', '2023-08-29'),
(25, 'paqunada', 'DO1_Linux', '2023-09-04'),
(26, 'paqunada', 'DO2_Linux_Network', '2023-09-07'),
(27, 'sanitell', 'C2_SimpleBashUtils', '2023-09-11'),
(28, 'paqunada', 'DO3_LinuxMonitoring_v1.0', '2023-09-12'),
(29, 'prichmul', 'C2_SimpleBashUtils', '2023-09-17'),
(30, 'fiirkont', 'C2_SimpleBashUtils', '2023-09-19');

-----------------------------------------------
--                   P2P                     --
----------------------------------------------- 
CREATE TABLE IF NOT EXISTS P2P
(
    id bigint PRIMARY KEY NOT NULL,
    "Check" BIGINT NOT NULL,
    CheckingPeer varchar NOT NULL,
    State check_status NOT NULL,
    Time time NOT NULL,
    FOREIGN KEY ("Check") REFERENCES Checks (ID),
    FOREIGN KEY (CheckingPeer) REFERENCES Peers (Nickname)
);

INSERT INTO P2P (id, "Check", CheckingPeer, State, Time)
VALUES (1,  1, 'paqunada', 'Start', '09:00:00'),
       (2,  1, 'paqunada', 'Success', '10:00:00'), 
       (3,  2, 'lorikorn', 'Start', '13:00:00'),
       (4,  2, 'lorikorn', 'Success', '14:00:00'),
       (5,  3, 'feermaka', 'Start', '18:00:00'),
       (6,  3, 'feermaka', 'Success', '19:00:00'),
       (7,  4, 'zuzannad', 'Start', '15:00:00'),
       (8,  4, 'zuzannad', 'Success', '16:00:00'), 
       (9,  5, 'furetrgr', 'Start', '14:00:00'),
       (10, 5, 'furetrgr', 'Success', '15:00:00'),
       (11, 6, 'pipkomag', 'Start', '01:00:00'),
       (12, 6, 'pipkomag', 'Success', '02:00:00'),
       (13, 7, 'sanitell', 'Start', '10:00:00'),
       (14, 7, 'sanitell', 'Success', '11:00:00'),
       (15, 8, 'prichmul', 'Start', '12:00:00'),
       (16, 8, 'prichmul', 'Success', '13:00:00'),
       (17, 9, 'fiirkont', 'Start', '12:00:00'),
       (18, 9, 'fiirkont', 'Success', '13:00:00'),
       (19, 10,'bozerrks', 'Start', '19:00:00'),
       (20, 10,'bozerrks', 'Success', '20:00:00'),
       (21, 11,'furetrgr', 'Start', '15:00:00'),
       (22, 11,'furetrgr', 'Success', '15:30:00'),
       (23, 12,'sanitell', 'Start', '18:00:00'),
       (24, 12,'sanitell', 'Failure', '19:00:00'), -- FAIL
       (25, 13,'zuzannad', 'Start', '18:00:00'),
       (26, 13,'zuzannad', 'Success', '19:00:00'),
       (27, 14, 'lorikorn', 'Start', '18:00:00'),
       (28, 14, 'lorikorn', 'Success', '19:00:00'),
       (29, 15, 'fiirkont', 'Start', '04:00:00'),
       (30, 15, 'fiirkont', 'Success', '05:00:00'),
       (31, 16, 'lorikorn', 'Start', '05:00:00'),
       (32, 16, 'lorikorn', 'Failure', '06:00:00'), -- FAIL
       (33, 17, 'sanitell', 'Start', '07:00:00'),
       (34, 17, 'sanitell', 'Success', '08:00:00'),
       (35, 18, 'bozerrks', 'Start', '08:00:00'),
       (36, 18, 'bozerrks', 'Success', '08:30:00'),
       (37, 19, 'zuzannad', 'Start', '09:00:00'),
       (38, 19, 'zuzannad', 'Success', '10:00:00'),
       (39, 20, 'pipkomag', 'Start', '11:00:00'),
       (40, 20, 'pipkomag', 'Success', '12:00:00'),
       (41, 21, 'lorikorn', 'Start', '11:00:00'),
       (42, 21, 'lorikorn', 'Success', '12:00:00'),
       (43, 22, 'paqunada', 'Start', '05:00:00'),
       (44, 22, 'paqunada', 'Success', '06:00:00'),
       (45, 23, 'feermaka', 'Start', '10:00:00'),
       (46, 23, 'feermaka', 'Success', '11:00:00'),
       (47, 24, 'zuzannad', 'Start', '11:00:00'),
       (48, 24, 'zuzannad', 'Success', '12:00:00'),
       (49, 25, 'furetrgr', 'Start', '18:00:00'),
       (50, 25, 'furetrgr', 'Success', '19:00:00'),
       (51, 26, 'pipkomag', 'Start', '15:00:00'),
       (52, 26, 'pipkomag', 'Success', '16:00:00'),
       (53, 27, 'paqunada', 'Start', '13:00:00'),
       (54, 27, 'paqunada', 'Success', '14:00:00'),
       (55, 28, 'prichmul', 'Start', '13:00:00'),
       (56, 28, 'prichmul', 'Success', '14:00:00'),
       (57, 29, 'fiirkont', 'Start', '16:00:00'),
       (58, 29, 'fiirkont', 'Success', '17:00:00'),
       (59, 30, 'bozerrks', 'Start', '18:00:00'),
       (60, 30, 'bozerrks', 'Success', '19:00:00');

-----------------------------------------------
--                  VERTER                   --
----------------------------------------------- 
CREATE TABLE Verter
(
    ID bigint PRIMARY KEY NOT NULL,
    "Check" bigint  NOT NULL,
    State check_status NOT NULL,
    Time time NOT NULL,
    FOREIGN KEY ("Check") REFERENCES Checks (ID)
);

INSERT INTO Verter (id, "Check", State, Time)
VALUES (1, 1, 'Start', '13:01:00'),
       (2, 1, 'Success', '13:02:00'),
       (3, 2, 'Start', '13:01:00'),
       (4, 2, 'Success', '13:02:00'),
       (5, 3, 'Start', '19:01:00'),
       (6, 3, 'Success', '19:02:00'),
       (7, 4, 'Start', '16:01:00'),
       (8, 4, 'Failure', '16:02:00'),
       (9, 5, 'Start', '15:01:00'),
       (10, 5, 'Success', '15:02:00'),
       (11, 6, 'Start', '19:01:00'),
       (12, 6, 'Success', '19:02:00'),
       (13, 7, 'Start', '13:01:00'),
       (14, 7, 'Success', '13:02:00'),
       (15, 8, 'Start', '13:01:00'),
       (16, 8, 'Success', '13:02:00'),
       (17, 9, 'Start', '19:01:00'),
       (18, 9, 'Success', '19:02:00'),
       (19, 10, 'Start', '16:01:00'),
       (20, 10, 'Failure', '16:02:00'),
       (21, 11, 'Start', '15:01:00'),
       (22, 11, 'Success', '15:02:00'),
       (23, 13, 'Start', '05:01:00'),
       (24, 13, 'Failure', '05:02:00'),
       (25, 14, 'Start', '10:01:00'),
       (26, 14, 'Success', '10:02:00'),
       (27, 15, 'Start', '08:01:00'),
       (28, 15, 'Success', '08:02:00'),
       (29, 16, 'Start', '10:01:00'),
       (30, 16, 'Failure', '10:02:00'),
       (31, 18, 'Start', '10:01:00'),
       (32, 18, 'Success', '10:02:00'),
       (33, 20, 'Start', '11:01:00'),
       (34, 20, 'Failure', '11:02:00'),
       (35, 21, 'Start', '12:01:00'),
       (36, 21, 'Success', '12:02:00'),
       (37, 22, 'Start', '11:01:00'),
       (38, 22, 'Success', '11:02:00'),
       (39, 24, 'Start', '12:01:00'),
       (40, 24, 'Success', '12:02:00'),
       (41, 27, 'Start', '14:01:00'),
       (42, 27, 'Success', '14:02:00'),
       (43, 29, 'Start', '17:01:00'),
       (44, 29, 'Success', '17:02:00'),
       (45, 30, 'Start', '19:01:00'),
       (46, 30, 'Success', '19:02:00');

-----------------------------------------------
--                  POINTS                   --
----------------------------------------------- 
CREATE TABLE IF NOT EXISTS TransferredPoints
(
    ID bigint NOT NULL GENERATED ALWAYS AS IDENTITY
    (INCREMENT 1 START 1) PRIMARY KEY,
    CheckingPeer varchar NOT NULL,
    CheckedPeer  varchar NOT NULL,
    PointsAmount integer NOT NULL,
    FOREIGN KEY (CheckingPeer) REFERENCES Peers (Nickname),
    FOREIGN KEY (CheckedPeer) REFERENCES Peers (Nickname)
);

INSERT INTO TransferredPoints (CheckingPeer, CheckedPeer, PointsAmount)
SELECT checkingpeer, Peer, count(*) from P2P
JOIN Checks C on C.ID = P2P."Check"
WHERE State != 'Start'
GROUP BY 1,2;

-----------------------------------------------
--                  FRIENDS                  --
----------------------------------------------- 
CREATE TABLE IF NOT EXISTS Friends
(
    id bigint PRIMARY KEY,
    Peer1 varchar NOT NULL,
    Peer2 varchar NOT NULL,
    FOREIGN KEY (Peer1) REFERENCES Peers (Nickname),
    FOREIGN KEY (Peer2) REFERENCES Peers (Nickname)
);

INSERT INTO Friends (id, Peer1, Peer2)
VALUES (1, 'lorikorn', 'paqunada'),
       (2, 'lorikorn', 'bozerrks'),
       (3, 'feermaka', 'zuzannad'),
       (4, 'furetrgr', 'pipkomag'),
       (5, 'pipkomag', 'lorikorn'),
       (6, 'pipkomag', 'paqunada'),
       (7, 'pipkomag', 'feermaka'),
       (8, 'sanitell', 'bozerrks'),
       (9, 'sanitell', 'zuzannad'),
       (10, 'fiirkont', 'bozerrks');

-----------------------------------------------
--              RECOMENDATION                --
----------------------------------------------- 
CREATE TABLE IF NOT EXISTS Recommendations
(
    ID bigint PRIMARY KEY NOT NULL,
    Peer varchar NOT NULL,
    RecommendedPeer varchar NOT NULL,
    FOREIGN KEY (Peer) REFERENCES Peers (Nickname),
    FOREIGN KEY (RecommendedPeer) REFERENCES Peers (Nickname)
);

INSERT INTO Recommendations (id, Peer, RecommendedPeer)
VALUES (1, 'lorikorn', 'paqunada'),
       (2, 'lorikorn', 'feermaka'),
       (3, 'paqunada', 'furetrgr'),
       (4, 'feermaka', 'furetrgr'),
       (5, 'zuzannad', 'lorikorn'),
       (6, 'furetrgr', 'bozerrks'),
       (7, 'pipkomag', 'zuzannad'),
       (8, 'sanitell', 'furetrgr'),
       (9, 'prichmul', 'lorikorn'),
       (10, 'fiirkont', 'pipkomag');

-----------------------------------------------
--                     XP                    --
----------------------------------------------- 
CREATE TABLE IF NOT EXISTS XP
(
    id BIGINT PRIMARY KEY ,
    "Check" BIGINT  NOT NULL ,
    XPAmount INTEGER NOT NULL ,
    FOREIGN KEY ("Check") REFERENCES Checks (id)
);

INSERT INTO XP (id, "Check", XPAmount)
VALUES (1, 1, 250),
       (2, 2, 250),
       (3, 3, 500),
       (4, 4, 500),
       (5, 5, 300),
       (6, 6, 300),
       (7, 7, 350),
       (8, 8, 350),
       (9, 9, 250),
       (10, 10, 200),
       (11, 11, 500),
       (12, 13, 250),
       (13, 14, 250),
       (14, 15, 500),
       (15, 17, 750),
       (16, 18, 300),
       (17, 19, 500),
       (18, 20, 350),
       (19, 21, 350),
       (20, 22, 250),
       (21, 23, 750),
       (22, 24, 250),
       (23, 25, 300),
       (24, 26, 250),
       (25, 27, 250),
       (26, 28, 350),
       (27, 29, 250),
       (28, 30, 250);

-----------------------------------------------
--              TIMETRACKING                 --
----------------------------------------------- 
CREATE TABLE IF NOT EXISTS TimeTracking
(
    id bigint PRIMARY KEY NOT NULL,
    Peer varchar NOT NULL,
    Date date NOT NULL,
    Time time NOT NULL,
    State bigint NOT NULL CHECK ( State IN (1, 2)),
    FOREIGN KEY (Peer) REFERENCES Peers (Nickname)
);

INSERT INTO TimeTracking (id, Peer, Date, Time, State)
VALUES (1, 'lorikorn', '2023-08-02', '07:32:00', 1),
       (2, 'lorikorn', '2023-08-02', '18:22:00', 2),
       (3, 'paqunada', '2023-08-02', '16:11:00', 1),
       (4, 'paqunada', '2023-08-02', '19:33:00', 2),
       (5, 'zuzannad', '2023-08-02', '12:04:00', 1),
       (6, 'zuzannad', '2023-08-02', '21:54:00', 2),
       (7, 'feermaka', '2023-08-22', '08:34:00', 1),
       (8, 'furetrgr', '2023-08-22', '11:26:00', 1),
       (9, 'furetrgr', '2023-08-22', '21:11:00', 2),
       (10, 'feermaka', '2023-08-22', '19:01:00', 2),
       (11, 'sanitell', '2023-09-02', '18:23:00', 1),
       (12, 'sanitell', '2023-09-02', '21:11:00', 2),
       (13, 'pipkomag', '2023-09-02', '07:32:00', 1),
       (14, 'pipkomag', '2023-09-02', '19:23:00', 2),
       (15, 'sanitell', '2023-09-02', '11:45:00', 1),
       (16, 'sanitell', '2023-09-02', '19:42:00', 2);

-----------------------------------------------
--              EXPORT/IMPORT                --
----------------------------------------------- 
CREATE OR REPLACE PROCEDURE export(IN tablename varchar, IN path text, IN separator char) AS $$
    BEGIN
        EXECUTE format('COPY %s TO ''%s'' DELIMITER ''%s'' CSV HEADER;',
            tablename, path, separator);
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE import(IN tablename varchar, IN path text, IN separator char) AS $$
    BEGIN
        EXECUTE format('COPY %s FROM ''%s'' DELIMITER ''%s'' CSV HEADER;',
            tablename, path, separator);
    END;
$$ LANGUAGE plpgsql;

-----------------------------------------------
--                  CHECK                    --
----------------------------------------------- 

--CALL export('p2p', '/tmp/file.csv', ',');
--TRUNCATE p2p;
--CALL "import"('p2p', '/tmp/file.csv', ',');