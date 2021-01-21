import UIKit
import AVFoundation

final class FilterOptionsView: UIView {
  typealias FilterTapped = (Int) -> Void
  typealias Tapped = () -> Void

  private let duration: Double

  private lazy var vStackView: UIStackView = {
    let view = UIStackView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .vertical
    view.alignment = .fill
    view.distribution = .fill
    view.spacing = 15
    return view
  }()

  private lazy var blurOption: FilterOption = {
    return makeFilterOption(title: "APPLY BLUR", tag: Filter.Kind.blur().tag)
  }()

  private lazy var brightnessOption: FilterOption = {
    return makeFilterOption(title: "APPLY BRIGHTNESS", tag: Filter.Kind.brightness().tag)
  }()

  private lazy var saturationOption: FilterOption = {
    return makeFilterOption(title: "APPLY SATURATION", tag: Filter.Kind.saturation().tag)
  }()

  private lazy var thresholdOption: FilterOption = {
    return makeFilterOption(title: "APPLY THRESHOLD", tag: Filter.Kind.threshold().tag)
  }()

  private lazy var addStickerButtonContainer: UIView = {
    return makeContainerView()
  }()

  private lazy var backAndExportButtonContainer: UIView = {
    let view = makeContainerView()
    view.isHidden = true
    return view
  }()

  var filterTapped: FilterTapped?
  var addStickerTapped: Tapped?
  var backTapped: Tapped?
  var saveTapped: Tapped?

  private var expandAnimator: UIViewPropertyAnimator?

  init(duration: Double) {
    self.duration = duration
    super.init(frame: .zero)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func filterTimeRangeUpdated(filter: Filter) {
    let timeRange: String = {
      if filter.isAvailable {
        return "\(filter.timeRange.from.hoursMinutesSecondsFormatted) -> \(filter.timeRange.to.hoursMinutesSecondsFormatted)"
      } else {
        return ""
      }
    }()

    switch filter.kind {
    case .blur:
      blurOption.setTimeRange(timeRange)
    case .brightness:
      brightnessOption.setTimeRange(timeRange)
    case .saturation:
      saturationOption.setTimeRange(timeRange)
    case .threshold:
      thresholdOption.setTimeRange(timeRange)
    default:
      break
    }
  }
}

private extension FilterOptionsView {
  var isExpanding: Bool {
    return backAndExportButtonContainer.isHidden
  }

  func setupView() {
    backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    addSubview(vStackView)
    let vStackViewConstraints = [
      vStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24),
      vStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
      vStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
      vStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ]
    NSLayoutConstraint.activate(vStackViewConstraints)
    setupFiltersView()
    setupBackAndExportButton()
    setupExpandButton()
  }

  func setupFiltersView() {
    vStackView.addArrangedSubview(blurOption)
    vStackView.addArrangedSubview(brightnessOption)
    vStackView.addArrangedSubview(saturationOption)
    vStackView.addArrangedSubview(thresholdOption)
    vStackView.addArrangedSubview(addStickerButtonContainer)
    let button = makeButton(title: "ADD RANDOM STICKER (DOUTAP FOR REMOVING)", tag: 0)
    button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    addStickerButtonContainer.addSubview(button)
    let addStickersButtonContainerConstraints = [
      button.topAnchor.constraint(equalTo: addStickerButtonContainer.topAnchor),
      button.bottomAnchor.constraint(equalTo: addStickerButtonContainer.bottomAnchor),
      button.leadingAnchor.constraint(equalTo: addStickerButtonContainer.leadingAnchor),
    ]
    NSLayoutConstraint.activate(addStickersButtonContainerConstraints)
  }

  func setupBackAndExportButton() {
    vStackView.addArrangedSubview(backAndExportButtonContainer)
    let backButton = makeButton(title: "BACK", tag: 1)
    backButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    backAndExportButtonContainer.addSubview(backButton)
    let saveButton = makeButton(title: "SAVE TO ALBUM", tag: 2)
    saveButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    backAndExportButtonContainer.addSubview(saveButton)
    let backAndExportButtonContainerConstraints = [
      backButton.topAnchor.constraint(equalTo: backAndExportButtonContainer.topAnchor),
      backButton.bottomAnchor.constraint(equalTo: backAndExportButtonContainer.bottomAnchor),
      backButton.leadingAnchor.constraint(equalTo: backAndExportButtonContainer.leadingAnchor),
      saveButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
      saveButton.trailingAnchor.constraint(equalTo: backAndExportButtonContainer.trailingAnchor),
    ]
    NSLayoutConstraint.activate(backAndExportButtonContainerConstraints)
  }

  func setupExpandButton() {
    vStackView.setCustomSpacing(0, after: addStickerButtonContainer)
    vStackView.setCustomSpacing(0, after: backAndExportButtonContainer)
    let expandContainer = makeContainerView()
    vStackView.addArrangedSubview(expandContainer)

    let expandHandle = UIView()
    expandHandle.translatesAutoresizingMaskIntoConstraints = false
    expandHandle.backgroundColor = .white
    expandHandle.layer.cornerRadius = 3
    expandContainer.addSubview(expandHandle)
    let expandHandleConstraints = [
      expandHandle.centerXAnchor.constraint(equalTo: expandContainer.centerXAnchor),
      expandHandle.topAnchor.constraint(equalTo: expandContainer.topAnchor, constant: 8),
      expandHandle.bottomAnchor.constraint(equalTo: expandContainer.bottomAnchor, constant: -8),
      expandHandle.heightAnchor.constraint(equalToConstant: 6),
      expandHandle.widthAnchor.constraint(equalToConstant: 60),
    ]

    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(expandTapped(_:)), for: .touchUpInside)
    expandContainer.addSubview(button)
    let buttonConstraints = [
      button.leadingAnchor.constraint(equalTo: expandContainer.leadingAnchor),
      button.trailingAnchor.constraint(equalTo: expandContainer.trailingAnchor),
      button.topAnchor.constraint(equalTo: expandContainer.topAnchor),
      button.bottomAnchor.constraint(equalTo: expandContainer.bottomAnchor),
    ]

    let constraints = expandHandleConstraints + buttonConstraints
    NSLayoutConstraint.activate(constraints)
  }

  func makeFilterOption(title: String, tag: Int) -> FilterOption {
    let view = FilterOption(title: title)
    view.tag = tag
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(filterTapped(_:)))
    tapGesture.numberOfTapsRequired = 1
    view.isUserInteractionEnabled = true
    view.addGestureRecognizer(tapGesture)
    return view
  }

  func makeButton(title: String, tag: Int) -> UIButton {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.tag = tag
    button.setTitle(title, for: .normal)
    button.setTitleColor(.link, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
    return button
  }

  func makeContainerView() -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    return view
  }
}

// MARK: IBAction
private extension FilterOptionsView {
  @objc func filterTapped(_ sender: UITapGestureRecognizer) {
    guard let view = sender.view else { return }
    filterTapped?(view.tag)
  }

  @objc func buttonTapped(_ sender: UIButton) {
    switch sender.tag {
    case 0: addStickerTapped?()
    case 1: backTapped?()
    case 2: saveTapped?()
    default: break
    }
  }

  @objc func expandTapped(_ sender: UIButton) {
    expandAnimator?.stopAnimation(true)
    expandAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .linear, animations: toggle)
    expandAnimator?.startAnimation()
  }

  func toggle() {
    // alpha
    blurOption.alpha = isExpanding ? 0 : 1
    brightnessOption.alpha = isExpanding ? 0 : 1
    saturationOption.alpha = isExpanding ? 0 : 1
    thresholdOption.alpha = isExpanding ? 0 : 1
    addStickerButtonContainer.alpha = isExpanding ? 0 : 1
    backAndExportButtonContainer.alpha = isExpanding ? 1 : 0

    // isHidden
    blurOption.isHidden = isExpanding
    brightnessOption.isHidden = isExpanding
    saturationOption.isHidden = isExpanding
    thresholdOption.isHidden = isExpanding
    addStickerButtonContainer.isHidden = isExpanding
    backAndExportButtonContainer.isHidden = !isExpanding
  }
}
