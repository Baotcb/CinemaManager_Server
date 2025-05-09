# CinemaManager_Server

CinemaManager_Server là phần máy chủ của hệ thống quản lý rạp chiếu phim. Hệ thống này được xây dựng bằng C# và TSQL, cung cấp các dịch vụ backend để hỗ trợ ứng dụng client [CinemaManager](https://github.com/Baotcb/CinemaManager).

## Mục Tiêu

Dự án này nhằm cung cấp một hệ thống quản lý rạp chiếu phim hiện đại, dễ sử dụng với các tính năng quản lý suất chiếu, đặt vé, và quản lý doanh thu.

## Tính Năng

- **Quản lý suất chiếu**: Cung cấp các API để tạo, sửa, và quản lý lịch chiếu phim.
- **Quản lý đặt vé**: Hỗ trợ xử lý đặt vé, hủy vé và lưu trữ thông tin khách hàng.
- **Thống kê và báo cáo**: Cung cấp các tính năng tổng hợp doanh thu và hiệu suất suất chiếu.
- **Kết nối với client**: Tương thích với ứng dụng client [CinemaManager](https://github.com/Baotcb/CinemaManager).

## Công Nghệ Sử Dụng

- **Ngôn ngữ**: 
  - C# (70.4%) để phát triển backend.
  - TSQL (29.6%) để quản lý cơ sở dữ liệu.
- **Cơ sở dữ liệu**: SQL Server.

## Cách Cài Đặt

1. Clone repository:
   ```bash
   git clone https://github.com/Baotcb/CinemaManager_Server.git
   ```
2. Cài đặt các dependency cần thiết:
   - Đảm bảo đã cài đặt .NET Framework và SQL Server.
   - Sử dụng Visual Studio để mở và build dự án.
3. Thiết lập cơ sở dữ liệu:
   - Chạy các file TSQL để tạo và cấu hình cơ sở dữ liệu.
4. Chạy máy chủ:
   - Mở giải pháp trong Visual Studio.
   - Build và chạy ứng dụng.

## Hướng Dẫn Sử Dụng

1. Thiết lập và chạy máy chủ từ dự án này.
2. Tải ứng dụng client từ dự án [CinemaManager](https://github.com/Baotcb/CinemaManager).
3. Kết nối ứng dụng client tới máy chủ bằng cách nhập địa chỉ IP và cổng của server.
4. Sử dụng hệ thống để quản lý rạp chiếu phim, đặt vé và theo dõi doanh thu.

## Đóng Góp

Chúng tôi luôn chào đón sự đóng góp từ cộng đồng. Nếu bạn muốn tham gia, hãy thực hiện các bước sau:

1. Fork repository.
2. Tạo một nhánh mới cho tính năng hoặc sửa lỗi của bạn (ví dụ: `feature/add-new-feature`).
3. Gửi pull request đến repository chính của chúng tôi.

## Liên Hệ

Nếu bạn có bất kỳ câu hỏi hoặc ý kiến nào, vui lòng liên hệ qua email: [Quocbaotrancao@gmail.com](mailto:quocbaotrancao@gmail.com).

## Giấy Phép

Dự án này được phát hành dưới giấy phép [MIT](https://opensource.org/licenses/MIT).
