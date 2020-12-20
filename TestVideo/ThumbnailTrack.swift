import UIKit
import AVFoundation

/// Referene FrameGrabber github: https://github.com/arthurhammer/FrameGrabber
class ThumbnailTrack: UIView {
  private lazy var thumbnailStack: UIStackView = {
    let view = UIStackView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .horizontal
    view.alignment = .fill
    view.distribution = .fillEqually
    view.spacing = 0
    return view
  }()

  private let imageGenerator: AVAssetImageGenerator
  private let duration: CMTime
  private let scaleFactor: CGFloat = 2

  init(asset: AVAsset) {
    imageGenerator = Self.makeImageGenerator(for: asset)
    duration = asset.duration.numericOrZero
    super.init(frame: .zero)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    startGenerateImages()
  }
}

private extension ThumbnailTrack {
  func setupView() {
    setupThumbnailStack()
  }

  func startGenerateImages() {
    guard thumbnailViews.isEmpty else { return }
    setupThumbnailViews()
    generateImages()
  }

  func setupThumbnailStack() {
    addSubview(thumbnailStack)
    let thumbnailStackConstraints = [
      thumbnailStack.topAnchor.constraint(equalTo: topAnchor),
      thumbnailStack.bottomAnchor.constraint(equalTo: bottomAnchor),
      thumbnailStack.leadingAnchor.constraint(equalTo: leadingAnchor),
      thumbnailStack.trailingAnchor.constraint(equalTo: trailingAnchor),
    ]
    NSLayoutConstraint.activate(thumbnailStackConstraints)
  }

  func setupThumbnailViews() {
    guard
      let thumbnailAspectRatio = imageGenerator.asset.dimensions,
      let thumbnailSize = thumbnailAspectRatio.aspectFitting(height: bounds.height),
      thumbnailSize.width != 0
    else { return }
    let amount = Int(ceil(bounds.width / thumbnailSize.width))
    (0..<amount).forEach { index in
      let imageView = ThumbnailImageView()
      imageView.backgroundColor = .lightGray
      imageView.contentMode = .scaleAspectFill
      imageView.clipsToBounds = true
      thumbnailStack.addArrangedSubview(imageView)
    }

    thumbnailStack.setNeedsLayout()
    thumbnailStack.layoutIfNeeded()
  }

  func generateImages() {
    imageGenerator.cancelAllCGImageGeneration()
    let times = thumbnailOffsets.map(time(for:)).map(NSValue.init)
    var index = -1
    imageGenerator.maximumSize = thumbnailViewSize.applying(.init(scaleX: scaleFactor, y: scaleFactor))
    imageGenerator.generateCGImagesAsynchronously(forTimes: times) {
      [weak self] _, image, _, status, _ in
      guard let self = self else { return }
      DispatchQueue.main.async {
        index += 1
        guard status != .cancelled else { return }
        let image = image.flatMap(UIImage.init)
        self.thumbnailViews[index].setImage(image)
      }
    }
  }
}

// MARK: - Private Static
private extension ThumbnailTrack {
  static private let timeTolerance = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

  static func makeImageGenerator(for asset: AVAsset) -> AVAssetImageGenerator {
    let generator = AVAssetImageGenerator(asset: asset)
    generator.requestedTimeToleranceBefore = timeTolerance
    generator.requestedTimeToleranceAfter = timeTolerance
    generator.appliesPreferredTrackTransform = true
    return generator
  }
}

// MARK: - Factory Methods
private extension ThumbnailTrack {
  private var thumbnailViews: [ThumbnailImageView] {
    return thumbnailStack.arrangedSubviews as? [ThumbnailImageView] ?? []
  }

  private var thumbnailOffsets: [CGFloat] {
    return thumbnailViews.map { thumbnailStack.convert($0.frame.origin, to: self).x }
  }

  private var thumbnailViewSize: CGSize {
    return thumbnailViews.first?.bounds.size ?? .zero
  }

  func time(for trackPosition: CGFloat) -> CMTime {
    let trackFrame = thumbnailStack.bounds
    let range = trackFrame.maxX - trackFrame.minX
    guard range != 0 else { return .zero }

    let progress = (trackPosition - trackFrame.minX) / range
    let time = CMTimeMultiplyByFloat64(duration, multiplier: Float64(progress))

    return time.numericOrZero.clamped(to: .zero, and: duration)
  }
}

private class ThumbnailImageView: UIImageView {
  private let fadeDuration: TimeInterval = 0.3

  func setImage(_ image: UIImage?, animated: Bool = true) {
    if animated {
      UIView.transition(
        with: self,
        duration: fadeDuration,
        options: [.transitionCrossDissolve, .beginFromCurrentState],
        animations: { self.image = image }
      )
    } else {
      self.image = image
    }
  }
}

private extension AVAsset {
  var dimensions: CGSize? {
    guard let videoTrack = tracks(withMediaType: .video).first else { return nil }
    return videoTrack.naturalSize.applying(videoTrack.preferredTransform)
  }
}

private extension CGSize {
  func aspectFitting(height targetHeight: CGFloat) -> CGSize? {
    guard height != 0 else { return nil }
    let heightScale = targetHeight / abs(height)
    return CGSize(width: abs(width) * heightScale, height: targetHeight)
  }

  var scaledToScreen: CGSize {
    let scale = UIScreen.main.scale
    return CGSize(width: width * scale, height: height * scale)
  }
}
