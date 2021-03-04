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
    let loadVideoButton = UIButton()
    loadVideoButton.translatesAutoresizingMaskIntoConstraints = false
    loadVideoButton.setTitle("LOAD VIDEO", for: .normal)
    loadVideoButton.setTitleColor(.link, for: .normal)
    loadVideoButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    loadVideoButton.addTarget(self, action: #selector(loadVideoButtonDidTap(_:)), for: .touchUpInside)
    view.addSubview(loadVideoButton)

    let mergeVideosButton = UIButton()
    mergeVideosButton.translatesAutoresizingMaskIntoConstraints = false
    mergeVideosButton.setTitle("MERGE VIDEOS", for: .normal)
    mergeVideosButton.setTitleColor(.link, for: .normal)
    mergeVideosButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    mergeVideosButton.addTarget(self, action: #selector(mergeVideoButtonDidtap(_:)), for: .touchUpInside)
    view.addSubview(mergeVideosButton)

    let constraints = [
      loadVideoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      loadVideoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      mergeVideosButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      mergeVideosButton.topAnchor.constraint(equalTo: loadVideoButton.bottomAnchor, constant: 24),
    ]
    NSLayoutConstraint.activate(constraints)
  }

  @objc func loadVideoButtonDidTap(_ sender: UIButton) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.sourceType = .savedPhotosAlbum
    imagePickerController.mediaTypes = ["public.movie"]
    present(imagePickerController, animated: true)
  }

  @objc func mergeVideoButtonDidtap(_ sender: UIButton) {
    let transitionPicker = TransitionPickerViewController()
    transitionPicker.delegate = self
    navigationController?.present(transitionPicker, animated: true)
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
    navigationController?.pushViewController(videoEditorViewController, animated: true)
  }
}

extension HomeViewController: TransitionPickerViewControllerDelegate {
  func transitionPickerViewController(
    _ picker: TransitionPickerViewController,
    effects: [VideoTransition.Effect]) {
    picker.dismiss(animated: true)
    guard
      let url1 = Bundle.main.url(forResource: "cut1.mp4", withExtension: nil),
      let url2 = Bundle.main.url(forResource: "cut2.mp4", withExtension: nil),
      let url3 = Bundle.main.url(forResource: "cut3.mp4", withExtension: nil)
    else { return }
    let multipleVideoTransition = MultipleVideoTranstionsViewController(
      urls: [url1, url2, url3],
      effects: effects)
    navigationController?.pushViewController(multipleVideoTransition, animated: true)
  }
}
