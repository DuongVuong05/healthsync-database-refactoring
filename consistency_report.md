# BÁO CÁO PHÂN TÍCH SỰ BẤT NHẤT DỮ LIỆU (GAP ANALYSIS REPORT)
Dự án: Hệ thống Quản lý Phòng khám HealthSync
Người thực hiện: System Analyst & Database Administrator

## 1. Tổng quan
Thực hiện đối chiếu giữa UML Activity Diagram (Quy trình Đặt lịch & Khám bệnh) và Legacy Database Schema, phát hiện 4 lỗ hổng dữ liệu nghiêm trọng khiến hệ thống không thể vận hành thực tế.

## 2. Các lỗ hổng dữ liệu chi tiết

### Lỗ hổng 1: Bẫy anti-pattern cờ Boolean (`is_active`) cho vòng đời đa trạng thái
* **Hiện trạng**: Bảng `Appointments` dùng cột `is_active BOOLEAN`.
* **Sự lệch pha với Activity Diagram**: Quy trình nghiệp vụ yêu cầu theo dõi 5 trạng thái: `PENDING` -> `CONFIRMED` -> `CHECKED_IN` -> `COMPLETED` / `CANCELLED`.
* **Hậu quả**: Cờ True/False không thể phân biệt giữa một lịch hẹn "vừa đặt thành công", "đã đến phòng khám" hay "đã khám xong". Hệ thống không có khả năng điều phối luồng bệnh nhân.

### Lỗ hổng 2: Thiếu hụt hoàn toàn các trường dữ liệu giao dịch tài chính
* **Hiện trạng**: Bảng `Appointments` không có cột lưu tiền cọc (`deposit_amount`) và phí phạt (`penalty_fee`).
* **Sự lệch pha với Activity Diagram**: Quy trình bắt buộc đóng tiền cọc khi đặt lịch và phạt tiền cọc nếu hủy sau khi đã xác nhận (`CONFIRMED`).
* **Hậu quả**: Thất thoát dữ liệu tài chính. Kế toán không thể đối soát số tiền cọc thực thu, số tiền refund và phần tiền giữ lại làm phí phạt.

### Lỗ hổng 3: Thiếu dữ liệu phục vụ quản trị và chăm sóc khách hàng (`cancel_reason`)
* **Hiện trạng**: Không có cột ghi nhận lý do hủy hẹn.
* **Sự lệch pha với Activity Diagram**: Khi chuyển trạng thái sang `CANCELLED`, hệ thống phải ghi nhận lý do hủy từ bệnh nhân.
* **Hậu quả**: Mất dấu vết nghiệp vụ (Audit Trail), phòng khám không có số liệu phân tích tỷ lệ rời bỏ dịch vụ hay lý do hủy lịch phổ biến.

### Lỗ hổng 4: Vắng mặt hoàn toàn thực thể Đơn thuốc (`Prescriptions`)
* **Hiện trạng**: Cơ sở dữ liệu legacy hoàn toàn không có bảng `Prescriptions`.
* **Sự lệch pha với Activity Diagram**: Khi lịch hẹn đạt trạng thái `COMPLETED`, Bác sĩ sẽ kê đơn thuốc đi kèm.
* **Hậu quả**: Tính năng "Kê đơn thuốc" trên Backend báo lỗi 500/404 vì không có bảng dữ liệu lưu trữ chi tiết thuốc và liều dùng.