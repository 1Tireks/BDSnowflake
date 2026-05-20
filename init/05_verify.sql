-- Sanity checks after load (visible in container logs on first start)
DO $$
DECLARE
    mock_cnt  BIGINT;
    fact_cnt  BIGINT;
BEGIN
    SELECT COUNT(*) INTO mock_cnt FROM mock_data;
    SELECT COUNT(*) INTO fact_cnt FROM fact_sales;

    RAISE NOTICE 'mock_data rows: %', mock_cnt;
    RAISE NOTICE 'fact_sales rows: %', fact_cnt;

    IF mock_cnt < 10000 THEN
        RAISE WARNING 'Expected at least 10000 rows in mock_data, got %', mock_cnt;
    END IF;

    IF fact_cnt <> mock_cnt THEN
        RAISE WARNING 'fact_sales (%) does not match mock_data (%)', fact_cnt, mock_cnt;
    END IF;
END $$;
