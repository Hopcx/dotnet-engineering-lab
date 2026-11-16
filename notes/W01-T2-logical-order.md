
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
