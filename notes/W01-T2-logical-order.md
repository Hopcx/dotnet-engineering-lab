
 # Trong notes/W01-T2-logical-order.md:

-- 3–5 dòng, bằng lời của bạn, giải thích cho một bạn junior: "Vì sao alias trong SELECT không dùng được trong WHERE, nhưng dùng được trong ORDER BY?"
-- So sánh với dự đoán notes/W01-du-doan.md hôm qua: đúng chỗ nào, sai chỗ nào.
-- 1 câu hỏi còn mở.

Giải thích: Trong SQL, alias được định nghĩa trong SELECT chỉ tồn tại sau khi các bước xử lý của câu lệnh đã hoàn tất, vì vậy nó không thể được sử dụng trong WHERE, nơi mà các điều kiện lọc được áp dụng trước khi SELECT thực hiện. Tuy nhiên, alias có thể được sử dụng trong ORDER BY vì ORDER BY được thực hiện sau khi SELECT đã hoàn tất và alias đã được xác định.
So sánh với dự đoán notes/W01-du-doan.md hôm qua: Dự đoán đúng về việc alias không thể sử dụng trong WHERE, nhưng có thể sử dụng trong ORDER BY. Câu hỏi còn mở: Có cách nào để sử dụng alias trong WHERE mà vẫn đảm bảo tính hợp lệ của câu lệnh SQL không?


-- Tự kiểm tra (không nhìn tài liệu)
-- Viết lại 6 bước xử lý logic, nêu rõ DISTINCT và TOP nằm ở đâu.
-- Vì sao ROW_NUMBER() không được xuất hiện trong WHERE?
-- SELECT a + 1 AS x, x * 2 AS y – lỗi gì, vì sao?
-- Khác biệt giữa thứ tự logic và thứ tự vật lý? Xem thứ tự vật lý ở đâu?
-- Cho WHERE Qty <> 0 AND Total / Qty > 5 – có an toàn không?

-- 6 bước xử lý logic của SQL:
-- 1. FROM: Xác định các bảng và liên kết (joins) để lấy dữ liệu.
-- 2. WHERE: Lọc các bản ghi dựa trên điều kiện.    
-- 3. GROUP BY: Nhóm các bản ghi theo các cột được chỉ định.
-- 4. HAVING: Lọc các nhóm dữ liệu dựa trên điều kiện.
-- 5. SELECT: Chọn các cột hoặc biểu thức cần hiển thị trong kết quả.
-- 6. ORDER BY: Sắp xếp kết quả theo các cột hoặc biểu
-- thức được chỉ định. DISTINCT và TOP nằm trong bước SELECT, vì chúng ảnh hưởng đến các bản ghi được chọn và hiển thị.
-- ROW_NUMBER() không được xuất hiện trong WHERE vì nó là một hàm phân tích (analytic function) được tính toán sau khi các bản ghi đã được lọc và nhóm, do đó không thể sử dụng trong điều kiện WHERE.
-- SELECT a + 1 AS x, x * 2 AS y – lỗi vì alias x chưa được định nghĩa tại thời điểm y được tính toán, dẫn đến lỗi "invalid column name 'x'".
-- Thứ tự logic là thứ tự mà SQL Server xử lý các phần của câu lệnh SQL, trong khi thứ tự vật lý là thứ tự mà dữ liệu được lưu trữ và truy xuất từ cơ sở dữ liệu. Thứ tự vật lý có thể được xem thông qua các công cụ quản lý cơ sở dữ liệu hoặc bằng cách kiểm tra execution plan.
-- Cho WHERE Qty <> 0 AND Total / Qty > 5 – không an toàn vì nếu Qty bằng 0, phép chia Total / Qty sẽ gây ra lỗi chia cho 0. Cần đảm bảo rằng điều kiện Qty <> 0 được kiểm tra trước khi thực hiện phép chia để tránh lỗi. 

<!-- 
Việc ngay bây giờ (≤ 20'): sửa 4 mục 🔴, viết lại câu hỏi mở, commit với nội dung fix: W01-T2 review, rồi báo thầy. Sửa đúng thì thầy chuyển hôm nay sang ✅ -->





--1. KQ_Q1 tự mâu thuẫn, và lại sai đúng ý chính của buổi học. Bạn viết “kết quả không đúng vì alias Ngay chưa được định nghĩa”. Thầy đã chạy Q1: kết quả hoàn toàn đúng, đã sắp xếp theo ngày. Ghi chú Feynman của bạn cũng viết rằng ORDER BY dùng được alias. Bạn phải tự giải thích hai chỗ ngược nhau này: chỗ nào đúng, và vì sao, theo số bước xử lý.
-- Sửa KQ_Q1: ORDER BY có thể sử dụng alias được định nghĩa trong SELECT, vì SQL Server xử lý SELECT trước khi thực hiện ORDER BY. Do đó, câu lệnh Q1 chạy đúng và sắp xếp theo ngày. Tuy nhiên, nếu alias được sử dụng trong GROUP BY hoặc HAVING, thì sẽ không hợp lệ vì các bước xử lý khác nhau.

-- 2. BT1 và BT3 thiếu bước 1. Đề yêu cầu viết bản lỗi, chạy, chép thông báo lỗi. Ở BT1, bản đầu tiên của bạn đã lặp lại biểu thức, tức là đã sửa xong, không còn là bản lỗi. Ở BT3 thì không có bản lỗi nào. Hãy viết lại 2 bản lỗi, chạy, rồi chép Msg … thật vào comment. Ở BT3, thử thêm 2 kiểu: lọc bằng rn và viết ROW_NUMBER() ngay trong WHERE. Hai kiểu này ra 2 mã lỗi khác nhau. Hãy giải thích vì sao.
-- Viết lại bản lỗi BT1:
SELECT OrderId, Quantity * UnitPrice as LineTotal
FROM dbo.OrderLines
WHERE LineTotal > 100
-- Msg 207, Level 16, 
-- Viết lại bản lỗi BT3:
SELECT CustomerId, OrderId, OrderDate
FROM (  
    SELECT CustomerId, OrderId, OrderDate,
           ROW_NUMBER() OVER (PARTITION BY CustomerId ORDER BY OrderDate DESC) AS rn
    FROM dbo.Orders
) AS RankedOrders
WHERE rn = 1;
-- Msg 207, Level 16, 

-- Ở BT3, thử thêm 2 kiểu: lọc bằng rn và viết ROW_NUMBER() ngay trong WHERE. Hai kiểu này ra 2 mã lỗi khác nhau. Hãy giải thích vì sao.
-- Lọc bằng rn trong WHERE của bảng phụ RankedOrders sẽ ra lỗi Msg 207 vì rn chưa được định nghĩa tại thời điểm WHERE được thực thi.
-- Viết ROW_NUMBER() ngay trong WHERE sẽ ra lỗi Msg 8120 vì không thể sử dụng hàm tổng hợp hoặc hàm phân tích trong điều kiện WHERE, vì WHERE chỉ áp dụng cho các cột đã được nhóm hoặc các giá trị cụ thể.



3. Vị trí của TOP sai (phần tự kiểm tra). Bạn xếp TOP vào bước SELECT. Hãy tự hỏi: muốn “lấy 3 đơn mới nhất” thì phải biết thứ tự trước hay cắt trước? Câu trả lời cho bạn biết TOP đứng sau bước nào.
-- TOP ở bước 6  đứng sau Order BY 
4. “Thứ tự vật lý” bị hiểu nhầm. Đó không phải thứ tự dữ liệu được lưu trên đĩa. Bạn đọc lại §1.1 rồi viết lại câu này.
-- Thứ tự vật lý là thứ tự dữ liệu được lưu trữ trên đĩa, nhưng không đảm bảo thứ tự khi truy vấn dữ liệu. Để đảm bảo thứ tự cụ thể trong kết quả truy vấn, cần sử dụng ORDER BY.


-- Câu hỏi mở : Làm thế nào để đảm bảo rằng kết quả của câu truy vấn luôn ổn định khi có nhiều bản ghi trùng nhau?

