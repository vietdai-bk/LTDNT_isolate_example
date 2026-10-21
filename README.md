# isolate

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Pull code về

```
git clone https://github.com/vietdai-bk/LTDNT_isolate_example/
```

## Download file json để test

Trong link drive sau chứa file json 100MB: [large_json_data.json](https://drive.google.com/file/d/1_zC-oz8iak1vBIlNMdJiehbefJo5bKDt/view?usp=sharing)
Đặt file json và thư mục ***assets/large_json_data.json***.
Khai báo trong ```pubspec.yaml```:
```
flutter:
  assets:
    - assets/large_test_data.json
```

## Chạy code

```
flutter run --release
```

Nên chạy ở mode --release để đo hiệu năng như lúc phát hành ứng dụng
