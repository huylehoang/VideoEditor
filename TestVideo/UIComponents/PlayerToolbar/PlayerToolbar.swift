import UIKit
import AVFoundation

final class PlayerToolbar: UIView {
  private var asset: AVAsset

  var sliderChanged: ((CMTime) -> Void)?
  var playTrigger: (() -> Void)?

  private lazy var thumbnailSlider: ThumbnaiSlider = {
    let view = ThumbnaiSlider(asset: asset)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addTarget(self, action: #selector(thumbnailSliderChanged(_:)), for: .valueChanged)
    return view
  }()

  private lazy var playButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("PLAY", for: .normal)
    button.setTitleColor(.link, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    button.addTarget(self, action: #selector(playButtonDidTap(_:)), for: .touchUpInside)
    return button
  }()

  private lazy var timeStartLabel: UILabel = {
    return makeLabel(title: CMTime.zero.hoursMinutesSecondsFormatted, textAlignment: .left)
  }()

  private lazy var timeEndLabel: UILabel = {
    return makeLabel(title: asset.duration.hoursMinutesSecondsFormatted, textAlignment: .right)
  }()

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
    thumbnailSlider.replaceCurrentAsset(with: asset)
    timeStartLabel.text = CMTime.zero.hoursMinutesSecondsFormatted
    timeEndLabel.text = asset.duration.hoursMinutesSecondsFormatted
  }

  func setTime(_ time: CMTime) {
    let time = time.numericOrZero.clamped(to: .zero, and: asset.duration)

    if !thumbnailSlider.isTracking {
      thumbnailSlider.setTime(time, animated: true)
    }

    timeStartLabel.text = time.hoursMinutesSecondsFormatted
    let remainingTime = CMTimeSubtract(asset.duration, time)
    timeEndLabel.text = remainingTime.hoursMinutesSecondsFormatted
  }

  func setRate(_ rate: Bool) {
    playButton.setTitle(rate ? "PAUSE" : "PLAY", for: .normal)
  }
}

private extension PlayerToolbar {
  func setupView() {
    let vStackView = UIStackView()
    vStackView.translatesAutoresizingMaskIntoConstraints = false
    vStackView.axis = .vertical
    vStackView.alignment = .fill
    vStackView.distribution = .fill
    vStackView.spacing = 12
    addSubview(vStackView)
    let vStackViewConstraints = [
      vStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      vStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      vStackView.topAnchor.constraint(equalTo: topAnchor),
      vStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ]

    vStackView.addArrangedSubview(thumbnailSlider)
    let thumbnailTrackConstraints = [
      thumbnailSlider.heightAnchor.constraint(equalToConstant: 58),
    ]

    let timeContainer = UIView()
    timeContainer.translatesAutoresizingMaskIntoConstraints = false
    timeContainer.backgroundColor = .clear
    timeContainer.addSubview(playButton)
    timeContainer.addSubview(timeStartLabel)
    timeContainer.addSubview(timeEndLabel)
    vStackView.addArrangedSubview(timeContainer)
    let timeContainerConstraints = [
      playButton.centerXAnchor.constraint(equalTo: timeContainer.centerXAnchor),
      playButton.topAnchor.constraint(equalTo: timeContainer.topAnchor),
      playButton.bottomAnchor.constraint(equalTo: timeContainer.bottomAnchor),
      timeStartLabel.topAnchor.constraint(equalTo: timeContainer.topAnchor),
      timeStartLabel.leadingAnchor.constraint(equalTo: timeContainer.leadingAnchor),
      timeEndLabel.topAnchor.constraint(equalTo: timeContainer.topAnchor),
      timeEndLabel.trailingAnchor.constraint(equalTo: timeContainer.trailingAnchor),
    ]

    let constraints = vStackViewConstraints + thumbnailTrackConstraints + timeContainerConstraints
    NSLayoutConstraint.activate(constraints)
  }

  func makeLabel(title: String, textAlignment: NSTextAlignment) -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = title
    label.textAlignment = textAlignment
    label.textColor = .white
    label.font = .systemFont(ofSize: 11, weight: .regular)
    label.numberOfLines = 0
    return label
  }
}

// MARK: - IBActions
private extension PlayerToolbar {
  @objc func playButtonDidTap(_ sender: UIButton) {
    playTrigger?()
  }

  @objc func thumbnailSliderChanged(_ sender: ThumbnaiSlider) {
    sliderChanged?(sender.time)
  }
}
