CREATE OR REPLACE FUNCTION int_or_null(input text)
    -- Cast to integer or return null
RETURNS integer AS $$
BEGIN
    RETURN CAST(input AS INTEGER);
EXCEPTION WHEN SQLSTATE '22P02' THEN -- Invalid input
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION float_or_null(input text)
    -- Cast to decimal or return null
RETURNS float8 AS $$
BEGIN
    RETURN CAST(input AS FLOAT8);
EXCEPTION WHEN SQLSTATE '22P02' THEN -- Invalid input
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;