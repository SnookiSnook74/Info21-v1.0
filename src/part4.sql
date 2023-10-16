CREATE OR REPLACE PROCEDURE part4_1(t_name IN VARCHAR)  -- процедура дропает все таблицы, начинающиеся с t_name
LANGUAGE plpgsql
AS $$
DECLARE
   _tbl TEXT;
BEGIN
FOR _tbl  IN  -- запоминаем в _tbl все имена в цикле for
    SELECT table_name
    FROM   information_schema.tables  -- поиск таблиц по всей датабазе
    WHERE  table_name LIKE t_name || '%'  -- находим таблицы по префиксу t_name
    AND table_schema = 'public'
LOOP
  EXECUTE 'drop table if exists ' || quote_ident(_tbl) || ' cascade';  -- 'cascade' удаляет таблицу _tbl и все зависимости
END LOOP;
END
$$;

CREATE OR REPLACE PROCEDURE part4_2(  -- процедура выводит имена всех функций с хотя бы одним параметром, выходной аргумент -- их количество
  output OUT INT
)
language plpgsql
AS $$
DECLARE
    functionName RECORD;
BEGIN
    output := 0;
    FOR functionName IN 
      SELECT DISTINCT proname AS name, pg_catalog.pg_get_function_identity_arguments(p.oid) AS args
      FROM pg_proc p INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
      WHERE pronamespace = 'public'::regnamespace and (pg_get_function_identity_arguments(p.oid) = '') IS NOT TRUE  -- ищем в public schema, исключая системные функции
      AND ns.nspname = 'public' AND proname IN (
        SELECT routine_name FROM information_schema.routines WHERE specific_schema = 'public' AND routine_type = 'FUNCTION'
      )
     LOOP
      RAISE INFO 'name: %, type: %', quote_ident(functionName.name), quote_ident(functionName.args);
      output := output + 1;
    END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE part4_3(  -- процедура удаляет триггеры в текущей датабазе и выдает уничтоженное количество как out-параметр
  counter OUT INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    triggNameRecord RECORD;  -- record это переменная типа rows
    triggTableRecord RECORD;
BEGIN
    counter := 0;
    FOR triggNameRecord IN SELECT DISTINCT(trigger_name) FROM information_schema.triggers WHERE trigger_schema = 'public' LOOP  -- находим все триггеры в датабазе для схемы public (не включаем системные триггеры)
        FOR triggTableRecord IN SELECT DISTINCT(event_object_table) from information_schema.triggers WHERE trigger_name = triggNameRecord.trigger_name LOOP  -- удаляем триггеры по именам в каждой таблице. Второй for-цикл обеспечивает удаление триггеров с одинаковым именем из разных таблиц
            EXECUTE 'DROP TRIGGER ' || triggNameRecord.trigger_name || ' ON ' || triggTableRecord.event_object_table || ';';
            counter := counter + 1;
        END LOOP;    
    END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE part4_4(  -- процедура выводит имена и типы процедур и функций, содержащие строчку input1
  input1 IN VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    procedureName RECORD;
BEGIN
    FOR procedureName IN 
        SELECT DISTINCT routine_name, routine_type
        FROM information_schema.routines
        WHERE
        routine_schema = 'public' -- находим все процедуры и функции в датабазе для схемы public (не включаем системные процедуры и функции)
        AND routine_definition like '%' || input1 || '%'  -- в которых встречается %input1%
     LOOP
      RAISE INFO 'name: %, type: %', quote_ident(procedureName.routine_name), quote_ident(procedureName.routine_type);
    END LOOP;
END;
$$;

---------------------
--///// TESTS /////--
---------------------


CREATE TABLE person (
    id BIGINT NOT NULL,
    name VARCHAR,
    age INT,
    gender VARCHAR,
    address VARCHAR
);

create table person_audit (
    created timestamp with time zone not null default current_timestamp,
    type_event char(1) not null default 'I',
    row_id bigint not null,
    name varchar,
    age int,
    gender varchar,
    address varchar
);

CALL part4_1('p');

CREATE OR REPLACE FUNCTION fnc_trg_person_insert_audit() RETURNS trigger AS $body$    
BEGIN
        if (TG_OP = 'INSERT') THEN
            insert into person_audit SELECT now(), 'I', new.id, new.name, new.age, new.gender, new.address;
        RETURN NEW;
        end if;
END;
$body$
LANGUAGE plpgsql

CREATE TABLE person (
    id BIGINT NOT NULL,
    name VARCHAR,
    age INT,
    gender VARCHAR,
    address VARCHAR
);

OR REPLACE TRIGGER trg_person_insert_audit
AFTER INSERT on person
FOR EACH ROW
EXECUTE PROCEDURE fnc_trg_person_insert_audit();

CREATE OR REPLACE FUNCTION test_func_1(integer, integer) RETURNS integer
    AS 'select $1 + $2;'
    LANGUAGE SQL
    IMMUTABLE
    RETURNS NULL ON NULL INPUT;

CALL part4_2(0);

CREATE OR REPLACE FUNCTION fnc_trg_person_insert_audit() RETURNS trigger AS $body$    
BEGIN
        IF (TG_OP = 'INSERT') THEN
            INSERT INTO person_audit SELECT now(), 'I', new.id, new.name, new.age, new.gender, new.address;
        RETURN NEW;
        END if;
END;
$body$
LANGUAGE plpgsql

CREATE OR REPLACE TRIGGER trg_person_insert_audit
AFTER INSERT ON person
FOR EACH ROW
EXECUTE PROCEDURE fnc_trg_person_insert_audit();

CALL part4_3(0);

CALL part4_4('RETURN NEW');