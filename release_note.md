# Tài Liệu Chuẩn: Quy Tắc Viết Release Notes

Đây là một bộ quy tắc (Format Guidelines) chi tiết và chuẩn mực, được thiết kế để áp dụng cho cả người viết nội dung (lên Store) và lập trình viên (hiển thị trên App). Bạn có thể lưu lại bộ quy tắc này làm tài liệu chuẩn cho dự án.

## 1. Bộ Từ Khóa (Tags) Tiêu Chuẩn & Gán Icon

Chúng ta sẽ chia các cập nhật thành 4 nhóm chính. Việc giới hạn số lượng nhóm giúp UI không bị rối và lập trình viên dễ dàng "bắt" (parse) dữ liệu.

| Từ khóa (Tag) | Ý nghĩa & Cấp độ ưu tiên | Icon đề xuất (khi lên App) | Màu sắc (Gợi ý cho Icon/Text) |
| :--- | :--- | :--- | :--- |
| **`[Mới]`** hoặc **`[Bổ sung]`** | Tính năng hoàn toàn mới, giá trị lớn nhất. (Ưu tiên cao nhất) | 🌟 Ngôi sao (Star)<br>🚀 Tên lửa (Rocket)<br>✨ Tia sáng (Sparkles) | **Màu Cam** (Đồng bộ với nút "Tiếp tục" của bạn) hoặc **Màu Vàng**. |
| **`[Tối ưu]`** hoặc **`[Cải thiện]`** | Làm tốt hơn tính năng đã có (nhanh hơn, mượt hơn, UI đẹp hơn). | ⚡️ Tia chớp (Lightning/Bolt)<br>📈 Đồ thị (Trending Up)<br>🔄 Vòng lặp (Sync) | **Màu Xanh dương** (Như background icon hiện tại của bạn) hoặc **Xanh lá**. |
| **`[Sửa lỗi]`** hoặc **`[Khắc phục]`** | Sửa các lỗi vặt (Bug fixes) ảnh hưởng đến người dùng. | 🛠 Cờ lê (Wrench/Build)<br>✅ Dấu tích (Check Circle)<br>🐞 Con bọ (Bug) | **Màu Xám** hoặc **Đỏ nhạt** (Không nên làm quá nổi bật phần lỗi). |
| **`[Bảo mật]`** (Tùy chọn) | Cập nhật liên quan đến an toàn dữ liệu, quyền riêng tư. | 🔒 Ổ khóa (Lock/Shield) | **Màu Xanh lá cây**. |

## 2. Ví Dụ Áp Dụng (Example)

Dưới đây là cách trình bày một bản cập nhật thực tế:

🚀 **[Bổ sung]**
- Chức năng tạo đơn đặt phòng xe.
- Thời gian vào ra giữa ca tại lịch sử chấm công.

⚡️ **[Tối ưu]**
- Luồng hiển thị thông tin mượt mà hơn.

🛠 **[Sửa lỗi]**
- Lỗi văng ứng dụng khi cập nhật ảnh đại diện.

---

## 3. Lưu Ý Cho Lập Trình Viên

Hệ thống sẽ tự động phân loại dựa trên từ khóa trong dấu ngoặc vuông `[...]`.
- Mỗi nhóm bắt đầu bằng một Tag.
- Các nội dung bên dưới Tag sẽ được hiển thị dưới dạng danh sách (Bullet points).
- Icon và màu sắc sẽ được tự động gán tương ứng với Tag.
