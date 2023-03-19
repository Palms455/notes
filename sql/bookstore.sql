CREATE OR REPLACE FUNCTION webapi.login(
	username text)
    RETURNS uuid
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE SECURITY DEFINER 
    
AS $BODY$
DECLARE
    auth_token uuid;
	_in_user_id int;
BEGIN
	select u.user_id into strict _in_user_id from users u where u.username = login.username; 
	delete from sessions where user_id = _in_user_id;
    INSERT INTO sessions AS s(auth_token, user_id)
        SELECT gen_random_uuid(), _in_user_id
    RETURNING s.auth_token INTO STRICT auth_token; -- ошибка, если пользователя нет
    RETURN auth_token;
END;
$BODY$;



CREATE OR REPLACE FUNCTION webapi.add_to_cart(
	auth_token uuid,
	book_id bigint,
	qty integer DEFAULT 1)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE SECURITY DEFINER 
    
AS $BODY$
DECLARE
	_in_user_id int;
BEGIN
	_in_user_id := check_auth(auth_token);
	if qty = 1 then
		insert into cart_items (user_id, book_id, qty) select _in_user_id, book_id, qty
		on conflict on constraint  cart_items_pkey do update set  qty = cart_items.qty + 1;
	elsif qty = -1 then
		update cart_items set  qty = cart_items.qty - 1;
	end if;
	
END;
$BODY$;

CREATE OR REPLACE FUNCTION public.check_auth(
	auth_token uuid)
    RETURNS bigint
    LANGUAGE 'plpgsql'

    COST 100
    STABLE 
    
AS $BODY$
DECLARE
    user_id bigint;
BEGIN
    --user_id := current_setting('check_auth.user_id', /* missing_ok */true);
    --IF user_id IS NULL THEN
        SELECT s.user_id
        INTO STRICT user_id
        FROM sessions s
        WHERE s.auth_token = check_auth.auth_token;
        ---PERFORM set_config('check_auth.user_id', user_id::text, /* is_local */false);
    --END IF;
    RETURN user_id;
END;
$BODY$;