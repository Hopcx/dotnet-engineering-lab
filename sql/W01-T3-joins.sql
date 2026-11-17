-- BT3:

SET NOCOUNT ON;

--  Tạo 3 bảng tạm
CREATE TABLE #BenchA
(
    Value INT
);

CREATE TABLE #BenchB
(
    Value INT
);

CREATE TABLE #BenchC
(
    Value INT
);

DECLARE @StartTime DATETIME2(7);
DECLARE @EndTime DATETIME2(7);


-- a) WHILE - Mỗi INSERT tự COMMIT
SET @StartTime = SYSDATETIME();

DECLARE @i INT = 1;

WHILE @i <= 20000
BEGIN
    INSERT INTO #BenchA (Value)
    VALUES (@i);

    SET @i += 1;
END;

SET @EndTime = SYSDATETIME();

PRINT N'(a) WHILE - Autocommit: '
    + CAST(DATEDIFF_BIG(MILLISECOND, @StartTime, @EndTime) AS VARCHAR(20))
    + N' ms';

-- b) WHILE - Một TRANSACTION

SET @StartTime = SYSDATETIME();

SET @i = 1;

BEGIN TRANSACTION;

WHILE @i <= 20000
BEGIN
    INSERT INTO #BenchB (Value)
    VALUES (@i);

    SET @i += 1;
END;

COMMIT TRANSACTION;

SET @EndTime = SYSDATETIME();

PRINT N'(b) WHILE - One transaction: '
    + CAST(DATEDIFF_BIG(MILLISECOND, @StartTime, @EndTime) AS VARCHAR(20))
    + N' ms';


-- (c) SET-BASED - Một câu INSERT
SET @StartTime = SYSDATETIME();

WITH Digits AS
(
    SELECT N
    FROM (VALUES
        (0), (1), (2), (3), (4),
        (5), (6), (7), (8), (9)
    ) AS D(N)
),
Numbers AS
(
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
    FROM Digits D1
    CROSS JOIN Digits D2
    CROSS JOIN Digits D3
    CROSS JOIN Digits D4
    CROSS JOIN Digits D5
)
INSERT INTO #BenchC (Value)
SELECT CAST(N AS INT)
FROM Numbers
WHERE N <= 20000;

SET @EndTime = SYSDATETIME();

PRINT N'(c) SET-BASED: '
    + CAST(DATEDIFF_BIG(MILLISECOND, @StartTime, @EndTime) AS VARCHAR(20))
    + N' ms';



-- 2. Kiểm tra số dòng
SELECT
    (SELECT COUNT(*) FROM #BenchA) AS Rows_A, -- 20000
    (SELECT COUNT(*) FROM #BenchB) AS Rows_B, -- 20000
    (SELECT COUNT(*) FROM #BenchC) AS Rows_C; -- 20000

    -- Mất 4s để chạy script 