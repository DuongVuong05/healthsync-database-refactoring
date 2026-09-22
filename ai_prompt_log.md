# AI PROMPT LOG - DỰ ÁN HEALTHSYNC DATABASE REFACTORING

## Nhật ký 1: Tìm hiểu Anti-pattern dữ liệu vòng đời
* **Mục đích**: Hiểu rõ lý do không nên dùng cột Boolean cho trạng thái quy trình.
* **Prompt gửi AI**: 
  > "Trong thiết kế cơ sở dữ liệu quan hệ, tại sao việc dùng một cột is_active (kiểu TINYINT/BOOLEAN) để theo dõi vòng đời của một Đơn hàng/Lịch hẹn lại là một thiết kế tồi (Anti-pattern)? Tôi nên thay thế bằng cấu trúc nào trong MySQL?"
* **Bài học rút ra**: Cờ Boolean chỉ biểu diễn được 2 trạng thái (True/False). Trong khi quy trình thực tế có 5 trạng thái. Việc dùng ENUM hoặc bảng Lookup State giúp mở rộng quy trình minh bạch, hỗ trợ tạo Index truy vấn nhanh hơn.

## Nhật ký 2: Lựa chọn kiểu dữ liệu tài chính
* **Mục đích**: Tránh lỗi làm tròn số khi xử lý tiền cọc và tiền phạt.
* **Prompt gửi AI**: 
  > "Khi thiết kế cột deposit_amount và penalty_fee trong MySQL phục vụ tính toán tài chính, tôi nên dùng kiểu dữ liệu FLOAT, DOUBLE hay DECIMAL? Tại sao?"
* **Bài học rút ra**: FLOAT và DOUBLE sử dụng biểu diễn dấu chấm động nhị phân dẫn đến sai số làm tròn (ví dụ $0.1 + 0.2 \neq 0.3$). Bắt buộc phải dùng `DECIMAL(precision, scale)` vì nó lưu trữ số thập phân chính xác tuyệt đối.

## Nhật ký 3: Kiểm soát toàn vẹn dữ liệu bằng Trigger
* **Mục đích**: Nghiên cứu cách chặn lỗi nghiệp vụ ở tầng Database.
* **Prompt gửi AI**: 
  > "Cú pháp tạo Trigger BEFORE INSERT trong MySQL để kiểm tra trạng thái của một bảng khác trước khi cho phép chèn dữ liệu là gì? Viết ví dụ minh họa bằng câu lệnh SIGNAL SQLSTATE."
* **Bài học rút ra**: Hiểu cách dùng `SIGNAL SQLSTATE '45000'` để hủy giao dịch và thông báo lỗi tùy chỉnh từ Stored Procedure/Trigger trong MySQL.