create or replace function author_name(IN last_name text, IN first_name text, IN surname text, OUT text) 
as 
$code$
select concat(last_name, ' ', left(first_name, 1), '.', coalesce(left(surname, 1)||'.', ''))
$code$
language sql; 


create or replace view authors_v 
as 
	select a.author_id, author_name(a.last_name, a.first_name, a.surname) AS display_name
	from authors a;
	
	
	
select string_agg(author_name(a.last_name, a.first_name, a.surname), ',' order by ab.seq_num)
from books b 
join authorship ab on ab.book_id = b.book_id
join authors a on a.author_id = ab.author_id
group by b.book_id;

create or replace function book_name(bookss_id integer, title text) returns text
as $code$
	select concat(title, ', ', string_agg(author_name(a.last_name, a.first_name, a.surname), ',' order by ab.seq_num))
	from books b 
	join authorship ab on ab.book_id = b.book_id
	join authors a on a.author_id = ab.author_id
	where b.book_id = bookss_id
	group by b.book_id;
$code$
language sql;


=> CREATE OR REPLACE FUNCTION book_name(book_id integer, title text)
RETURNS text
AS $$
SELECT title || '. ' ||
       string_agg(
           author_name(a.last_name, a.first_name, a.surname), ', '
           ORDER BY ash.seq_num
       )
FROM   authors a
       JOIN authorship ash ON a.author_id = ash.author_id
WHERE  ash.book_id = book_name.book_id;
$$ STABLE LANGUAGE sql;

create or replace view catalog_v as
 SELECT b.book_id,
    book_name(b.book_id, b.title) AS display_name
   FROM books b;
   
   
create or replace function onhand_qty(book books) returns integer
as $code$
	select coalesce(sum(op.qty_change), 0)::integer from operations op
	where op.book_id = book.book_id;
$code$
language sql;

create or replace function get_catalog(author_name text, book_title text, in_stock boolean) returns
table(book_id integer, display_name text, onhand_qty integer)
as $$
	
$$
language sql;

CREATE OR REPLACE FUNCTION authors(book books) RETURNS text
AS $$
    SELECT string_agg(
               a.last_name ||
               ' ' ||
               a.first_name ||
               coalesce(' ' || nullif(a.surname,''), ''),
               ', ' 
               ORDER BY ash.seq_num
           )
    FROM   authors a
           JOIN authorship ash ON a.author_id = ash.author_id
    WHERE  ash.book_id = book.book_id;
$$ STABLE LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_catalog(
    author_name text, 
    book_title text, 
    in_stock boolean
)
RETURNS TABLE(book_id integer, display_name text, onhand_qty integer)
AS $$
    SELECT cv.book_id, 
           cv.display_name,
           cv.onhand_qty
    FROM   catalog_v cv
    WHERE  cv.title   ILIKE '%'||coalesce(book_title,'')||'%'
    AND    cv.authors ILIKE '%'||coalesce(author_name,'')||'%'
    AND    (in_stock AND cv.onhand_qty > 0 OR in_stock IS NOT TRUE)
    ORDER BY display_name;
$$ STABLE LANGUAGE sql;
