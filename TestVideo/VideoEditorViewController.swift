import UIKit
import AVFoundation
import Photos

final class VideoEditorViewController: UIViewController {
  private let asset: AVAsset
  private let videoCompositor: VideoCompositor
  private let playbackController: PlaybackController
  private let videoExporter: VideoExporter

  private lazy var playerView: PlayerView = {
    let view = PlayerView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .black
    view.player = playbackController.player
    return view
  }()

  private lazy var indicator: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .large)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.color = .systemBlue
    view.hidesWhenStopped = true
    return view
  }()

  private lazy var playerToolbar: PlayerToolbar = {
    let view = PlayerToolbar(asset: asset)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  init(videoUrl: URL) {
    asset = AVAsset(url: videoUrl)
    videoCompositor = VideoCompositor(duration: asset.duration.seconds)
    playbackController = PlaybackController(
      asset: asset,
      playerItem: videoCompositor.makePlayerItemWithComposition(for: asset))
    videoExporter = VideoExporter()
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    super.loadView()
    setupViews()
    setupObserver()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    playbackController.play()
  }
}

// MARK: Setup Views
private extension VideoEditorViewController {
  func setupViews() {
    setupBasicView()
    setupPlayerToolbar()
    setupFilterOptionsView()
  }

  func setupBasicView() {
    view.addSubview(playerView)
    let playerViewConstraints = [
      playerView.topAnchor.constraint(equalTo: view.topAnchor),
      playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ]
    view.addSubview(indicator)
    let indicatorConstraints = [
      indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ]
    NSLayoutConstraint.activate(playerViewConstraints + indicatorConstraints)
  }

  func setupFilterOptionsView() {
    let filterOptionsView = FilterOptionsView(duration: asset.duration.seconds)
    filterOptionsView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(filterOptionsView)
    filterOptionsView.layer.cornerRadius = 12
    let filterOptionViewContraints = [
      filterOptionsView.topAnchor.constraint(equalTo: view.topAnchor, constant: -12),
      filterOptionsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      filterOptionsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ]
    NSLayoutConstraint.activate(filterOptionViewContraints)

    filterOptionsView.blurChanged = { [weak self] value in
      self?.videoCompositor.updateBlur(value)
    }

    filterOptionsView.brightnessChanged = { [weak self] value in
      self?.videoCompositor.updateBrightness(value)
    }

    filterOptionsView.saturationChanged = { [weak self] value in
      self?.videoCompositor.updateSaturation(value)
    }

    filterOptionsView.addStickerTapped = { [weak self] in
      self?.playerView.addSticker()
    }

    filterOptionsView.backTapped = { [weak self] in
      self?.dismiss(animated: true)
    }

    filterOptionsView.saveTapped = { [weak self] in
      guard let self = self else { return }
      self.saveVideoToAlbum()
    }
    
    filterOptionsView.setupObserveValueChanged()
  }

  func setupPlayerToolbar() {
    view.addSubview(playerToolbar)
    let playerToolbarConstraints = [
      playerToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
      playerToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
      playerToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
    ]
    NSLayoutConstraint.activate(playerToolbarConstraints)
  }
}

private extension VideoEditorViewController {
  func setupObserver() {
    playbackController.currentTime = { [weak self] time in
      self?.playerToolbar.setTime(time)
    }

    playbackController.currentRate = { [weak self] rate in
      self?.playerToolbar.setRate(rate)
    }

    playerToolbar.sliderChanged = { [weak self] time in
      self?.playbackController.smoothlySeek(to: time)
    }

    playerToolbar.playTrigger = { [weak self] in
      self?.playbackController.playOrPause()
    }
  }

  func saveVideoToAlbum() {
    let videoComposition = videoCompositor.makeExportVideoComposition(asset: asset, playerView: playerView)
    Utilites.authorizePhotoLibraryPermission(in: self) { [weak self] in
      guard let self = self else { return }
      self.indicator.startAnimating()
      self.videoExporter.exportAndSaveToAlbum(
        asset: self.asset,
        videoComposition: videoComposition,
        completion: { errorMessage in
          DispatchQueue.main.async { [weak self] in
            self?.indicator.stopAnimating()
            let alertVC = UIAlertController(
              title: errorMessage == nil ? "OH YEAH!!!" : "Error",
              message: errorMessage ?? "Saved edited video to album",
              preferredStyle: .alert)
            let alertAction = UIAlertAction(
              title: errorMessage == nil ? "Great" : "Cancel",
              style: .default, handler: { _ in
                if errorMessage == nil {
                  self?.dismiss(animated: true)
                }
            })
            alertVC.addAction(alertAction)
            self?.present(alertVC, animated: true)
          }
        })
    }
  }
}
