# interview_demo

通过原图的遮罩图实现抠图效果

## 开发环境配置如下
```shell
╰ flutter doctor -v
[✓] Flutter (Channel stable, 3.13.9, on macOS 13.5 22G74 darwin-x64, locale zh-Hans-CN)
    • Flutter version 3.13.9 on channel stable at /Users/liuyanfeng/Library/flutter
    • Upstream repository git@github.com:flutter/flutter.git
    • Framework revision d211f42860 (9 months ago), 2023-10-25 13:42:25 -0700
    • Engine revision 0545f8705d
    • Dart version 3.1.5
    • DevTools version 2.25.0
    • Pub download mirror https://pub.flutter-io.cn
    • Flutter download mirror https://storage.flutter-io.cn

[!] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
    • Android SDK at /Users/liuyanfeng/Library/Android/sdk
    ✗ cmdline-tools component is missing
      Run `path/to/sdkmanager --install "cmdline-tools;latest"`
      See https://developer.android.com/studio/command-line for more details.
    ✗ Android license status unknown.
      Run `flutter doctor --android-licenses` to accept the SDK licenses.
      See https://flutter.dev/docs/get-started/install/macos#android-setup for more details.

[✓] Xcode - develop for iOS and macOS (Xcode 14.3.1)
    • Xcode at /Applications/Xcode.app/Contents/Developer
    • Build 14E300c
    • CocoaPods version 1.12.1

[✓] Chrome - develop for the web
    • Chrome at /Applications/Google Chrome.app/Contents/MacOS/Google Chrome

[✓] IntelliJ IDEA Ultimate Edition (version 2023.2.6)
    • IntelliJ at /Applications/IntelliJ IDEA.app
    • Flutter plugin version 76.3.4
    • Dart plugin version 232.9559.10

[✓] Connected device (3 available)
    • iPhone 14 (mobile) • A21BA52B-3DD6-4B72-8230-41C56F302A44 • ios            • com.apple.CoreSimulator.SimRuntime.iOS-16-4 (simulator)
    • macOS (desktop)    • macos                                • darwin-x64     • macOS 13.5 22G74 darwin-x64
    • Chrome (web)       • chrome                               • web-javascript • Google Chrome 127.0.6533.89

[✓] Network resources
    • All expected network resources are available.
```
## 效果图
    ![抠图效果预览](https://github.com/lyf571321556/interview_demo/blob/main/result.png)