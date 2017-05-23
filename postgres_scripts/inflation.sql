/*
Returns inflation adjusted numbers (given CPI data is loaded)
 * Numbers will be returned in `end_yr` adjusted dollars
 
Efficiency:
 * Tries to select CPI inflator from cache
 * Otherwise, it creates a table
*/
CREATE OR REPLACE FUNCTION
    inflate(money float8, start_yr integer, end_yr integer)
RETURNS float8 AS $$
DECLARE
    start_cpi float8;
    end_cpi float8;
    inflation float8;
BEGIN
    -- Try fetching inflation ratio from cache
    inflation := (SELECT ratio FROM cpi_ratios
                  WHERE
                    cpi_ratios.startyr = start_yr AND
                    cpi_ratios.endyr = end_yr);

    IF inflation IS NULL THEN
        RAISE EXCEPTION 'Nothing found';
    ELSE                    
        RETURN money * inflation;
    END IF;
                    
    EXCEPTION WHEN others THEN -- Table doesn't exist or value not found
        -- Create table
        CREATE TABLE IF NOT EXISTS cpi_ratios
            (startyr integer, endyr integer, ratio float8);
            
        -- Add an index for efficient future queries
        CREATE INDEX ON cpi_ratios (startyr);
        CREATE INDEX ON cpi_ratios (endyr);
        
        -- Do the computation
        start_cpi := (SELECT CAST(value as float8) FROM cpi
                      WHERE
                        series_id LIKE '%CUUR0000AA0%' AND
                        period LIKE '%M13%' AND  -- M13 = Yearly average
                        year = start_yr);
                        
        end_cpi := (SELECT CAST(value as float8) FROM cpi
                      WHERE
                        series_id LIKE '%CUUR0000AA0%' AND
                        period LIKE '%M13%' AND
                        year = end_yr);
                    
        inflation := end_cpi/start_cpi;
        
        -- Save it
        INSERT INTO cpi_ratios (startyr, endyr, ratio)
            VALUES (start_yr, end_yr, inflation);
    
        RETURN money * inflation;
END;
$$ LANGUAGE plpgsql VOLATILE;