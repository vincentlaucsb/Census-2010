CREATE OR REPLACE FUNCTION count_numeric(count int, next_row text) RETURNS integer as $$
    BEGIN
        IF isnumeric(next_row) THEN
            RETURN count + 1;
        ELSE
            RETURN count;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE AGGREGATE isnumeric_col (col text, threshold real) RETURNS yesno as boolean (
  SFUNC = count_numeric,
  STYPE = int
  FINALFUNC = 
)