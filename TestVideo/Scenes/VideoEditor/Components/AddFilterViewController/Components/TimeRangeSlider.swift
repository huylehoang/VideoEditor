import UIKit
import AVFoundation

final class TimeRangeSlider: UIControl, TimeAndPositionTrackable {
  enum TrackingThumb {
    case lower, upper, none
  }

  var from = CMTime.zero {
    didSet {
      guard updatedThumbForFirstTimeIfNeeded else { return }
      updateLowerThumbPosition()
    }
  }

  var to = CMTime.zero {
    didSet {
      guard updatedThumbForFirstTimeIfNeeded else { return }
      updateUpperThumbPosision()
    }
  }

  private let duration: CMTime
  private let thumbRadius: CGFloat = 15
  private let trackingHeight: CGFloat = 3
  private let thumbColor: UIColor = .white
  private let trackingBackgroundColor: UIColor = .lightGray
  private let highlightBackgroundColor: UIColor = .link

  private var timeRangeThreshold: CMTime {
    return CMTimeMultiplyByRatio(duration, multiplier: 1, divisor: 5)
  }

  private var timeForAddOrSubtractIfReachThreshold: CMTime {
    return CMTimeMultiplyByRatio(timeRangeThreshold, multiplier: 1, divisor: 2)
  }

  private var updateAnimator: UIViewPropertyAnimator?
  private var updatedThumbForFirstTimeIfNeeded = false
  private var lowerThumbLeading: NSLayoutConstraint?
  private var upperThumbTrailing: NSLayoutConstraint?

  private var trackingThumb: TrackingThumb = .none

  private lazy var trackingView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = trackingBackgroundColor
    view.layer.cornerRadius = trackingHeight / 2
    return view
  }()

  private lazy var lowerThumb: UIView = {
    return makeThumbView()
  }()

  private lazy var upperThumb: UIView = {
    return makeThumbView()
  }()

  private lazy var fromTimeLabel: UILabel = {
    return makeTimeLabel(title: from.hoursMinutesSecondsFormatted, textAlignment: .left)
  }()

  private lazy var toTimeLabel: UILabel = {
    return makeTimeLabel(title: to.hoursMinutesSecondsFormatted, textAlignment: .right)
  }()

  init(duration: CMTime) {
    self.duration = duration
    super.init(frame: .zero)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    super.beginTracking(touch, with: event)
    let point = touch.location(in: self)
    if lowerThumb.frame.contains(point) {
      trackingThumb = .lower
    } else if upperThumb.frame.contains(point) {
      trackingThumb = .upper
    } else {
      trackingThumb = .none
    }
    return trackingThumb != .none
  }

  override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let position = touch.location(in: self).x
    let newTime = trackTime(for: position, withDuration: duration)
    switch trackingThumb {
    case .lower:
      return updateFromTime(newTime: newTime)
    case .upper:
      return updateToTime(newTime: newTime)
    default:
      return false
    }
  }

  override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    super.endTracking(touch, with: event)
    trackingThumb = .none
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    guard !updatedThumbForFirstTimeIfNeeded else { return }
    updateLowerThumbPosition()
    updateUpperThumbPosision()
    updatedThumbForFirstTimeIfNeeded = true
  }
}

// MARK: Setup
private extension TimeRangeSlider {
  func setupView() {
    addSubview(lowerThumb)
    let fixLowerThumbLeading = lowerThumb.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor)
    let dynamicLowerThumbLeading = lowerThumb.leadingAnchor.constraint(equalTo: leadingAnchor)
    fixLowerThumbLeading.priority = .required
    dynamicLowerThumbLeading.priority = .defaultHigh
    lowerThumbLeading = dynamicLowerThumbLeading

    addSubview(upperThumb)
    let fixUpperThumbTrailing = upperThumb.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let dynamicUpperThumbTrailing = upperThumb.trailingAnchor.constraint(equalTo: trailingAnchor)
    fixUpperThumbTrailing.priority = .required
    dynamicUpperThumbTrailing.priority = .defaultHigh
    upperThumbTrailing = dynamicUpperThumbTrailing

    let thumbContraints = [
      fixLowerThumbLeading,
      dynamicLowerThumbLeading,
      lowerThumb.bottomAnchor.constraint(equalTo: bottomAnchor),
      lowerThumb.widthAnchor.constraint(equalToConstant: thumbRadius),
      lowerThumb.heightAnchor.constraint(equalToConstant: thumbRadius),
      fixUpperThumbTrailing,
      dynamicUpperThumbTrailing,
      upperThumb.bottomAnchor.constraint(equalTo: lowerThumb.bottomAnchor),
      upperThumb.widthAnchor.constraint(equalToConstant: thumbRadius),
      upperThumb.heightAnchor.constraint(equalToConstant: thumbRadius),
    ]

    insertSubview(trackingView, belowSubview: lowerThumb)
    let trackingViewContraints = [
      trackingView.centerYAnchor.constraint(equalTo: lowerThumb.centerYAnchor),
      trackingView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: thumbRadius / 2),
      trackingView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -thumbRadius / 2),
      trackingView.heightAnchor.constraint(equalToConstant: trackingHeight),
    ]

    let highlightView = UIView()
    highlightView.translatesAutoresizingMaskIntoConstraints = false
    highlightView.backgroundColor = highlightBackgroundColor
    highlightView.layer.cornerRadius = trackingHeight / 2
    insertSubview(highlightView, belowSubview: lowerThumb)
    let highlightViewConstraints = [
      highlightView.centerYAnchor.constraint(equalTo: lowerThumb.centerYAnchor),
      highlightView.heightAnchor.constraint(equalToConstant: trackingHeight),
      highlightView.leadingAnchor.constraint(equalTo: lowerThumb.centerXAnchor),
      highlightView.trailingAnchor.constraint(equalTo: upperThumb.centerXAnchor),
    ]

    addSubview(fromTimeLabel)
    addSubview(toTimeLabel)
    let timeLabelConstraints = [
      fromTimeLabel.bottomAnchor.constraint(equalTo: lowerThumb.topAnchor, constant: -8),
      fromTimeLabel.topAnchor.constraint(equalTo: topAnchor),
      fromTimeLabel.leadingAnchor.constraint(equalTo: lowerThumb.leadingAnchor),
      toTimeLabel.topAnchor.constraint(equalTo: fromTimeLabel.topAnchor),
      toTimeLabel.trailingAnchor.constraint(equalTo: upperThumb.trailingAnchor),
    ]

    let constraints = thumbContraints + trackingViewContraints + highlightViewConstraints + timeLabelConstraints
    NSLayoutConstraint.activate(constraints)

    subviews.forEach { $0.isUserInteractionEnabled = false }
  }
}

// MARK: Factory Method
private extension TimeRangeSlider {
  func updateFromTime(newTime: CMTime) -> Bool {
    guard CMTimeSubtract(to, newTime) > timeRangeThreshold else {
      from = CMTimeSubtract(from, timeForAddOrSubtractIfReachThreshold).clamped(to: .zero, and: duration)
      animateThumb()
      return false
    }
    from = newTime
    return true
  }

  func updateToTime(newTime: CMTime) -> Bool {
    guard CMTimeSubtract(newTime, from) > timeRangeThreshold else {
      to = CMTimeAdd(to, timeForAddOrSubtractIfReachThreshold).clamped(to: .zero, and: duration)
      animateThumb()
      return false
    }
    to = newTime
    return true
  }

  func animateThumb() {
    updateAnimator?.stopAnimation(true)
    updateAnimator = UIViewPropertyAnimator(
      duration: 0.2,
      curve: .linear,
      animations: layoutIfNeeded)
    updateAnimator?.startAnimation()
  }

  func updateLowerThumbPosition() {
    lowerThumbLeading?.constant = trackPosition(for: from, withDuration: duration)
    fromTimeLabel.text = from.hoursMinutesSecondsFormatted
  }

  func updateUpperThumbPosision() {
    upperThumbTrailing?.constant = -(frame.width - trackPosition(for: to, withDuration: duration))
    toTimeLabel.text = to.hoursMinutesSecondsFormatted
  }

  func makeThumbView() -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = thumbColor
    view.layer.cornerRadius = thumbRadius / 2
    return view
  }

  func makeTimeLabel(title: String, textAlignment: NSTextAlignment) -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .black
    label.font = .systemFont(ofSize: 12, weight: .regular)
    label.textAlignment = textAlignment
    label.text = title
    return label
  }
}
