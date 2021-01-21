import UIKit

final class FilterSlider: UIControl {
  var minimumValue: Float = 0.0
  var maximumValue: Float = 1.0

  var value: Float = 0.0 {
    didSet {
      guard updatedThumbForFirstTimeIfNeeded else { return }
      updateThumbPosition()
    }
  }

  private let thumbRadius: CGFloat = 15
  private let trackingHeight: CGFloat = 3
  private let thumbColor: UIColor = .white
  private let trackingBackgroundColor: UIColor = .lightGray
  private let highlightBackgroundColor: UIColor = .link

  private var updatedThumbForFirstTimeIfNeeded = false
  private var thumbLeading: NSLayoutConstraint?

  private var valueRange: Float { maximumValue - minimumValue }

  private lazy var trackingView: UIView = {
    let progessView = UIView()
    progessView.translatesAutoresizingMaskIntoConstraints = false
    progessView.backgroundColor = trackingBackgroundColor
    progessView.layer.cornerRadius = trackingHeight / 2
    return progessView
  }()

  private lazy var thumb: UIView = {
    return makeThumbView()
  }()

  private lazy var valueLabel: UILabel = {
    return makeValueLabel(title: value.description)
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    super.beginTracking(touch, with: event)
    let point = touch.location(in: self)
    return thumb.frame.contains(point)
  }

  override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    super.continueTracking(touch, with: event)
    let position = touch.location(in: self).x
    value = trackValue(for: position - thumbRadius/2)
    return true
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    guard !updatedThumbForFirstTimeIfNeeded else { return }
    updateThumbPosition(animated: false)
    updatedThumbForFirstTimeIfNeeded = true
  }
}

// MARK: Setup
private extension FilterSlider {
  func setupView() {
    addSubview(thumb)
    let fixThumbLeading = thumb.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor)
    let fixThumbTrailing = thumb.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let dynamicThumbLeading = thumb.leadingAnchor.constraint(equalTo: leadingAnchor)
    fixThumbLeading.priority = .required
    fixThumbTrailing.priority = .required
    dynamicThumbLeading.priority = .defaultHigh
    thumbLeading = dynamicThumbLeading

    let thumbConstraints = [
      fixThumbLeading,
      fixThumbTrailing,
      dynamicThumbLeading,
      thumb.bottomAnchor.constraint(equalTo: bottomAnchor),
      thumb.widthAnchor.constraint(equalToConstant: thumbRadius),
      thumb.heightAnchor.constraint(equalToConstant: thumbRadius),
    ]

    insertSubview(trackingView, belowSubview: thumb)
    let trackingViewContraints = [
      trackingView.centerYAnchor.constraint(equalTo: thumb.centerYAnchor),
      trackingView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: thumbRadius / 2),
      trackingView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -thumbRadius / 2),
      trackingView.heightAnchor.constraint(equalToConstant: trackingHeight),
    ]

    let highlightView = UIView()
    highlightView.translatesAutoresizingMaskIntoConstraints = false
    highlightView.backgroundColor = highlightBackgroundColor
    highlightView.layer.cornerRadius = trackingHeight / 2
    insertSubview(highlightView, belowSubview: thumb)
    let highlightViewConstraints = [
      highlightView.centerYAnchor.constraint(equalTo: thumb.centerYAnchor),
      highlightView.heightAnchor.constraint(equalToConstant: trackingHeight),
      highlightView.leadingAnchor.constraint(equalTo: trackingView.leadingAnchor),
      highlightView.trailingAnchor.constraint(equalTo: thumb.centerXAnchor),
    ]

    addSubview(valueLabel)
    let valueLabelConstraints = [
      valueLabel.bottomAnchor.constraint(equalTo: thumb.topAnchor, constant: -8),
      valueLabel.topAnchor.constraint(equalTo: topAnchor),
      valueLabel.centerXAnchor.constraint(equalTo: thumb.centerXAnchor),
    ]

    let constraints = thumbConstraints + trackingViewContraints + highlightViewConstraints + valueLabelConstraints
    NSLayoutConstraint.activate(constraints)

    subviews.forEach { $0.isUserInteractionEnabled = false }
  }
}

// MARK: Factory methods
private extension FilterSlider {
  func updateThumbPosition(animated: Bool = true) {
    thumbLeading?.constant = trackPosition(for: value) - thumbRadius/2
    if animated {
      UIView.animate(withDuration: 0.1, animations: layoutIfNeeded)
    }
    valueLabel.text = value.description
  }

  func trackValue(for position: CGFloat) -> Float {
    let trackFrame = trackingView.frame
    let range = trackFrame.maxX - trackFrame.minX
    let leading = position - trackFrame.minX

    guard range != 0, leading >= 0 else { return 0 }

    let progress = leading / range
    let value = Float(progress) * valueRange
    let roundedValue = value.roundToPlaces()

    return roundedValue.clamped(to: minimumValue, and: maximumValue)
  }

  func trackPosition(for value: Float) -> CGFloat {
    let trackFrame = trackingView.frame

    let progress = value / valueRange
    let range = trackFrame.maxX - trackFrame.minX
    let position = trackFrame.minX + CGFloat(progress) * range

    return position.clamped(to: trackFrame.minX, and: trackFrame.maxX)
  }

  func makeThumbView() -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = thumbColor
    view.layer.cornerRadius = thumbRadius / 2
    return view
  }

  func makeValueLabel(title: String) -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .black
    label.font = .systemFont(ofSize: 12, weight: .regular)
    label.text = title
    return label
  }
}

private extension Float {
  /// Rounds the double to decimal places value
  func roundToPlaces(places: Int = 2) -> Float {
    let divisor = pow(10.0, Float(places))
    return (self * divisor).rounded() / divisor
  }
}
