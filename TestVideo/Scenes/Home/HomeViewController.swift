import UIKit

final class HomeViewController: UIViewController {
  override func loadView() {
    super.loadView()
    setupView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    Utilites.authorizePhotoLibraryPermission(in: self)
  }
}

private extension HomeViewController {
  func setupView() {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("UPLOAD", for: .normal)
    button.setTitleColor(.link, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    button.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
    view.addSubview(button)
    let buttonContraints = [
      button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ]
    NSLayoutConstraint.activate(buttonContraints)
  }

  @objc func buttonDidTap(_ sender: UIButton) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.sourceType = .savedPhotosAlbum
    imagePickerController.mediaTypes = ["public.movie"]
    present(imagePickerController, animated: true)
  }
}

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
  ) {
    picker.dismiss(animated: true)
    guard let videoUrl = info[.mediaURL] as? URL else { return }
    let videoEditorViewController = VideoEditorViewController(videoUrl: videoUrl)
    videoEditorViewController.modalPresentationStyle = .fullScreen
    present(videoEditorViewController, animated: true)
  }
}
