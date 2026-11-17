-- BT1: 
IF DB_ID('LabW01_T3_171126') IS NULL CREATE DATABASE LabW01_T3_171126;
GO
USE LabW01_T3_171126;
GO
DROP TABLE IF EXISTS dbo.Users, dbo.Products, dbo.Orders, dbo.OrderDetails;

CREATE TABLE dbo.Users
(
    UserId      INT IDENTITY(1,1) PRIMARY KEY,
    FullName    NVARCHAR(150) NOT NULL,
    Email       VARCHAR(255) NOT NULL UNIQUE,
    City        NVARCHAR(100) NULL,
    CreatedAt   DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO
CREATE TABLE dbo.Products
(
    ProductId   INT IDENTITY(1,1) PRIMARY KEY,
    Name        NVARCHAR(200) NOT NULL,
    Category    NVARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2) NOT NULL
        CHECK (Price >= 0)
);

CREATE TABLE dbo.Orders
(
    OrderId     INT IDENTITY(1,1) PRIMARY KEY,
    UserId      INT NOT NULL,
    OrderDate   DATE NOT NULL,
    Status      VARCHAR(30) NOT NULL,

    CONSTRAINT FK_Orders_Users
        FOREIGN KEY (UserId)
        REFERENCES dbo.Users(UserId)
);
GO
CREATE TABLE dbo.OrderDetails
(
    OrderId     INT NOT NULL,
    LineNumber  INT NOT NULL,
    ProductId   INT NOT NULL,
    Quantity    INT NOT NULL,
    UnitPrice   DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_OrderDetails
        PRIMARY KEY (OrderId, LineNumber),

    CONSTRAINT FK_OrderDetails_Orders
        FOREIGN KEY (OrderId)
        REFERENCES dbo.Orders(OrderId),

    CONSTRAINT FK_OrderDetails_Products
        FOREIGN KEY (ProductId)
        REFERENCES dbo.Products(ProductId),

    CONSTRAINT CK_OrderDetails_Quantity
        CHECK (Quantity > 0),

    CONSTRAINT CK_OrderDetails_UnitPrice
        CHECK (UnitPrice >= 0)
);
GO

-- Trả lời câu hỏi:  vì sao OrderDetails.UnitPrice tồn tại dù đã có Products.Price?
-- Đáp án: Products.Price lưu giá bán hiện tại của sản phẩm, còn OrderDetails.UnitPrice lưu giá sản phẩm tại thời điểm phát sinh đơn hàng


-- BT2: 


USE SalesLab;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;


IF EXISTS (SELECT 1 FROM dbo.Users)
   OR EXISTS (SELECT 1 FROM dbo.Products)
   OR EXISTS (SELECT 1 FROM dbo.Orders)
   OR EXISTS (SELECT 1 FROM dbo.OrderDetails)
BEGIN
    THROW 50001, N'Các bảng phải trống trước khi chạy BT2.', 1;
END;
GO


DBCC CHECKIDENT ('dbo.Users', RESEED, 0);
DBCC CHECKIDENT ('dbo.Products', RESEED, 0);
DBCC CHECKIDENT ('dbo.Orders', RESEED, 0);
GO



DROP TABLE IF EXISTS #Numbers;

SELECT TOP (1000000)
    CONVERT(INT, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) AS N
INTO #Numbers
FROM sys.all_objects A
CROSS JOIN sys.all_objects B;

IF (SELECT COUNT_BIG(*) FROM #Numbers) <> 1000000
    THROW 50002, N'Không sinh đủ 1 triệu số.', 1;

CREATE UNIQUE CLUSTERED INDEX IX_Numbers_N
ON #Numbers(N);

DECLARE @StartTime DATETIME2(7);
DECLARE @EndTime DATETIME2(7);

SET @StartTime = SYSDATETIME();

INSERT INTO dbo.Users
(
    FullName,
    Email,
    City,
    CreatedAt
)
SELECT
    N'User ' + RIGHT('00000' + CAST(N AS VARCHAR(5)), 5),

    'user' + CAST(N AS VARCHAR(10)) + '@example.com',

    CASE
        WHEN N % 10 = 0 THEN NULL
        ELSE
            CASE N % 5
                WHEN 0 THEN N'Hà Nội'
                WHEN 1 THEN N'Hồ Chí Minh'
                WHEN 2 THEN N'Đà Nẵng'
                WHEN 3 THEN N'Hải Phòng'
                ELSE N'Cần Thơ'
            END
    END,

    DATEADD(
        SECOND,
        N % 31536000,
        CAST('20230101' AS DATETIME2)
    )
FROM #Numbers
WHERE N <= 50000;

SET @EndTime = SYSDATETIME();

PRINT CONCAT(
    'Users: ',
    DATEDIFF_BIG(MILLISECOND, @StartTime, @EndTime),
    ' ms'
);


SET @StartTime = SYSDATETIME();

INSERT INTO dbo.Products
(
    Name,
    Category,
    Price
)
SELECT
    N'Product ' + CAST(N AS NVARCHAR(10)),

    CASE N % 5
        WHEN 0 THEN N'Electronics'
        WHEN 1 THEN N'Fashion'
        WHEN 2 THEN N'Food'
        WHEN 3 THEN N'Furniture'
        ELSE N'Books'
    END,

    CAST(100.00 + (N % 500000) / 100.0 AS DECIMAL(10,2))

FROM #Numbers
WHERE N <= 2000;

SET @EndTime = SYSDATETIME();

PRINT CONCAT(
    'Products: ',
    DATEDIFF_BIG(MILLISECOND, @StartTime, @EndTime),
    ' ms'
);



SET @StartTime = SYSDATETIME();

INSERT INTO dbo.Orders
(
    UserId,
    OrderDate,
    Status
)
SELECT
    CASE
        WHEN (N - 1) % 10 < 7
            THEN 1 + ((N - 1) % 100)

    
        ELSE 101 + ((N - 1) % 42400)
    END,

    DATEADD(
        DAY,
        (N - 1) % 1461,
        CAST('20230101' AS DATE)
    ),

    CASE N % 4
        WHEN 0 THEN 'Completed'
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Cancelled'
        ELSE 'Processing'
    END

FROM #Numbers
WHERE N <= 1000000;

SET @EndTime = SYSDATETIME();

PRINT CONCAT(
    'Orders: ',
    DATEDIFF_BIG(MILLISECOND, @StartTime, @EndTime),
    ' ms'
);




SET @StartTime = SYSDATETIME();

INSERT INTO dbo.OrderDetails
(
    OrderId,
    LineNumber,
    ProductId,
    Quantity,
    UnitPrice
)
SELECT
    O.OrderId,

    L.LineNumber,

    ((O.OrderId * 37 + L.LineNumber * 13 - 1) % 1900) + 1,

    1 + ((O.OrderId + L.LineNumber) % 5),

    P.Price

FROM dbo.Orders O

CROSS JOIN
(
    VALUES (1), (2), (3), (4), (5)
) L(LineNumber)

INNER JOIN dbo.Products P
    ON P.ProductId =
       ((O.OrderId * 37 + L.LineNumber * 13 - 1) % 1900) + 1

WHERE L.LineNumber <= 1 + ((O.OrderId - 1) % 5);

SET @EndTime = SYSDATETIME();

PRINT CONCAT(
    'OrderDetails: ',
    DATEDIFF_BIG(MILLISECOND, @StartTime, @EndTime),
    ' ms'
);


-- Tổng số đơn hàng
SELECT COUNT_BIG(*) AS TotalOrders
FROM dbo.Orders;

-- Tổng số OrderDetails
SELECT COUNT_BIG(*) AS TotalOrderDetails
FROM dbo.OrderDetails;

-- Kiểm tra OrderDetails không có Order tương ứng
SELECT COUNT_BIG(*) AS InvalidOrderReferences
FROM dbo.OrderDetails OD
LEFT JOIN dbo.Orders O
    ON OD.OrderId = O.OrderId
WHERE O.OrderId IS NULL;


--Thời gian chạy Users: 1653 ms
--Thời gian chạy Products: 38 ms
--Thời gian chạy Orders: 15436 ms


-- BT4:
-- 1. Số user có ít nhất một đơn
/*
Dự đoán:
- INNER JOIN chỉ giữ user có đơn hàng.
- COUNT(DISTINCT U.UserId) đếm mỗi user đúng một lần.
- Kết quả trả về 1 dòng.
*/

SELECT
    COUNT(DISTINCT U.UserId) AS TotalUsersWithOrders
FROM dbo.Users U
INNER JOIN dbo.Orders O
    ON U.UserId = O.UserId;

--2. Đếm số đơn của từng user, bao gồm user không có đơn
/*
Dự đoán:
- LEFT JOIN giữ lại toàn bộ Users.
- User không có đơn vẫn xuất hiện.
- COUNT(O.OrderId) trả về 0 nếu user không có đơn.
*/

SELECT
    U.UserId,
    U.FullName,
    COUNT(O.OrderId) AS TotalOrders
FROM dbo.Users U
LEFT JOIN dbo.Orders O
    ON U.UserId = O.UserId
GROUP BY
    U.UserId,
    U.FullName
ORDER BY
    TotalOrders DESC;

-- 3. Chỉ đếm đơn hàng năm 2026: điều kiện ở ON và WHERE

/*
Dự đoán:
- Điều kiện năm 2026 chỉ giới hạn những đơn được JOIN.
- LEFT JOIN vẫn giữ toàn bộ Users.
- Kết quả có 50.000 dòng.
*/

-- điều kiện trong ON:
SELECT
    U.UserId,
    U.FullName,
    COUNT(O.OrderId) AS TotalOrders2026
FROM dbo.Users U
LEFT JOIN dbo.Orders O
    ON U.UserId = O.UserId
    AND O.OrderDate >= '20260101'
    AND O.OrderDate <  '20270101'
GROUP BY
    U.UserId,
    U.FullName
ORDER BY
    TotalOrders2026 DESC;

-- điều kiện trong WHERE:
/*
Dự đoán:
- LEFT JOIN tạo các dòng NULL cho user không có đơn.
- WHERE loại bỏ những dòng có OrderDate = NULL.
- Kết quả chỉ còn user có ít nhất một đơn năm 2026.
*/

SELECT
    U.UserId,
    U.FullName,
    COUNT(O.OrderId) AS TotalOrders2026
FROM dbo.Users U
LEFT JOIN dbo.Orders O
    ON U.UserId = O.UserId
WHERE
    O.OrderDate >= '20260101'
    AND O.OrderDate <  '20270101'
GROUP BY
    U.UserId,
    U.FullName
ORDER BY
    TotalOrders2026 DESC;

-- 4. Fan-out – JOIN làm tăng số dòng

/*
Dự đoán:
- COUNT(*) trên Orders: 1.000.000.
- COUNT(*) trên Orders JOIN OrderDetails: 3.000.000.
- JOIN làm một đơn xuất hiện nhiều lần tương ứng số dòng chi tiết.
*/

-- Đếm số đơn
SELECT
    COUNT(*) AS TotalOrders
FROM dbo.Orders;


-- Đếm số dòng sau JOIN
SELECT
    COUNT(*) AS TotalJoinedRows
FROM dbo.Orders O
INNER JOIN dbo.OrderDetails OD
    ON O.OrderId = OD.OrderId;
