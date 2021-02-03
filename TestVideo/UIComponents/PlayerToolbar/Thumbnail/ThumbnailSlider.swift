import UIKit
import AVFoundation

/// Referene FrameGrabber github: https://github.com/arthurhammer/FrameGrabber
final class ThumbnaiSlider: UIControl {
  private var asset: AVAsset

  private lazy var handle: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isUserInteractionEnabled = false
    view.layer.cornerRadius = 4
    view.layer.cornerCurve = .continuous
    view.backgroundColor = .white
    return view
  }()

  private lazy var track: ThumbnailTrack = {
    let view = ThumbnailTrack(asset: asset)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isUserInteractionEnabled = false
    view.clipsToBounds = true
    view.layer.cornerRadius = 6
    view.layer.cornerCurve = .continuous
    view.layer.borderWidth = 1
    view.layer.borderColor = UIColor.white.cgColor
    return view
  }()

  private(set) var time: CMTime = .zero {
    didSet {
      updateHandlePosition()
    }
  }

  private var handleLeading: NSLayoutConstraint?
  private var updateAnimator: UIViewPropertyAnimator?

  private let handleWidth: CGFloat = 10
  private let verticalTrackInset: CGFloat = 8
  private let resetAnimationDuration: TimeInterval = 0.1
  private let animationDuration: TimeInterval = 0.05

  init(asset: AVAsset) {
    self.asset = asset
    super.init(frame: .zero)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func replaceCurrentAsset(with asset: AVAsset) {
    self.asset = asset
    track.replaceCurrentAsset(with: asset)
  }

  // MARK: - Tracking Touches

  override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    super.beginTracking(touch, with: event)
    let point = touch.location(in: self)
    return handle.frame.contains(point)
  }

  override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    super.continueTracking(touch, with: event)
    let position = touch.location(in: self).x
    time = UIControlHelper.trackTime(inView: self, for: position, withDuration: duration)
    sendActions(for: .valueChanged)
    return true
  }

  func setTime(_ time: CMTime, animated: Bool) {
    let actualDuration = self.time == duration ? resetAnimationDuration : animationDuration
    self.time = time.numericOrZero.clamped(to: .zero, and: duration)
    updateAnimator?.stopAnimation(true)
    guard animated else { return }
    updateAnimator = UIViewPropertyAnimator(
      duration: actualDuration,
      curve: .linear,
      animations: layoutIfNeeded)
    updateAnimator?.startAnimation()
  }
}

private extension ThumbnaiSlider {
  var duration: CMTime {
    return asset.duration
  }

  func setupView() {
    addSubview(track)
    let trackContrainst = [
      track.leadingAnchor.constraint(equalTo: leadingAnchor),
      track.trailingAnchor.constraint(equalTo: trailingAnchor),
      track.centerYAnchor.constraint(equalTo: centerYAnchor),
      track.heightAnchor.constraint(equalTo: heightAnchor, constant: -verticalTrackInset * 2),
    ]

    addSubview(handle)
    let handleLeading = handle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -handleWidth/2)
    self.handleLeading = handleLeading
    let handleConstraints = [
      handleLeading,
      handle.topAnchor.constraint(equalTo: topAnchor),
      handle.bottomAnchor.constraint(equalTo: bottomAnchor),
      handle.widthAnchor.constraint(equalToConstant: handleWidth),
    ]

    NSLayoutConstraint.activate(trackContrainst + handleConstraints)
  }

  func updateHandlePosition() {
    handleLeading?.constant = UIControlHelper.trackPosition(inView: self, for: time, withDuration: duration) - handleWidth/2
  }
}
