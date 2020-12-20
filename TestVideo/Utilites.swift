import UIKit
import Photos

enum Utilites {
  static func authorizePhotoLibraryPermission(
    in viewController: UIViewController,
    authorized: (() -> Void)? = nil
  ) {
    switch PHPhotoLibrary.authorizationStatus() {
    case .authorized:
      authorized?()
    case .notDetermined:
      let photoAuthorizationHandler = { (status: PHAuthorizationStatus) in
        guard status != .authorized else {
          authorized?()
          return
        }
        guard !Thread.isMainThread else {
          openAppSettings(from: viewController)
          return
        }
        // Call openAppSettings in main queue to avoid crash app
        DispatchQueue.main.async {
          openAppSettings(from: viewController)
        }
      }

      if #available(iOS 14, *) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly, handler: photoAuthorizationHandler)
      } else {
        PHPhotoLibrary.requestAuthorization(photoAuthorizationHandler)
      }
    default:
      openAppSettings(from: viewController)
    }
  }
}

private extension Utilites {
  static func openAppSettings(from viewController: UIViewController) {
    guard
      let appSettingUrl = URL(string: UIApplication.openSettingsURLString),
      UIApplication.shared.canOpenURL(appSettingUrl)
    else { return }
    let alertViewController = UIAlertController(
      title: "Permission Required",
      message: "This feature requires permission to continue",
      preferredStyle: .alert)
    alertViewController.addAction(.init(title: "Cancel", style: .cancel))
    alertViewController.addAction(.init(title: "Settings", style: .default, handler: { _ in
      UIApplication.shared.open(appSettingUrl)
    }))
  }
}
