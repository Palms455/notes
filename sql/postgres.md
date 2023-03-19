# 1\. База данных, схемы, таблицы
Создаем базу данных:

=> CREATE DATABASE data\_logical;

CREATE DATABASE

=> \c data\_logical

You are now connected to database "data\_logical" as user "student".

Схемы:

=> CREATE SCHEMA student;

CREATE SCHEMA

=> CREATE SCHEMA app;

CREATE SCHEMA

Таблицы для схемы student:

=> CREATE TABLE a(s text);

CREATE TABLE

=> INSERT INTO a VALUES ('student');

INSERT 0 1

=> CREATE TABLE b(s text);

CREATE TABLE

=> INSERT INTO b VALUES ('student');

INSERT 0 1

Таблицы для схемы app:

=> CREATE TABLE app.a(s text);

CREATE TABLE

=> INSERT INTO app.a VALUES ('app');

INSERT 0 1

=> CREATE TABLE app.c(s text);

CREATE TABLE

=> INSERT INTO app.c VALUES ('app');

INSERT 0 1
# 2\. Описание схем и таблиц
Описание схем:

=> \dn

`  `List of schemas

`  `Name   |  Owner   

---------+----------

` `app     | student

` `public  | postgres

` `student | student

(3 rows)

Описание таблиц:

=> \dt student.\*

`        `List of relations

` `Schema  | Name | Type  |  Owner  

---------+------+-------+---------

` `student | a    | table | student

` `student | b    | table | student

(2 rows)

=> \dt app.\*

`        `List of relations

` `Schema | Name | Type  |  Owner  

--------+------+-------+---------

` `app    | a    | table | student

` `app    | c    | table | student

(2 rows)

# 3\. Путь поиска
С текущими настройками пути поиска видны таблицы только схемы student:

=> SELECT \* FROM a;

`    `s    

\---------

` `student

(1 row)

=> SELECT \* FROM b;

`    `s    

\---------

` `student

(1 row)

=> SELECT \* FROM c;

ERROR:  relation "c" does not exist

LINE 1: SELECT \* FROM c;

`                      `^

Изменим путь поиска.

=> ALTER DATABASE data\_logical SET search\_path = "$user",app,public;

ALTER DATABASE

=> \c

You are now connected to database "data\_logical" as user "student".

=> SHOW search\_path;

`     `search\_path      

\----------------------

` `"$user", app, public

(1 row)

Теперь видны таблицы из обоих схем, но приоритет остается за student:

=> SELECT \* FROM a;

`    `s    

\---------

` `student

(1 row)

=> SELECT \* FROM b;

`    `s    

\---------

` `student

(1 row)

=> SELECT \* FROM c;

`  `s  

\-----

` `app

(1 row)
# 1\. Табличные пространства и таблица
Создаем базу данных:

=> CREATE DATABASE data\_physical;

CREATE DATABASE

=> \c data\_physical

You are now connected to database "data\_physical" as user "student".

Табличное пространство:

postgres$ mkdir /var/lib/postgresql/ts\_dir

=> CREATE TABLESPACE ts LOCATION '/var/lib/postgresql/ts\_dir';

CREATE TABLESPACE

Создаем таблицу:

=> CREATE TABLE t(n integer) TABLESPACE ts;

CREATE TABLE

=> INSERT INTO t SELECT 1 FROM generate\_series(1,1000);

INSERT 0 1000
# 2\. Размер данных
Объем базы данных:

=> SELECT pg\_size\_pretty(pg\_database\_size('data\_physical')) AS db\_size;

` `db\_size 

\---------

` `8041 kB

(1 row)

Размер таблицы:

=> SELECT pg\_size\_pretty(pg\_total\_relation\_size('t')) AS t\_size;

` `t\_size 

\--------

` `64 kB

(1 row)

Объем табличных пространств:

=> SELECT

`    `pg\_size\_pretty(pg\_tablespace\_size('pg\_default')) AS pg\_default\_size,

`    `pg\_size\_pretty(pg\_tablespace\_size('ts')) AS ts\_size;

` `pg\_default\_size | ts\_size 

-----------------+---------

` `188 MB          | 68 kB

(1 row)

Размер табличного пространства несколько больше размера таблицы за счет служебных файлов, хранящихся в каталоге табличного пространства.
# 3\. Перенос таблицы
Перенесем таблицу:

=> ALTER TABLE t SET TABLESPACE pg\_default;

ALTER TABLE

Новый объем табличных пространств:

=> SELECT

`    `pg\_size\_pretty(pg\_tablespace\_size('pg\_default')) AS pg\_default\_size,

`    `pg\_size\_pretty(pg\_tablespace\_size('ts')) AS ts\_size;

` `pg\_default\_size |  ts\_size   

-----------------+------------

` `188 MB          | 4096 bytes

(1 row)

# 4\. Удаление табличного пространства
Удаляем табличное пространство:

=> DROP TABLESPACE ts;

DROP TABLESPACE
# Представления
Представление — запрос, у которого есть имя. Например, можно создать представление, которое показывает только авторов без отчества:

=> CREATE VIEW authors\_no\_surname AS

`    `SELECT author\_id, first\_name, last\_name

`    `FROM authors

`    `WHERE nullif(surname,'') IS NULL;

CREATE VIEW

Теперь имя представления можно использовать в запросах практически так же, как и таблицу:

=> SELECT \* FROM authors\_no\_surname;

` `author\_id | first\_name | last\_name 

-----------+------------+-----------

`         `6 | Джонатан   | Свифт

(1 row)

В простом случае с представлением будут работать и другие операции, например:

=> UPDATE authors\_no\_surname SET last\_name = initcap(last\_name);

UPDATE 1

С помощью триггеров можно сделать так, чтобы и в сложных случаях для представлений работали вставка, обновление и удаление строк. Мы рассмотрим это в теме «PL/pgSQL. Триггеры».

При планировании запроса представление «разворачивается» до базовых таблиц:

=> EXPLAIN (costs off) 

SELECT \* FROM authors\_no\_surname;

`                  `QUERY PLAN                   

\-----------------------------------------------

` `Seq Scan on authors

`   `Filter: (NULLIF(surname, ''::text) IS NULL)

(2 rows)


Приложение использует три представления. Сначала они будут очень простыми, но в следующих темах мы перенесем в них часть логики приложения.

Представление для авторов — конкатенация фамилии, имени и отчества (если оно есть):

=> SELECT \* FROM authors\_v;

` `author\_id |         display\_name         

-----------+------------------------------

`         `1 | Пушкин Александр Сергеевич

`         `2 | Тургенев Иван Сергеевич

`         `3 | Стругацкий Борис Натанович

`         `4 | Стругацкий Аркадий Натанович

`         `5 | Толстой Лев Николаевич

`         `6 | Свифт Джонатан

(6 rows)

Представление для каталога книг — пока просто название книги:

=> SELECT \* FROM catalog\_v;

` `book\_id |                                                                    display\_name                                                                    

---------+----------------------------------------------------------------------------------------------------------------------------------------------------

`       `1 | Сказка о царе Салтане

`       `2 | Муму

`       `3 | Трудно быть богом

`       `4 | Война и мир

`       `5 | Путешествия в некоторые удаленные страны мира в четырех частях: сочинение Лемюэля Гулливера, сначала хирурга, а затем капитана нескольких кораблей

`       `6 | Хрестоматия

(6 rows)

Представление для операций — дополнительно определяет тип операции (поступление или покупка):

=> SELECT \* FROM operations\_v;

` `book\_id |   op\_type   | qty\_change | date\_created 

---------+-------------+------------+--------------

`       `1 | Поступление |         10 | 09.12.2020

`       `1 | Поступление |         10 | 09.12.2020

`       `1 | Покупка     |          1 | 09.12.2020

(3 rows)





ФУНКЦИИ

Вот простой пример функции без параметров:

=> CREATE FUNCTION hello\_world() -- имя и пустой список параметров

RETURNS text                     -- тип возвращаемого значения

AS $$ SELECT 'Hello, world!'; $$ -- тело

LANGUAGE sql;                    -- указание языка

Тело удобно записывать в строке, заключенной в кавычки-доллары, как в приведенном примере. Иначе придется заботиться об экранировании кавычек, которые наверняка встретятся в теле функции 

При необходимости кавычки-доллары могут быть вложенными. Для этого в каждой паре кавычек надо использовать разный текст между долларами:

=> SELECT $func$ SELECT $$Hello, world!$$; $func$;

Функция вызывается в контексте выражения, например:

=> SELECT hello\_world(); -- пустые скобки обязательны

Не все операторы SQL можно использовать в функции. Запрещены:

- команды управления транзакциями (BEGIN, COMMIT, ROLLBACK и т. п.);
- служебные команды (такие, как VACUUM или CREATE INDEX).

# Функции с входными параметрами
Пример функции с одним параметром:

=> CREATE FUNCTION hello(name text) -- формальный параметр

RETURNS text AS $$

SELECT 'Hello, ' || name || '!';

$$ LANGUAGE sql;

При вызове функции мы указываем фактический параметр, соответствующий формальному:

=> SELECT hello('Alice');

При указании типа параметра можно указать и модификатор (например, varchar(10)), но он игнорируется.

Можно определить параметр функции без имени; тогда внутри тела функции на параметры придется ссылаться по номеру. Удалим функцию и создадим новую:

=> DROP FUNCTION hello(text); -- достаточно указать тип параметра

DROP FUNCTION

=> CREATE FUNCTION hello(text)

RETURNS text AS $$

SELECT 'Hello, ' || $1 || '!'; -- номер вместо имени

$$ LANGUAGE sql;

Здесь мы использовали необязательное ключевое слово IN, обозначающее входной параметр. Предложение DEFAULT позволяет определить значение по умолчанию для параметра:

=> CREATE FUNCTION hello(IN name text, IN title text DEFAULT 'Mr')

RETURNS text AS $$

SELECT 'Hello, ' || title || ' ' || name || '!';

$$ LANGUAGE sql;

SELECT hello('Alice', 'Mrs'); -- указаны оба параметра

`       `hello       

\-------------------

` `Hello, Mrs Alice!

(1 row)

Но если формальным параметрам даны имена, можно использовать их при указании фактических параметров. В этом случае параметры могут указываться в произвольном порядке:

=> SELECT hello(title => 'Mrs', name => 'Alice');

Можно совмещать оба способа: часть параметров (начиная с первого) указать  позиционно, а оставшиеся — по имени:

=> SELECT hello('Alice', title => 'Mrs');

Если функция должна возвращать неопределенное значение, если хотя бы один из входных параметров не определен, ее можно объявить как строгую (STRICT). Тело функции при этом вообще не будет выполняться. 

**=> CREATE FUNCTION hello(IN name text, IN title text DEFAULT 'Mr')**

**RETURNS text AS $$**

**SELECT 'Hello, ' || title || ' ' || name || '!';**

**$$ LANGUAGE sql STRICT;**

Входные значения

определяются параметрами с режимом IN и INOUT

Выходное значение

определяется либо предложением RETURNS,

либо параметрами с режимом INOUT и OUT

если одновременно указаны обе формы, они должны быть согласованы

Возвращаемое значение можно определить двумя способами:

\- использовать предложение RETURNS для указания типа;

\- определить выходные параметры с режимом INOUT или OUT.

Две эти формы записи эквивалентны. Например, функция с указанием 

RETURNS integer и функция с параметром OUT integer возвращают 

целое число

**CREATE FUNCTION hello(**

`    `**IN name text,**

`    `**OUT text -- имя можно не указывать, если оно не нужно**

**)**

**AS $$**

**SELECT 'Hello, ' || name || '!';**

**$$ LANGUAGE sql;**

Результат тот же самый.

Можно использовать и RETURNS, и OUT-параметр вместе — результат снова будет тем же:


**CREATE FUNCTION hello(IN name text, OUT text)**

**RETURNS text AS $$**

**SELECT 'Hello, ' || name || '!';**

**$$ LANGUAGE sql;**

Или даже так, использовав INOUT-параметр: 

**CREATE FUNCTION hello(INOUT name text)**

**AS $$**

**SELECT 'Hello, ' || name || '!';**

**$$ LANGUAGE sql;**

В то время как в RETURNS можно указать только одно значение, выходных параметров может быть несколько. Например: 

**CREATE FUNCTION hello(**

`    `**IN name text,**

`    `**OUT greeting text,**

`    `**OUT clock timetz)**

**AS $$**

**SELECT 'Hello, ' || name || '!', current\_time;**

**$$ LANGUAGE sql;**

**Категории изменчивости**

**Volatile**

возвращаемое значение может произвольно меняться

при одинаковых значениях входных параметров

используется по умолчанию

**Stable**

значение не меняется в пределах одного оператора SQL

функция не может менять состояние базы данных

**Immutable**

значение не меняется, функция детерминирована

функция не может менять состояние базы данных

Во-первых, функции с изменчивостью volatile на уровне изоляции Read Committed приводят к рассогласованию данных внутри одного запроса.

Сделаем функцию, возвращающую число строк в таблице:

**CREATE TABLE t(n integer);**

**CREATE FUNCTION cnt() RETURNS bigint**

**AS $$**

`    `**SELECT count(\*) FROM t;**

**$$ VOLATILE LANGUAGE sql;**

Теперь вызовем ее несколько раз с задержкой, а в параллельном сеансе вставим в таблицу строку.

**BEGIN ISOLATION LEVEL READ COMMITTED;**

BEGIN

=> SELECT (SELECT count(\*) FROM t), cnt(), pg\_sleep(1)

FROM generate\_series(1,4);

=> INSERT INTO t VALUES (1);

INSERT 0 1

` `count | cnt | pg\_sleep 

-------+-----+----------

`     `0 |   0 | 

`     `0 |   0 | 

`     `0 |   1 | 

`     `0 |   1 | 

(4 rows)

=> END;

COMMIT

При изменчивости stable или immutable, или либо использовании более строгих уровней изоляции, такого не происходит.

=> ALTER FUNCTION cnt() STABLE;

ALTER FUNCTION

=> TRUNCATE t;

TRUNCATE TABLE

=> BEGIN ISOLATION LEVEL READ COMMITTED;

BEGIN

=> SELECT (SELECT count(\*) FROM t), cnt(), pg\_sleep(1)

FROM generate\_series(1,4);

=> INSERT INTO t VALUES (1);

INSERT 0 1

` `count | cnt | pg\_sleep 

-------+-----+----------

`     `0 |   0 | 

`     `0 |   0 | 

`     `0 |   0 | 

`     `0 |   0 | 

(4 rows)

=> END;

COMMIT

Функции с изменчивостью volatile видят все изменения, в том числе сделанные текущим, еще не завершенным оператором SQL.

=> ALTER FUNCTION cnt() VOLATILE;

ALTER FUNCTION

=> TRUNCATE t;

TRUNCATE TABLE

=> INSERT INTO t SELECT cnt() FROM generate\_series(1,5);

INSERT 0 5

=> SELECT \* FROM t;

` `n 

\---

` `0

` `1

` `2

` `3

` `4

(5 rows)

Это верно для любых уровней изоляции.

Функции с изменчивостью stable или immutable видят изменения только уже завершенных операторов.

=> ALTER FUNCTION cnt() STABLE;

ALTER FUNCTION

=> TRUNCATE t;

TRUNCATE TABLE

=> INSERT INTO t SELECT cnt() FROM generate\_series(1,5);

INSERT 0 5

=> SELECT \* FROM t;

` `n 

\---

` `0

` `0

` `0

` `0

` `0

(5 rows)


**Категории изменчивости и оптимизация**

Благодаря дополнительной информации о поведении функции, которую дает указание категории изменчивости, оптимизатор может сэкономить на вызовах функции.

Для экспериментов создадим функцию, возвращающую случайное число:

=> CREATE FUNCTION rnd() RETURNS float

AS $$

`    `SELECT random();

$$ VOLATILE LANGUAGE sql;

SELECT \* FROM generate\_series(1,10) WHERE rnd() > 0.5;

` `generate\_series 

\-----------------

`               `2

`               `4

`               `6

`               `7

`               `8

`              `10

(6 rows)

Функция с изменчивостью stable будет вызвана всего один раз — поскольку мы фактически указали, что ее значение не может измениться в пределах оператора:

=> ALTER FUNCTION rnd() STABLE;

ALTER FUNCTION

=> EXPLAIN (costs off)

SELECT \* FROM generate\_series(1,10) WHERE rnd() > 0.5;

`                      `QUERY PLAN                      

\------------------------------------------------------

` `Result

`   `One-Time Filter: (rnd() > '0.5'::double precision)

`   `->  Function Scan on generate\_series

(3 rows)

Наконец, изменчивость immutable позволяет вычислить функции еще на этапе планирования, поэтому во время выполнения никакие фильтры не нужны:

=> ALTER FUNCTION rnd() IMMUTABLE;

ALTER FUNCTION

=> EXPLAIN (costs off)

SELECT \* FROM generate\_series(1,10) WHERE rnd() > 0.5;

`            `QUERY PLAN            

\----------------------------------

` `Function Scan on generate\_series

(1 row)

Ответственность «за дачу заведомо ложных показаний» лежит на разработчике.
# Подстановка тела функции в SQL-запрос
В некоторых (очень простых) случаях тело функции на языке SQL может быть подставлено прямо в основной SQL-оператор на этапе разбора запроса. В этом случае время на вызов функции не тратится.

Упрощенно требуется выполнение следующих условий:

- Тело функции состоит из одного оператора SELECT;
- Нет обращений к таблицам, отсутствуют подзапросы, группировки и т. п.;
- Возвращаемое значение должно быть одно;
- Вызываемые функции не должны противоречить указанной категории изменчивости.

Пример мы уже видели: наша функция rnd(), объявленная volatile.

Посмотрим еще раз.

=> ALTER FUNCTION rnd() VOLATILE;

ALTER FUNCTION

=> EXPLAIN (costs off)

SELECT \* FROM generate\_series(1,10) WHERE rnd() > 0.5;

**Функции**

вызываются в контексте выражения

не могут управлять транзакциями

возвращают результат

**Процедуры**

вызываются оператором CALL

могут управлять транзакциями

могут возвращать результат


Начнем с примера простой процедуры без параметров.

=> CREATE TABLE t(a float);

**CREATE PROCEDURE fill()**

**AS $$**

`    `**TRUNCATE t;**

`    `**INSERT INTO t SELECT random() FROM generate\_series(1,3);**

**$$ LANGUAGE sql;**

Чтобы вызвать подпрограмму, необходимо использовать специальный оператор: 

**CALL fill();**

Результат работы виден в таблице:

=> SELECT \* FROM t;

`          `a          

\---------------------

`  `0.2685976310134599

` `0.33821079330682124

`  `0.9238443843290334

(3 rows)


Тот же эффект можно получить и с помощью функции. Функция на языке SQL тоже может состоять из нескольких операторов (не обязательно SELECT); возвращаемое значение определяется последним оператором. Можно объявить тип результата void, если фактически функция ничего не возвращает, или вернуть что-то осмысленное:

=> CREATE FUNCTION fill\_avg() RETURNS float

AS $$

`    `TRUNCATE t;

`    `INSERT INTO t SELECT random() FROM generate\_series(1,3);

`    `SELECT avg(a) FROM t;

$$ LANGUAGE sql;

CREATE FUNCTION

В любом случае функция вызывается в контексте какого-либо выражения:

=> SELECT fill\_avg();

`      `fill\_avg       

\---------------------

` `0.17004812781735387

(1 row)

=> SELECT \* FROM t;

`          `a          

\---------------------

` `0.11659705326677283

` `0.12700793014354517

`  `0.2665394000417436

(3 rows)

Чего нельзя достичь с помощью функции — это управления транзакциями. Но и в процедурах на языке SQL это не поддерживается (зато поддерживается при использовании других языков).
# Процедуры с параметрами
Добавим в процедуру входной параметр — число строк:

**DROP PROCEDURE fill();**

**CREATE PROCEDURE fill(nrows integer)**

**AS $$**

`    `**TRUNCATE t;**

`    `**INSERT INTO t SELECT random() FROM generate\_series(1,nrows);**

**$$ LANGUAGE sql;**

Точно так же, как и в случае функций, при вызове процедур фактические параметры можно передавать позиционным способом или по имени: 

**CALL fill(nrows => 5);**

Процедуры могут также иметь INOUT-параметры, с помощью которых процедура может возвращать значение. OUT-параметры пока не поддерживаются (но будут в PostgreSQL 14). 

**DROP PROCEDURE fill(integer);**

**CREATE PROCEDURE fill(IN nrows integer, INOUT average float)**

**AS $$**

`    `**TRUNCATE t;**

`    `**INSERT INTO t SELECT random() FROM generate\_series(1,nrows);**

`    `**SELECT avg(a) FROM t; -- как в функции**

**$$ LANGUAGE sql;**

**Перегрузка** — это возможность использования одного и того же имени 

для нескольких подпрограмм (функций или процедур), отличающихся 

типами параметров IN и INOUT. Иными словами, сигнатура 

подпрограммы — ее имя и типы входных параметров.

При вызове подпрограммы PostgreSQL находит ту подпрограмму, 

которая соответствует переданным фактическим параметрам. 

Возможны ситуации, когда подходящую подпрограмму невозможно 

определить однозначно; в таком случае во время выполнения 

возникнет ошибка.

Перегрузку надо учитывать при использовании команды CREATE OR 

REPLACE (FUNCTION или PROCEDURE). Дело в том, что при 

несовпадении типов входных параметров будет создана новая — 

перегруженная — подпрограмма. Кроме того, для функций эта команда 

не позволяет изменить тип возвращаемого значения и типы выходных 

параметров.

Поэтому при необходимости следует удалять подпрограмму и 

создавать ее заново, но это будет уже новая подпрограмма. При 

удалении старой функции потребуется также удалить зависящие от нее 

представления, триггеры и т. п. (DROP FUNCTION ... CASCADE).

Полиморфизм

Подпрограмма, принимающая параметры разных типов

формальные параметры используют полиморфные псевдотипы

(например, anyelement)

конкретный тип данных выбирается во время выполнения

по типу фактических параметров
# Перегруженные подпрограммы
Перегрузка работает одинаково и для функций, и для процедур. Они имеют общее пространство имен.

В качестве примера напишем функцию, возвращающую большее из двух целых чисел. (Похожее выражение есть в SQL и называется greatest, но мы напишем собственную функцию.)

**CREATE FUNCTION maximum(a integer, b integer) RETURNS integer**

**AS $$**

`    `**SELECT CASE WHEN a > b THEN a ELSE b END;**

**$$ LANGUAGE sql;**

Допустим, мы решили сделать аналогичную функцию для трех чисел. Благодаря перегрузке, не надо придумывать для нее какое-то новое название: 

**CREATE FUNCTION maximum(a integer, b integer, c integer)**

**RETURNS integer**

**AS $$**

**SELECT CASE**

`        `**WHEN a > b THEN maximum(a,c)**

`        `**ELSE maximum(b,c)**

`    `**END;**

**$$ LANGUAGE sql;**

Теперь у нас две функции с одним именем, но разным числом параметров:

=> \df maximum

И обе работают: 

**SELECT maximum(10, 20), maximum(10, 20, 30);**

Команда CREATE OR REPLACE позволяет создать подпрограмму или заменить существующую, не удаляя ее. Поскольку в данном случае функция с такой сигнатурой уже существует, она будет заменена: 

**CREATE OR REPLACE FUNCTION maximum(a integer, b integer, c integer)**

**RETURNS integer**

**AS $$**

**SELECT CASE**

`        `**WHEN a > b THEN**

`            `**CASE WHEN a > c THEN a ELSE c END**

`        `**ELSE**

`            `**CASE WHEN b > c THEN b ELSE c END**

`    `**END;**

**$$ LANGUAGE sql;**

Пусть наша функция работает не только для целых чисел, но и для вещественных.

Как этого добиться? Можно было бы определить еще такую функцию:

**CREATE FUNCTION maximum(a real, b real) RETURNS real**

**AS $$**

`    `**SELECT CASE WHEN a > b THEN a ELSE b END;**

**$$ LANGUAGE sql;**

Теперь у нас три функции с одинаковым именем: 

\df maximum

`                              `List of functions

` `Schema |  Name   | Result data type |       Argument data types       | Type 

--------+---------+------------------+---------------------------------+------

` `public | maximum | integer          | a integer, b integer            | func

` `public | maximum | integer          | a integer, b integer, c integer | func

` `public | maximum | real             | a real, b real                  | func

(3 rows)

Но дальше нам придется определить функции для всех остальных типов данных, и повторить все то же самое для трех параметров. При том, что тело функции не меняется!
# Полиморфные функции
Здесь нам поможет полиморфный тип anyelement.

` `**CREATE FUNCTION maximum(a anyelement, b anyelement)**

**RETURNS anyelement**

**AS $$**

`    `**SELECT CASE WHEN a > b THEN a ELSE b END;**

**$$ LANGUAGE sql;**

Такая функция должна принимать любой тип данных (а работать будет с любым типом, для которого определен оператор «больше»).

Получится?

**SELECT maximum('A', 'B');**

Увы, нет. В данном случае строковые литералы могут быть типа char, varchar, text — конкретный тип нам неизвестен. Но можно применить явное приведение типов:** 

**SELECT maximum('A'::text, 'B'::text);**

Важно, чтобы типы обоих параметров совпадали, иначе будет ошибка

Определим теперь функцию с тремя параметрами, но так, чтобы третий можно было не указывать. 

CREATE FUNCTION maximum(

`    `**a anyelement,** 

`    `**b anyelement,** 

`    `**c anyelement DEFAULT NULL**

**) RETURNS anyelement** 

**AS $$**

**SELECT CASE**

`        `**WHEN c IS NULL THEN**

`            `**x**

`        `**ELSE**

`            `**CASE WHEN x > c THEN x ELSE c END**

`    `**END**

**FROM (**

`    `**SELECT CASE WHEN a > b THEN a ELSE b END**

**) max2(x);**

**$$ LANGUAGE sql;**

Попробуем:

=> SELECT maximum(10, 20, 30);

` `maximum 

\---------

`      `30

(1 row)

Так работает. А так?

=> SELECT maximum(10, 20);

ERROR:  function maximum(integer, integer) is not unique

LINE 1: SELECT maximum(10, 20);

`               `^

HINT:  Could not choose a best candidate function. You might need to add explicit type casts.

А так произошел конфликт перегруженных функций:

=> \df maximum

`                                              `List of functions

` `Schema |  Name   | Result data type |                      Argument data types                       | Type 

--------+---------+------------------+----------------------------------------------------------------+------

` `public | maximum | anyelement       | a anyelement, b anyelement                                     | func

` `public | maximum | anyelement       | a anyelement, b anyelement, c anyelement DEFAULT NULL::unknown | func

(2 rows)

Невозможно понять, имеем ли мы в виду функцию с двумя параметрами, или с тремя (но просто не указали последний).

Мы решим этот конфликт просто — удалим первую функцию за ненадобностью.

**DROP FUNCTION maximum(anyelement, anyelement);**






# 1\. Устранение дубликатов
В целях проверки добавим второго Пушкина:

=> INSERT INTO authors(last\_name, first\_name, surname)

`    `VALUES ('Пушкин', 'Александр', 'Сергеевич');

INSERT 0 1

=> SELECT last\_name, first\_name, surname, count(\*)

FROM authors

GROUP BY last\_name, first\_name, surname;

` `last\_name  | first\_name |  surname   | count 

------------+------------+------------+-------

` `Свифт      | Джонатан   |            |     1

` `Стругацкий | Борис      | Натанович  |     1

` `Пушкин     | Александр  | Сергеевич  |     2

` `Стругацкий | Аркадий    | Натанович  |     1

` `Толстой    | Лев        | Николаевич |     1

` `Тургенев   | Иван       | Сергеевич  |     1

(6 rows)

Задачу устранения дубликатов можно решить разными способами. Например, так:

=> CREATE PROCEDURE authors\_dedup()

AS $$

DELETE FROM authors

WHERE author\_id IN (

`    `SELECT author\_id

`    `FROM (

`        `SELECT author\_id,

`               `row\_number() OVER (

`                   `PARTITION BY first\_name, last\_name, surname

`                   `ORDER BY author\_id

`               `) AS rn

`        `FROM authors

`    `) t

`    `WHERE t.rn > 1

);

$$ LANGUAGE sql;

CREATE PROCEDURE

=> CALL authors\_dedup();







**Составной тип** это набор атрибутов, каждый из которых имеет свое 

имя и свой тип. Составной тип можно рассматривать как табличную 

строку. Часто он называется «записью» (а в Си-подобных языках такой 

тип называется «структурой»).

Составной тип — объект базы данных, его объявление регистрирует 

новый тип в системном каталоге, после чего он становится 

полноценным типом SQL. При создании таблицы автоматически 

создается и одноименный составной тип, представляющий строку этой 

таблицы. Важное отличие состоит в том, что в составном типе нет 

ограничений целостности.

Составной тип можно использовать как любой другой тип SQL,  например, создавать столбцы таблиц этого типа и т. п. Значения составного типа можно сравнивать между собой, проверять на 

неопределенность (NULL), использовать с подзапросами в таких  конструкциях, как 
# Явное объявление составного типа
Первый способ ввести составной тип — явным образом объявить его.

**CREATE TYPE currency AS (**

`    `**amount numeric,**

`    `**code   text**

**);**

\dT

`       `List of data types

` `Schema |   Name   | Description 

--------+----------+-------------

` `public | currency | 

Такой тип можно использовать точно так же, как любой другой тип SQL. Например, мы можем создать таблицу со столбцами такого типа:

**=> CREATE TABLE transactions(**

`    `**account\_id   integer,**

`    `**debit        currency,**

`    `**credit       currency,**

`    `**date\_entered date DEFAULT current\_date**

**);**

Значения составного типа можно формировать в виде строки, внутри которой в скобках перечислены значения. Обратите внимание, что строковые значения заключается в двойные кавычки:

=> INSERT INTO transactions VALUES (1, NULL, '(100.00,"RUR")');

Другой способ — табличный конструктор ROW:

=> INSERT INTO transactions VALUES (2, ROW(80.00,'RUR'), NULL);

Если составной тип содержит более одного поля, то слово ROW можно опустить:

=> INSERT INTO transactions VALUES (3, (20.00,'RUR'), NULL);

SELECT \* FROM transactions;

` `account\_id |    debit    |    credit    | date\_entered 

------------+-------------+--------------+--------------

`          `1 |             | (100.00,RUR) | 2020-12-09

`          `2 | (80.00,RUR) |              | 2020-12-09

`          `3 | (20.00,RUR) |              | 2020-12-09

Обращение к отдельному атрибуту составного типа — по сути то же, что и обращению к столбцу таблицы, ведь строка таблицы — это и есть составной тип:

=> SELECT t.account\_id FROM transactions t;

` `account\_id 

\------------

`          `1

`          `2

`          `3

В некоторых случаях требуется брать составное значение в скобки, например, чтобы отличать атрибут записи от столбца таблицы:

=> SELECT (t.debit).amount, (t.credit).amount FROM transactions t;

` `amount | amount 

--------+--------

`        `| 100.00

`  `80.00 |       

`  `20.00 |       

(3 rows)

Или в случае, когда используется выражение:

=> SELECT ((10.00,'RUR')::currency).amount;

` `amount 

\--------

`  `10.00

(1 row)

Составное значение не обязательно связано с каким-то конкретным типом, оно может быть неопределенной записью псевдотипа record:

=> SELECT (10.00,'RUR')::record;

Но получится ли обратиться к атрибуту такой записи?

=> SELECT ((10.00,'RUR')::record).amount;

ERROR:  could not identify column "amount" in record data type

LINE 1: SELECT ((10.00,'RUR')::record).amount;

`                `^

Нет, поскольку атрибуты такого типа безымянные.





# **Неявный составной тип для таблиц**
Более частое на практике применение составных типов — упрощение работы функций с таблицами.

При создании таблицы неявно создается и одноименный составной тип. Например, места в кинотеатре:

=> CREATE TABLE seats(

`    `line text,

`    `number integer

);

CREATE TABLE

=> INSERT INTO seats VALUES

`    `('A', 42), ('B',  1), ('C', 27);

INSERT 0 3

Команда \dT «прячет» такие неявные типы, но при желании их можно увидеть непосредственно в таблице pg\_type:

=> SELECT typtype FROM pg\_type WHERE typname = 'seats';

` `typtype 

\---------

` `c

(1 row)

Значения составных типов можно сравнивать между собой. Это происходит поэлементно (примерно так же, так строки сравниваются посимвольно):

=> SELECT \* FROM seats s WHERE s < ('B',52)::seats;

Также работает проверка на неопределенность IS [NOT] NULL и сравнение IS [NOT] DISTINCT FROM.

Составные типы можно использовать с подзапросами, что бывает очень удобно.

Добавим таблицу с билетами:

=> CREATE TABLE tickets(

`    `line text,

`    `number integer,

`    `movie\_start date

);

CREATE TABLE

=> INSERT INTO tickets VALUES

`    `('A', 42, current\_date),

`    `('B',  1, current\_date+1);

INSERT 0 2

Теперь, например, можно написать такой запрос для поиска мест в билетах на сегодняшний сеанс:

=> SELECT \* FROM seats WHERE (line, number) IN (

`    `SELECT line, number FROM tickets WHERE movie\_start = current\_date

);

**Параметры функций**

Функция может принимать параметры составного типа

Способ реализации вычисляемых полей

взаимозаменяемость table.column и column(table)

Другие способы

представления

столбцы GENERATED ALWAYS

Разумеется, функции могут принимать параметры составных типов.

Интересно, что для доступа к столбцу таблицы можно использовать не 

только привычную форму «таблица.столбец», но и функциональную: 

«столбец(таблица)». Это позволяет создавать вычислимые поля, 

определяя функцию, принимающую на вход составной тип.

Это несколько курьезный способ, поскольку того же результата можно 

добиться более явно с помощью представления. Стандарт SQL также 

предусматривает генерируемые (GENERATED ALWAYS) столбцы, хотя 

в PostgreSQL эта возможность пока реализована не в соответствии

со стандартом — столбцы не вычисляются на лету, а сохраняются

в таблице
# **Параметры составного типа**
Определим функцию, принимающую значение составного типа и возвращающую текстовый номер места.

=> CREATE FUNCTION seat\_no(seat seats) RETURNS text

AS $$

`    `SELECT seat.line || seat.number;

$$ IMMUTABLE LANGUAGE sql;

Обратите внимание, что в общем случае конкатенация имеет категорию изменчивости stable, а не immutable, поскольку для некоторых типов данных приведение к строке может давать разные результаты в зависимости от настроек.

=> SELECT seat\_no(ROW('A',42));

` `seat\_no 

\---------

` `A42

(1 row)


**Что удобно, такой функции можно передавать непосредственно строку таблицы:**

=> SELECT s.line, s.number, seat\_no(s.\*) FROM seats s;

**Можно обойтись и без «звездочки»:**

=> SELECT s.line, s.number, seat\_no(s) FROM seats s;

**Синтаксисом допускается обращение к функции как к столбцу таблицы (и наоборот, к столбцу как к функции):**

=> SELECT s.line, number(s), s.seat\_no FROM seats s;

Таким образом можно использовать функции как вычисляемые «на лету» столбцы таблиц.

Что, если и в таблице окажется столбец с тем же именем? Раньше в любом случае предпочтение отдавалось столбцу, а начиная с версии 11 выбор зависит от синтаксической формы.

Разумеется, такого же эффекта можно добиться, определив представление.

=> CREATE VIEW seats\_v AS

`    `SELECT s.line, s.number, seat\_no(s) FROM seats s;

CREATE VIEW

=> SELECT line, number, seat\_no FROM seats\_v;

А начиная с версии 12, PostgreSQL позволяет при создании таблиц объявить «настоящие» вычисляемые столбцы. Правда, в отличие от стандарта SQL, такие столбцы не вычисляются на лету, а сохраняются в таблице:

=> CREATE TABLE seats2(

`    `line text,

`    `number integer,

`    `seat\_no text GENERATED ALWAYS AS (seat\_no(ROW(line,number))) STORED

);

CREATE TABLE

=> INSERT INTO seats2 (line, number)

`    `SELECT line, number FROM seats;

INSERT 0 3

=> SELECT \* FROM seats2;

` `line | number | seat\_no 

------+--------+---------

` `A    |     42 | A42

` `B    |      1 | B1

` `C    |     27 | C27

**Однострочные функции**

Возвращают значение составного типа

Обычно вызываются в списке выборки запроса

При вызове в предложении FROM возвращают однострочную таблицу

Обычно функции вызываются в списке выборки запроса (предложение SELECT).

Но функцию можно вызвать и в предложении FROM, как будто таблицу из одной строки.
# **Функции, возвращающие одно значение**
Напишем функцию, конструирующую и возвращающую табличную строку по отдельным компонентам.

Такую функцию можно объявить как RETURNS seats:

=> CREATE FUNCTION seat(line text, number integer) RETURNS seats

AS $$

`    `SELECT ROW(line, number)::seats;

$$ IMMUTABLE LANGUAGE sql;

CREATE FUNCTION

=> SELECT seat('A', 42);

`  `seat  

\--------

` `(A,42)

Мы получаем результат составного типа. Его можно «развернуть» в однострочную таблицу:

=> SELECT (seat('A', 42)).\*;

` `line | number 

------+--------

` `A    |     42

Имена столбцов и их типы получены здесь из описания составного типа seats.

Но функцию можно вызывать не только в списке выборки запроса или в условиях, как часть выражения. К функции можно обратиться и в предложении FROM, как к таблице:

=> SELECT \* FROM seat('A', 42);

` `line | number 

------+--------

` `A    |     42

(При этом мы тоже получаем однострочную таблицу.

Кстати, можно ли подобным образом вызвать функцию, возвращающую скалярное значение?

=> SELECT \* FROM abs(-1.5);

` `abs 

\-----

` `1.5

Да, так тоже можно.

Другой вариант, который мы уже видели в теме «SQL. Функции» — объявить выходные параметры.

Заодно отметим, что в запросе не обязательно собирать составной тип из отдельных полей — это будет проделано автоматически:

**CREATE FUNCTION seat(line INOUT text, number INOUT integer)**

**AS $$**

`    `**SELECT line, number;**

**$$ IMMUTABLE LANGUAGE sql;**

SELECT \* FROM seat('A', 42);

` `line | number 

------+--------

` `A    |     42

Получаем тот же результат — но имена и типы полей в данном случае получены из выходных параметров функции, а сам составной тип остается анонимным.

И еще один вариант — объявить функцию как возвращающую псевдотип record, который обозначает составной тип «вообще», без уточнения его структуры.

CREATE FUNCTION seat(line text, number integer) RETURNS record

AS $$

`    `SELECT line, number;

$$ IMMUTABLE LANGUAGE sql

=> SELECT seat('A',42);

`  `seat  

\--------

` `(A,42)

(Но вызвать такую функцию в предложении FROM уже не получится, поскольку возвращаемый составной тип не просто анонимный, но и количество и типы его полей заранее (на этапе разбора запроса) неизвестны:

=> SELECT \* FROM seat('A',42);

ERROR:  a column definition list is required for functions returning "record"

LINE 1: SELECT \* FROM seat('A',42);

В этом случае при вызове функции структуру составного типа придется уточнить:

=> SELECT \* FROM seat('A',42) AS seats(line text, number integer);

` `line | number 

------+--------

` `A    |     42

(1 row)

При написании функций допустим любой из этих трех вариантов, но лучше сразу подумать об использовании: будет ли удобен анонимный тип и уточнение структуры типа при вызове.

**ТАБЛИЧНЫЕ ФУНКЦИИ**

Объявляются как RETURNS SETOF или RETURNS TABLE

Могут возвращать несколько строк

Обычно вызываются в предложении FROM

Можно использовать как представление с параметрами
# Функции, возвращающие множество строк (табличные функции)
Напишем функцию, которая вернет все места в прямоугольном зале заданного размера.

=> CREATE FUNCTION rect\_hall(max\_line integer, max\_number integer)

RETURNS SETOF seats

AS $$

`    `SELECT chr(line+64), number

`    `FROM generate\_series(1,max\_line) AS lines(line),

`         `generate\_series(1,max\_number) AS numbers(number);

$$ IMMUTABLE LANGUAGE sql;

ELECT \* FROM rect\_hall(max\_line => 2, max\_number => 3);

` `line | number 

------+--------

` `A    |      1

` `A    |      2

` `A    |      3

` `B    |      1

` `B    |      2

` `B    |      3

Вместо SETOF seats можно использовать и SETOF record: 

**CREATE FUNCTION rect\_hall(max\_line integer, max\_number integer)**

**RETURNS SETOF record**

**AS $$**

`    `**SELECT chr(line+64), number**

`    `**FROM generate\_series(1,max\_line) AS lines(line),** 

`         `**generate\_series(1,max\_number) AS numbers(number);**

**$$ IMMUTABLE LANGUAGE sql;**

Но в этом случае, как мы видели, при вызове функции придется уточнять структуру составного типа: 

SELECT \* FROM rect\_hall(max\_line => 2, max\_number => 3)

`    `AS seats(line text, number integer);

А можно объявить функцию с выходными параметрами. Но SETOF record все равно придется написать, чтобы показать, что функция возвращает не одну строку, а множество: 

**CREATE FUNCTION rect\_hall(**

`    `**max\_line integer, max\_number integer,**

`    `**OUT line text, OUT number integer**

**)**

**RETURNS SETOF record**

**AS $$**

`    `**SELECT chr(line+64), number**

`    `**FROM generate\_series(1,max\_line) AS lines(line),** 

`         `**generate\_series(1,max\_number) AS numbers(number);**

**$$ IMMUTABLE LANGUAGE sql;**

**SELECT \* FROM rect\_hall(max\_line => 2, max\_number => 3);**

Еще один равнозначный (и к тому же описанный в стандарте SQL) способ объявить табличную функцию — указать слово TABLE: 

**CREATE FUNCTION rect\_hall(max\_line integer, max\_number integer)**

**RETURNS TABLE(line text, number integer)**

**AS $$**

`    `**SELECT chr(line+64), number**

`    `**FROM generate\_series(1,max\_line) AS lines(line),** 

`         `**generate\_series(1,max\_number) AS numbers(number);**

**$$ LANGUAGE sql;**

Иногда в запросах бывает полезно пронумеровать строки в том порядке, в котором они получены от функции. Для этого есть специальная конструкция:

=> SELECT \*

FROM rect\_hall(max\_line => 2, max\_number => 3) WITH ORDINALITY;

` `line | number | ordinality 

------+--------+------------

` `A    |      1 |          1

` `A    |      2 |          2

` `A    |      3 |          3

` `B    |      1 |          4

` `B    |      2 |          5

` `B    |      3 |          6

(6 rows)

При использовании функции в предложении FROM, перед ней неявно подразумевается ключевое слово LATERAL, что позволяет функции обращаться к столбцам таблиц, стоящих в запросе слева от нее. Иногда это позволяет упростить формулировку запросов.





Например, напишем функцию, конструирующую зал наподобие амфитеатра, в котором дальние ряды имеют больше мест, чем ближние:

**CREATE FUNCTION amphitheatre(max\_line integer)**

**RETURNS TABLE(line text, number integer)**

**AS $$**

`    `**SELECT chr(line+64), number**

`    `**FROM generate\_series(1,max\_line) AS lines(line), -- <--+**

`         `**generate\_series(1, --                             |**

`                         `**line -----------------------------+**

`                        `**) AS numbers(number);**

**$$ IMMUTABLE LANGUAGE sql;**
# Функции как представления с параметрами
Как мы видели, функцию можно использовать во фразе FROM, как таблицу или представление. Но при этом мы дополнительно получаем возможность использовать параметры, что в ряде случаев бывает удобно.

Единственная сложность с таким подходом состоит в том, что при обращении к функции (Function Scan) запросы из нее сначала выполняются полностью, и только затем к результату применяются дополнительные условия из запроса.

=> EXPLAIN (costs off)

SELECT \* FROM rect\_hall(3,4) WHERE line = 'A';

Если бы функция содержала сложный, долгий запрос, это могло бы стать проблемой.

В некоторых случаях тело функции может подставляться в вызывающий запрос. Для табличных функций ограничения более мягкие:

- функция написана на языке SQL;
- функция сама не должна быть изменчивой (VOLATILE) и не должна содержать вызовов таких функций;
- функция не должна быть строгой (STRICT);
- тело должно содержать единственный оператор SELECT (но он может быть сложным);
- и ряд других ограничений.

В нашем случае дело в том, что последний раз мы объявили функцию как изменчивую, не указав категорию изменчивости явно.

=> ALTER FUNCTION rect\_hall(integer, integer) IMMUTABLE;









**PL/pgSQL**
# **Анонимные блоки**
Общая структура блока PL/pgSQL:

<<метка>>

DECLARE

`    `-- объявления переменных

BEGIN

`    `-- операторы

EXCEPTION

`    `-- обработка ошибок

END метка;

- Все секции, кроме операторов, являются необязательными.

Минимальный блок PL/pgSQL-кода:

=> DO $$

BEGIN

`    `-- сами операторы могут и отсутствовать

END;

$$;

Вариант программы Hello, World!

=> DO $$

DECLARE

`    `-- Это однострочный комментарий.

`    `/\* А это — многострочный.

`       `После каждого объявления ставится знак ';'.

`       `Этот же знак ставится после каждого оператора.

`    `\*/

`    `foo text;

`    `bar text := 'World'; -- также допускается = или DEFAULT

BEGIN

`    `foo := 'Hello'; -- это присваивание

`    `RAISE NOTICE '%, %!', foo, bar; -- вывод сообщения

END;

$$;

NOTICE:  Hello, World!

DO

- После BEGIN точка с запятой не ставится!

Переменные могут иметь модификаторы:

- CONSTANT — значение переменной не должно изменяться после инициализации;
- NOT NULL — не допускается неопределенное значение.

Пример вложенных блоков. Переменная во внутреннем блоке перекрывает переменную из внешнего блока, но с помощью меток можно обратиться к любой из них:


=> DO $$

<<outer\_block>>

DECLARE

`    `foo text := 'Hello';

BEGIN

`    `<<inner\_block>>

`    `DECLARE

`        `foo text := 'World';

`    `BEGIN

`        `RAISE NOTICE '%, %!', outer\_block.foo, inner\_block.foo;

`        `RAISE NOTICE 'Без метки — внутренняя переменная: %', foo;

`    `END inner\_block;

END outer\_block;

$$;

**Если в SQL подпрограмма возвращала значение, выданное последним  SQL-оператором, то в подпрограммах на PL/pgSQL требуется либо присваивать возвращаемые значения формальным INOUT- и OUT- параметрам, либо (для функций) использовать специальный оператор** 

**RETURN**
# **Подпрограммы PL/pgSQL**
**Пример функции, возвращающей значение с помощью оператора RETURN:**

**=> CREATE FUNCTION sqr\_in(IN a numeric) RETURNS numeric**

**AS $$**

**BEGIN**

`    `**RETURN a \* a;**

**END;**

**$$ LANGUAGE plpgsql IMMUTABLE;**

**CREATE FUNCTION**

**Та же функция, но с OUT-параметром. Возвращаемое значение присваивается параметру:**

**=> CREATE FUNCTION sqr\_out(IN a numeric, OUT retval numeric)**

**AS $$**

**BEGIN**

`    `**retval := a \* a;**

**END;**

**$$ LANGUAGE plpgsql IMMUTABLE;**

**CREATE FUNCTION**

**Та же функция, но с INOUT-параметром. Такой параметр используется и для принятия входного значения, и для возврата значения функции:**

**=> CREATE FUNCTION sqr\_inout(INOUT a numeric)**

**AS $$**

**BEGIN**

`    `**a := a \* a;**

**END;**

**$$ LANGUAGE plpgsql IMMUTABLE;**

**CREATE FUNCTION**

**=> SELECT sqr\_in(3), sqr\_out(3), sqr\_inout(3);**

` `**sqr\_in | sqr\_out | sqr\_inout** 

**--------+---------+-----------**

`      `**9 |       9 |         9**

**(1 row)**


**Условные операторы**

Общий вид оператора IF:

IF условие THEN

`    `-- операторы

ELSIF условие THEN

`    `-- операторы

ELSE

`    `-- операторы

END IF;

- Секция ELSIF может повторяться несколько раз, а может отсутствовать.
- Секция ELSE может отсутствовать.
- Выполняются операторы, соответствующие первому истинному условию.
- Если ни одно из условий не истинно, выполняются операторы ELSE (если есть).

Пример функции, использующей условный оператор для форматирования номера телефона. Функция возвращает два значения:

=> CREATE FUNCTION fmt (IN phone text, OUT code text, OUT num text)

AS $$

BEGIN

`    `IF phone ~ '^[0-9]\*$' AND length(phone) = 10 THEN

`        `code := substr(phone,1,3);

`        `num  := substr(phone,4);

`    `ELSE

`        `code := NULL;

`        `num  := NULL;

`    `END IF;

END;

$$ LANGUAGE plpgsql IMMUTABLE;

**Общий вид оператора CASE (первый вариант — по условию):**

CASE

`    `WHEN условие THEN

`        `-- операторы

`    `ELSE

`        `-- операторы

END CASE;

- Секция WHEN может повторяться несколько раз.
- Секция ELSE может отсутствовать.
- Выполняются операторы, соответствующие первому истинному условию.
- Если ни одно из условий не истинно, выполняются операторы ELSE (отсутствие ELSE в таком случае — ошибка).

Пример использования:

=> DO $$

DECLARE

`    `code text := (fmt('8122128506')).code;

BEGIN

`    `CASE

`        `WHEN code IN ('495','499') THEN

`            `RAISE NOTICE '% — Москва', code;

`        `WHEN code = '812' THEN

`            `RAISE NOTICE '% — Санкт-Петербург', code;

`        `WHEN code = '384' THEN

`            `RAISE NOTICE '% — Кемеровская область', code;

`        `ELSE

`            `RAISE NOTICE '% — Прочие', code;

`    `END CASE;

END;

$$;

**Общий вид оператора CASE (второй вариант — по выражению):**

CASE выражение

`    `WHEN значение, ... THEN

`        `-- операторы

`    `ELSE

`        `-- операторы

END CASE;

- Секция WHEN может повторяться несколько раз.
- Секция ELSE может отсутствовать.
- Выполняются операторы, соответствующие первому истинному условию «выражение = значение».
- Если ни одно из условий не истинно, выполняются операторы ELSE (отсутствие ELSE в таком случае — ошибка).

При однотипных условиях эта форма CASE может оказаться компактней:

=> DO $$

DECLARE

`    `code text := (fmt('8122128506')).code;

BEGIN

`    `CASE code

`        `WHEN '495', '499' THEN

`            `RAISE NOTICE '% — Москва', code;

`        `WHEN '812' THEN

`            `RAISE NOTICE '% — Санкт-Петербург', code;

`        `WHEN '384' THEN

`            `RAISE NOTICE '% — Кемеровская область', code;

`        `ELSE

`            `RAISE NOTICE '% — Прочие', code;

`    `END CASE;

END;

$$;


# **Циклы**
В PL/pgSQL все циклы используют общую конструкцию:

LOOP

`    `-- операторы

END LOOP;

К ней может добавляться заголовок, определяющий условие выхода из цикла.

Цикл по диапазону FOR повторяется, пока счетчик цикла пробегает значения от нижней границы до верхней. С каждой итерацией счетчик увеличивается на 1 (но инкремент можно изменить в необязательной фразе BY).

FOR имя IN низ .. верх BY инкремент

LOOP

`    `-- операторы

END LOOP;

- Переменная, выступающая счетчиком цикла, объявляется неявно и существует только внутри блока LOOP — END LOOP.

При указании REVERSE значение счетчика на каждой итерации уменьшается, а нижнюю и верхнюю границы цикла нужно поменять местами:

FOR имя IN REVERSE верх .. низ BY инкремент

LOOP

`    `-- операторы

END LOOP;

Пример использования цикла FOR — функция, переворачивающая строку:

=> CREATE FUNCTION reverse\_for (line text) RETURNS text

AS $$

DECLARE

`    `line\_length CONSTANT int := length(line);

`    `retval text := '';

BEGIN

`    `FOR i IN 1 .. line\_length

`    `LOOP

`        `retval := substr(line, i, 1) || retval;

`    `END LOOP;

`    `RETURN retval;

END;

$$ LANGUAGE plpgsql IMMUTABLE STRICT;

CREATE FUNCTION

Напомним, что строгая (STRICT) функция немедленно возвращает NULL, если хотя бы один из входных параметров не определен. Тело функции при этом не выполняется.


Цикл WHILE выполняется до тех пор, пока истинно условие:

WHILE условие

LOOP

`    `-- операторы

END LOOP;

Та же функция, обращающая строку, с помощью цикла WHILE:

=> CREATE FUNCTION reverse\_while (line text) RETURNS text

AS $$

DECLARE

`    `line\_length CONSTANT int := length(line);

`    `i int := 1;

`    `retval text := '';

BEGIN

`    `WHILE i <= line\_length

`    `LOOP

`        `retval := substr(line, i, 1) || retval;

`        `i := i + 1;

`    `END LOOP;

`    `RETURN retval;

END;

$$ LANGUAGE plpgsql IMMUTABLE STRICT;

CREATE FUNCTION

Цикл LOOP без заголовка выполняется бесконечно. Для выхода используется оператор EXIT:

EXIT метка WHEN условие;

- Метка необязательна; если не указана, будет прерван самый вложенный цикл.
- Фраза WHEN также необязательна; при отсутствии цикл прерывается безусловно.

Пример использования цикла LOOP:

=> CREATE FUNCTION reverse\_loop (line text) RETURNS text

AS $$

DECLARE

`    `line\_length CONSTANT int := length(reverse\_loop.line);

`    `i int := 1;

`    `retval text := '';

BEGIN

`    `<<main\_loop>>

`    `LOOP

`        `EXIT main\_loop WHEN i > line\_length;

`        `retval := substr(reverse\_loop.line, i,1) || retval;

`        `i := i + 1;

`    `END LOOP;

`    `RETURN retval;

END;

$$ LANGUAGE plpgsql IMMUTABLE STRICT;

CREATE FUNCTION

- Тело функции помещается в неявный блок, метка которого совпадает с именем функции. Поэтому к параметрам можно обращаться как «имя\_функции.параметр».

Убедимся что все функции работают правильно:

=> SELECT reverse\_for('главрыба') as "for",

`          `reverse\_while('главрыба') as "while",

`          `reverse\_loop('главрыба') as "loop";

`   `for    |  while   |   loop   

----------+----------+----------

` `абырвалг | абырвалг | абырвалг

(1 row)

Замечание. В PostgreSQL есть встроенная функция reverse.

Иногда бывает полезен оператор CONTINUE, начинающий новую итерацию цикла:

=> DO $$

DECLARE

`    `s integer := 0;

BEGIN

`    `FOR i IN 1 .. 100

`    `LOOP

`        `s := s + i;

`        `CONTINUE WHEN mod(i, 10) != 0;

`        `RAISE NOTICE 'i = %, s = %', i, s;

`    `END LOOP;

END;

$$;

Другой вариант FOR позволяет организовать цикл по результатам запроса. Синтаксис:

[ <<***метка***>> ]

FOR ***цель*** IN ***запрос*** LOOP

`    `***операторы***

END LOOP [ ***метка*** ];

Переменная ***цель*** может быть строковой переменной, переменной типа record или разделённым запятыми списком скалярных переменных. Переменной ***цель*** последовательно присваиваются строки результата запроса, и для каждой строки выполняется тело цикла. Пример:

CREATE FUNCTION refresh\_mviews() RETURNS integer AS $$

DECLARE

`    `mviews RECORD;

BEGIN

`    `RAISE NOTICE 'Refreshing all materialized views...';

`    `FOR mviews IN

`       `SELECT n.nspname AS mv\_schema,

`              `c.relname AS mv\_name,

`              `pg\_catalog.pg\_get\_userbyid(c.relowner) AS owner

`         `FROM pg\_catalog.pg\_class c

`    `LEFT JOIN pg\_catalog.pg\_namespace n ON (n.oid = c.relnamespace)

`        `WHERE c.relkind = 'm'

`     `ORDER BY 1

`    `LOOP

`        `-- Здесь "mviews" содержит одну запись с информацией о матпредставлении

`        `RAISE NOTICE 'Refreshing materialized view %.% (owner: %)...',

`                     `quote\_ident(mviews.mv\_schema),

`                     `quote\_ident(mviews.mv\_name),

`                     `quote\_ident(mviews.owner);

`        `EXECUTE format('REFRESH MATERIALIZED VIEW %I.%I', mviews.mv\_schema, mviews.mv\_name);

`    `END LOOP;

`    `RAISE NOTICE 'Done refreshing materialized views.';

`    `RETURN 1;

END;

$$ LANGUAGE plpgsql;

Если цикл завершается по команде EXIT, то последняя присвоенная строка доступна и после цикла.

В качестве ***запроса*** в этом типе оператора FOR может задаваться любая команда SQL, возвращающая строки. Чаще всего это SELECT, но также можно использовать и INSERT, UPDATE или DELETE с предложением RETURNING. Кроме того, возможно применение и некоторых служебных команд, например EXPLAIN.

### **Цикл по элементам массива**

Цикл FOREACH очень похож на FOR. Отличие в том, что вместо перебора строк SQL-запроса происходит перебор элементов массива. (В целом, FOREACH предназначен для перебора выражений составного типа. Варианты реализации цикла для работы с прочими составными выражениями помимо массивов могут быть добавлены в будущем.) Синтаксис цикла FOREACH:

[ <<***метка***>> ]

FOREACH ***цель*** [ SLICE ***число*** ] IN ARRAY ***выражение*** LOOP

`    `***операторы***

END LOOP [ ***метка*** ];

Без указания SLICE, или если SLICE равен 0, цикл выполняется по всем элементам массива, полученного из ***выражения***. Переменной ***цель*** последовательно присваивается каждый элемент массива и для него выполняется тело цикла. Пример цикла по элементам целочисленного массива:

CREATE FUNCTION sum(int[]) RETURNS int8 AS $$

DECLARE

`  `s int8 := 0;

`  `x int;

BEGIN

`  `FOREACH x IN ARRAY $1

`  `LOOP

`    `s := s + x;

`  `END LOOP;

`  `RETURN s;

END;

$$ LANGUAGE plpgsql;






# **Команды, не возвращающие результат**
Если результат запроса не нужен, заменяем SELECT на PERFORM:

=> CREATE FUNCTION do\_something() RETURNS void

AS $$

BEGIN

`    `RAISE NOTICE 'Что-то сделалось.';

END;

$$ LANGUAGE plpgsql;

CREATE FUNCTION

=> DO $$

BEGIN

`    `PERFORM do\_something();

END;

$$;

NOTICE:  Что-то сделалось.

DO

Внутри PL/pgSQL можно использовать без изменений практически любые команды SQL, не возвращающие результат:

=> DO $$

BEGIN

`    `CREATE TABLE test(n integer);

`    `INSERT INTO test VALUES (1),(2),(3);

`    `UPDATE test SET n = n + 1 WHERE n > 1;

`    `DELETE FROM test WHERE n = 1;

`    `DROP TABLE test;

END;

$$;
# **Управление транзакциями в процедурах**
В процедурах (и в анонимных блоках кода) на PL/pgSQL можно также использовать команды управления транзакциями:

=> CREATE TABLE test(n integer);

CREATE TABLE

=> CREATE PROCEDURE foo()

AS $$

BEGIN

`    `INSERT INTO test VALUES (1);

`    `COMMIT;

`    `INSERT INTO test VALUES (2);

`    `ROLLBACK;

END;

$$ LANGUAGE plpgsql;




**SELECT … INTO**

получение первой по порядку строки результата

одна переменная составного типа

или подходящее количество скалярных переменных

INSERT, UPDATE, DELETE RETURNING … INTO

получение вставленной (измененной, удаленной) строки

одна переменная составного типа

или подходящее количество скалярных переменных
# **Команды, возвращающие одну строку**
Наверное, наиболее часто используется в PL/pgSQL команда SELECT, возвращающая одну строку. Пример, который не получилось бы выполнить с помощью выражения с подзапросом (потому что возвращаются сразу две строки):

=> CREATE TABLE t(id integer, code text);

CREATE TABLE

=> INSERT INTO t VALUES (1, 'Раз'), (2, 'Два');

INSERT 0 2

=> DO $$

DECLARE

`    `r record;

BEGIN

`    `SELECT id, code INTO r FROM t WHERE id = 1;

`    `RAISE NOTICE '%', r;

END;

$$;
# **Устранение неоднозначностей именования**
Получится ли выполнить следующий код?

=> DO $$

DECLARE

`    `id   integer := 1;

`    `code text;

BEGIN

`    `SELECT id, code INTO id, code

`    `FROM t WHERE id = id;

`    `RAISE NOTICE '%, %', id, code;

END;

$$;

ERROR:  column reference "id" is ambiguous

LINE 1: SELECT id, code                   FROM t WHERE id = id

`               `^

DETAIL:  It could refer to either a PL/pgSQL variable or a table column.

QUERY:  SELECT id, code                   FROM t WHERE id = id

CONTEXT:  PL/pgSQL function inline\_code\_block line 6 at SQL statement

Не получится из-за неоднозначности в SELECT: id может означать и имя столбца, и имя переменной:

Причем во фразе INTO неоднозначности нет — она относится только к PL/pgSQL. В сообщении, кстати, видно, как PL/pgSQL вырезает фразу INTO, прежде чем передать запрос в SQL.

Есть несколько подходов к устранению неоднозначностей.

Первый состоит в том, чтобы неоднозначностей не допускать. Для этого к переменным добавляют префикс, который обычно выбирается в зависимости от «класса» переменной, например:

\* Для параметров p\_ (parameter);

\* Для обычных переменных l\_ (local) или v\_ (variable);

\* Для констант c\_ (constant);

Это простой и действенный способ, если использовать его систематически и никогда не использовать префиксы в именах столбцов. К минусам можно отнести некоторую неряшливость и пестроту кода из-за лишних подчеркиваний.

Вот как это может выглядеть в нашем случае:

=> DO $$

DECLARE

`    `l\_id   integer := 1;

`    `l\_code text;

BEGIN

`    `SELECT id, code INTO l\_id, l\_code

`    `FROM t WHERE id = l\_id;

`    `RAISE NOTICE '%, %', l\_id, l\_code;

END;

$$;

NOTICE:  1, Раз!

DO

Второй способ состоит в использовании квалифицированных имен — к имени объекта через точку дописывается уточняющий квалификатор:

\* Для столбца — имя или псевдоним таблицы;

\* Для переменной — метку блока;

\* Для параметра — имя функции.

Такой способ более «честный», чем добавление префиксов, поскольку работает для любых названий столбцов.

Вот как будет выглядеть наш пример с использованием квалификаторов:

=> DO $$

<<local>>

DECLARE

`    `id   integer := 1;

`    `code text;

BEGIN

`    `SELECT t.id, t.code INTO local.id, local.code

`    `FROM t WHERE t.id = local.id;

`    `RAISE NOTICE '%, %', id, code;

END;

$$;

NOTICE:  1, Раз!

DO

Третий вариант — установить приоритет переменных над столбцами или наоборот, столбцов над переменными. За это отвечает конфигурационный параметр plpgsql.variable\_conflict.

В ряде случаев это упрощает разрешение конфликтов, но не устраняет их полностью. Кроме того, неявное правило (которое, к тому же, может внезапно поменяться) непременно приведет к тому, что какой-то код будет выполняться не так, как предполагал разработчик.

Тем не менее приведем пример. Здесь устанавливается приоритет переменных, поэтому достаточно квалифицировать только столбцы таблицы:

=> SET plpgsql.variable\_conflict = use\_variable;

SET

=> DO $$

DECLARE

`    `id   integer := 1;

`    `code text;

BEGIN

`    `SELECT t.id, t.code INTO id, code

`    `FROM t WHERE t.id = id;

`    `RAISE NOTICE '%, %', id, code;

END;

$$;

NOTICE:  1, Раз!

DO

=> RESET plpgsql.variable\_conflict;

RESET


**Ровно одна строка**

Что произойдет, если запрос вернет несколько строк?

=> DO $$

DECLARE

`    `r record;

BEGIN

`    `SELECT id, code INTO r FROM t;

`    `RAISE NOTICE '%', r;

END;

$$;

NOTICE:  (2,Два)

DO

В переменную будет записана только первая строка. Поскольку мы не указали ORDER BY, то порядок строк в общем случае непредсказуем:

=> SELECT \* FROM t;

` `id | code 

----+------

`  `2 | Два

`  `1 | Раз!

(2 rows)

Поскольку в командах INSERT, UPDATE, DELETE нет возможности указать порядок строк, то команда, затрагивающая несколько строк, приводит к ошибке:

=> DO $$

DECLARE

`    `r record;

BEGIN

`    `UPDATE t SET code = code || '!' RETURNING \* INTO r;

`    `RAISE NOTICE 'Изменили: %', r;

END;

$$;

ERROR:  query returned more than one row

HINT:  Make sure the query returns a single row, or use LIMIT 1.

CONTEXT:  PL/pgSQL function inline\_code\_block line 5 at SQL statement

А если запрос не вернет ни одной строки?

=> DO $$

DECLARE

`    `r record;

BEGIN

`    `r := (-1,'!!!');

`    `SELECT id, code INTO r FROM t WHERE false;

`    `RAISE NOTICE '%', r;

END;

$$;

NOTICE:  (,)

DO

Переменные будут содержать неопределенные значения.

То же относится и командам INSERT, UPDATE, DELETE. Например:

=> DO $$

DECLARE

`    `r record;

BEGIN

`    `UPDATE t SET code = code || '!' WHERE id = -1

`        `RETURNING \* INTO r;

`    `RAISE NOTICE 'Изменили: %', r;

END;

$$;

NOTICE:  Изменили: (,)

DO

Иногда хочется быть уверенным, что в результате выборки получилась ровно одна строка: ни больше, ни меньше. В этом случае удобно воспользоваться фразой INTO STRICT:

=> DO $$

DECLARE

`    `r record;

BEGIN

`    `SELECT id, code INTO STRICT r FROM t;

`    `RAISE NOTICE '%', r;

END;

$$;
# **Явная проверка состояния**
Другая возможность — проверять состояние последней выполненной SQL-команды:

- Команда GET DIAGNOSTICS позволяет получить количество затронутых строк (row\_count);
- Предопределенная логическая переменная FOUND показывает, была ли затронута хотя бы одна строка.

=> DO $$

DECLARE

`    `r record;

`    `rowcount integer;

BEGIN

`    `SELECT id, code INTO r FROM t WHERE false;

`    `GET DIAGNOSTICS rowcount = row\_count;

`    `RAISE NOTICE 'rowcount = %', rowcount;

`    `RAISE NOTICE 'found = %', FOUND;

END;

$$;

NOTICE:  rowcount = 0

NOTICE:  found = f

DO

=> DO $$

DECLARE

`    `r record;

`    `rowcount integer;

BEGIN

`    `SELECT id, code INTO r FROM t;

`    `GET DIAGNOSTICS rowcount = row\_count;

`    `RAISE NOTICE 'rowcount = %', rowcount;

`    `RAISE NOTICE 'found = %', FOUND;

END;

$$;

NOTICE:  rowcount = 1

NOTICE:  found = t

DO

Заметьте: диагностика не позволяет обнаружить, что запросу соответствует нескольких строк, поскольку row\_count возвращает единицу.

