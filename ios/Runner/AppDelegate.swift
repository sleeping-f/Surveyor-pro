import Flutter
import Photos
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let channelName = "surveyor_pro/gallery"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as? FlutterViewController
    if let controller = controller {
      let channel = FlutterMethodChannel(
        name: channelName,
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "saveImage" else {
          result(FlutterMethodNotImplemented)
          return
        }

        guard
          let arguments = call.arguments as? [String: Any],
          let filePath = arguments["filePath"] as? String
        else {
          result(
            FlutterError(code: "invalid_args", message: "File path is missing.", details: nil)
          )
          return
        }

        self?.saveImageToGallery(filePath: filePath, result: result)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  private func saveImageToGallery(filePath: String, result: @escaping FlutterResult) {
    let fileUrl = URL(fileURLWithPath: filePath)
    PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
      guard status == .authorized || status == .limited else {
        DispatchQueue.main.async {
          result(
            FlutterError(
              code: "permission_denied",
              message: "Photo library permission is required.",
              details: nil
            )
          )
        }
        return
      }

      PHPhotoLibrary.shared().performChanges(
        {
          PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileUrl)
        },
        completionHandler: { success, error in
          DispatchQueue.main.async {
            if success {
              result(filePath)
            } else {
              result(
                FlutterError(
                  code: "save_failed",
                  message: error?.localizedDescription ?? "Gallery save failed.",
                  details: nil
                )
              )
            }
          }
        }
      )
    }
  }
}
