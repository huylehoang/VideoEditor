//
//  MultipleVideoTranstionsViewController.swift
//  TestVideo
//
//  Created by Admin on 2/2/21.
//

import UIKit
import AVFoundation

final class MultipleVideoTranstionsViewController: UIViewController {
  private let clips: [AVAsset]
  private let videoTransition: VideoTransition
  private let playbackController: PlaybackController
  private let videoExporter: VideoExporter

  private lazy var playerView: PlayerView = {
    let view = PlayerView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .black
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
    let view = PlayerToolbar(asset: clips[0])
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private var asset: AVAsset
  private var videoComposition: AVVideoComposition?

  init(urls: [URL]) {
    clips = urls.map { AVAsset(url: $0) }
    videoTransition = VideoTransition()
    asset = AVAsset(url: urls[0])
    playbackController = PlaybackController(playerItem: AVPlayerItem(asset: asset))
    videoExporter = VideoExporter()
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    super.loadView()
    setupNavigationBar()
    setupView()
    setupTranstions()
    addObserver()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    playbackController.play()
  }
}

// MARK: - Setup
private extension MultipleVideoTranstionsViewController {
  func setupNavigationBar() {
    navigationController?.setNavigationBarHidden(false, animated: false)
    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    let exportButton = UIBarButtonItem(
      title: "Export",
      style: .plain,
      target: self,
      action: #selector(exportButtonDidTap(_:)))
    navigationItem.rightBarButtonItem = exportButton
  }

  func setupView() {
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

    view.addSubview(playerToolbar)
    let playerToolbarConstraints = [
      playerToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
      playerToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
      playerToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
    ]

    NSLayoutConstraint.activate(playerViewConstraints + indicatorConstraints + playerToolbarConstraints)
  }

  func setupTranstions() {
    do {
      try videoTransition.merge(clips, completion: { [weak self] result in
        guard let self = self else { return }
        self.asset = result.composition
        self.videoComposition = result.videoComposition
        let playerItem = AVPlayerItem(asset: self.asset)
        playerItem.videoComposition = self.videoComposition

        self.playbackController.smoothlySeek(to: .zero)
        self.playbackController.replaceCurrentItem(with: playerItem)

        self.playerToolbar.replaceCurrentAsset(with: self.asset)
        self.playerView.player = self.playbackController.player
      })
    } catch {
      print("Error while setting up transitions: \(error.localizedDescription)")
    }
  }

  func addObserver() {
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
}

// MARK: - IBActions
private extension MultipleVideoTranstionsViewController {
  @objc func exportButtonDidTap(_ sender: UIButton) {
    Utilites.authorizePhotoLibraryPermission(in: self) { [weak self] in
      guard let self = self else { return }
      self.indicator.startAnimating()
      self.videoExporter.exportAndSaveToAlbum(
        asset: self.asset,
        videoComposition: self.videoComposition,
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
