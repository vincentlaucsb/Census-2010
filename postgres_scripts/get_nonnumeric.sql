CREATE OR REPLACE FUNCTION get_nonnumeric(value TEXT)
	RETURNS text AS $$
BEGIN
    IF isnumeric(value) THEN
        RETURN NULL;
    ELSE
        RETURN value;
    END IF;
END;
$$ LANGUAGE plpgsql;