CREATE OR REPLACE FUNCTION multi_replace(str text, rep text[])
    RETURNS text as $$
    DECLARE
    	rep_str text;
    BEGIN
        FOREACH rep_str IN ARRAY rep
        LOOP
            str:= replace(str, rep_str, '');
        END LOOP;
        
        RETURN str;
    END;
$$ LANGUAGE plpgsql;