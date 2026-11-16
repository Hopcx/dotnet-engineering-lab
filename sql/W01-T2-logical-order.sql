-- BT0:
 
-- Q1 : Dự đoán chạy được ko gặp lỗi 
SELECT CustomerId, OrderDate AS Ngay FROM dbo.Orders ORDER BY Ngay;
-- KQ_Q1 : Chạy được, không gặp lỗi
-- Câu lệnh đúng sẽ là:
SELECT CustomerId, OrderDate AS Ngay FROM dbo.Orders ORDER BY OrderDate;

-- Q2 : Dự đoán lỗi, lỗi invalid column name 'Nam' 
SELECT CustomerId, YEAR(OrderDate) AS Nam FROM dbo.Orders GROUP BY CustomerId, Nam;
-- KQ_Q2 : Lỗi vì trong câu lệnh GROUP BY không thể sử dụng alias, cần sử dụng biểu thức gốc
SELECT CustomerId, YEAR(OrderDate) AS Nam FROM dbo.Orders GROUP BY CustomerId, YEAR(OrderDate);

-- Q3: Dự đoán lỗi, lỗi invalid column name 'SoDon'
SELECT CustomerId, COUNT(*) AS SoDon FROM dbo.Orders GROUP BY CustomerId HAVING SoDon >= 2;
-- KQ_Q3 : Lỗi vì trong câu lệnh HAVING không thể sử dụng alias, cần sử dụng biểu thức gốc
SELECT CustomerId, COUNT(*) AS SoDon FROM dbo.Orders GROUP BY CustomerId HAVING COUNT(*) >= 2;

-- Q4 : Dự đoán lỗi,  Do  OrderDate chưa được định nghĩa trong SELECT nên không thể sử dụng trong ORDER BY
SELECT DISTINCT CustomerId FROM dbo.Orders ORDER BY OrderDate;
-- KQ_Q4 : Lỗi vì trong câu lệnh ORDER BY không thể sử dụng cột OrderDate khi cột này không có trong SELECT DISTINCT. Câu lệnh đúng sẽ là:
SELECT DISTINCT CustomerId, OrderDate FROM dbo.Orders ORDER BY OrderDate;
-- Q5: Dự đoán chạy được ko gặp lỗi
SELECT TOP (3) OrderId, OrderDate FROM dbo.Orders;
-- KQ_Q5 : Chạy ok, ko xảy ra lỗi, câu lệnh này sẽ trả về 3 bản ghi đầu tiên trong bảng Orders theo thứ tự mặc định (thường là theo thứ tự nhập dữ liệu vào bảng).
-- Q5 chạy được nhưng có vấn đề về thứ tự dữ liệu trả về, vì không có ORDER BY nên không đảm bảo thứ tự cụ thể. Câu lệnh đúng sẽ là:
SELECT TOP (3) OrderId, OrderDate FROM dbo.Orders ORDER BY OrderDate;

-- Q6: Dự đoán lỗi, lỗi vì Order by thiếu dữ liệu khi nhóm
SELECT CustomerId, OrderId FROM dbo.Orders GROUP BY CustomerId;
-- KQ_Q6 : Lỗi vì trong câu lệnh GROUP BY, khi nhóm theo CustomerId thì OrderId không được phép xuất hiện trong SELECT mà không có một hàm tổng hợp (aggregate function) nào.
-- Câu lệnh đúng sẽ là:
SELECT CustomerId, COUNT(OrderId) AS SoDon FROM dbo.Orders GROUP BY CustomerId;

-- BT1 – Alias trong WHERE (minh họa #1)
-- Liệt kê các dòng hàng có LineTotal = Quantity * UnitPrice lớn hơn 100, sắp giảm dần theo LineTotal.

--1. Viết phiên bản dùng alias trong WHERE, chạy, chép thông báo lỗi vào comment.
SELECT OrderId, Quantity * UnitPrice as LineTotal 
FROM dbo.OrderLines
WHERE (Quantity * UnitPrice) > 100 
ORDER BY LineTotal DESC;

--2 Sửa bằng 2 cách khác nhau trong 3 cách ở mục 2 (bắt buộc có 1 cách là CTE hoặc derived table).
WITH CTE_LineTotal AS (
    SELECT OrderId, Quantity * UnitPrice as LineTotal 
    FROM dbo.OrderLines
)
SELECT OrderId, LineTotal
FROM CTE_LineTotal
WHERE LineTotal > 100
ORDER BY LineTotal DESC;

-- 3. Sửa bằng cách dùng derived table
SELECT OrderId, LineTotal
FROM (
    SELECT OrderId, Quantity * UnitPrice as LineTotal 
    FROM dbo.OrderLines
) AS DerivedTable
WHERE LineTotal > 100
ORDER BY LineTotal DESC;

-- Comment: trong cách sửa, LineTotal được tạo ra ở bước nào?
-- CTE: ở bước tạo CTE
-- Derived Table: ở bước tạo bảng phụ


-- BT2 – WHERE và HAVING trong cùng một câu (minh họa #2)
-- Tìm các khách hàng có ít nhất 2 đơn trong năm 2026, hiển thị CustomerId, số đơn, ngày đặt đơn gần nhất.

-- Comment cho từng điều kiện: vì sao nó nằm ở WHERE hay ở HAVING?
-- Thử chuyển điều kiện năm 2026 xuống HAVING – có chạy không? Nếu không, vì sao? Nếu có, kết quả và ý nghĩa có còn giống không?


SELECT CustomerId, COUNT(OrderId) AS SoDon, MAX(OrderDate) AS NgayDatDonGanNhat
FROM dbo.Orders
WHERE YEAR(OrderDate) = 2026
GROUP BY CustomerId
HAVING COUNT(OrderId) >= 2
-- Comment: Điều kiện YEAR(OrderDate) = 2026 nằm ở WHERE vì nó lọc các bản ghi trước khi nhóm. Điều kiện COUNT(OrderId) >= 2 nằm ở HAVING vì nó áp dụng sau khi nhóm dữ liệu.
-- Nếu chuyển điều kiện YEAR(OrderDate) = 2026 xuống HAVING, câu lệnh sẽ không chạy được vì HAVING chỉ áp dụng cho các cột đã được nhóm hoặc các hàm tổng hợp. Kết quả và ý nghĩa sẽ khác nhau vì việc lọc dữ liệu trước khi nhóm (WHERE) và sau khi nhóm (HAVING) sẽ ảnh hưởng đến số lượng bản ghi được tính toán.


-- BT3 – Đơn mới nhất của mỗi khách (minh họa #3, câu C8)
-- Với mỗi khách hàng, lấy 1 đơn có OrderDate mới nhất (CustomerId, OrderId, OrderDate) bằng ROW_NUMBER().

-- Viết thử phiên bản lọc rn = 1 ngay trong WHERE, chép lỗi vào comment, giải thích bằng số bước.
-- Sửa cho đúng.
-- Khách số 3 có 2 đơn cùng ngày 2026-05-01 – không ảnh hưởng tới kết quả hôm nay, nhưng hãy nghĩ: nếu 2 đơn mới nhất trùng ngày thì ROW_NUMBER chọn đơn nào? Kết quả có ổn định giữa các lần chạy không? Sửa thế nào để ổn định?

SELECT CustomerId, OrderId, OrderDate
FROM (  
    SELECT CustomerId, OrderId, OrderDate,
           ROW_NUMBER() OVER (PARTITION BY CustomerId ORDER BY OrderDate DESC) AS rn
    FROM dbo.Orders
) AS RankedOrders
WHERE rn = 1;

-- Comment: Nếu lọc rn = 1 ngay trong WHERE của câu lệnh con, sẽ xảy ra lỗi vì rn chưa được định nghĩa tại thời điểm WHERE được thực thi. Câu lệnh đúng là phải lọc rn = 1 ở bên ngoài sau khi đã tạo bảng phụ RankedOrders.
-- Nếu 2 đơn mới nhất trùng ngày, ROW_NUMBER sẽ chọn một trong số đó dựa trên thứ tự mặc định của cơ sở dữ liệu, điều này có thể không ổn định giữa các lần chạy. Để ổn định, có thể thêm một cột khác vào ORDER BY trong ROW_NUMBER, ví dụ như OrderId, để đảm bảo thứ tự duy nhất:
SELECT CustomerId, OrderId, OrderDate
FROM (  
    SELECT CustomerId, OrderId, OrderDate,
           ROW_NUMBER() OVER (PARTITION BY CustomerId ORDER BY OrderDate DESC, OrderId DESC) AS rn
    FROM dbo.Orders
) AS RankedOrders
WHERE rn = 1;


-- 2 lỗi ở BT3:
SELECT
    CustomerId,
    OrderId,
    OrderDate,
    ROW_NUMBER() OVER (
        PARTITION BY CustomerId
        ORDER BY OrderDate DESC
    ) AS rn
FROM dbo.Orders
WHERE rn = 1;

-- Msg 207, Level 16, State 1
-- Invalid column name 'rn'.

SELECT
    CustomerId,
    OrderId,
    OrderDate
FROM dbo.Orders
WHERE ROW_NUMBER() OVER (
    PARTITION BY CustomerId
    ORDER BY OrderDate DESC
) = 1;

-- Msg 4108, Level 15, State 1
-- Windowed functions can only appear in the SELECT or ORDER BY clauses.
