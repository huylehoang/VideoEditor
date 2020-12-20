import UIKit
import AVFoundation

class FilterOptionsView: UIView {
  typealias ValueChanged = (Double) -> Void
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

  private lazy var blurSlider: FilterSlider = {
    let endBlurSeconds = Int((duration/2).rounded())
    let title = "BLUR (0s -> \(endBlurSeconds)s)"
    let slider = FilterSlider(title: title)
    slider.minimumValue = 0
    slider.maximumValue = 25
    return slider
  }()

  private lazy var brightnessSlider: FilterSlider = {
    let startBrightnessSeconds = Int((duration/2).rounded())
    let endBrightnessSeconds = Int((duration * 5/6).rounded())
    let title = "BRIGHTNESS (\(startBrightnessSeconds)s -> \(endBrightnessSeconds)s)"
    let slider = FilterSlider(title: title)
    slider.minimumValue = 0
    slider.maximumValue = 0.5
    return slider
  }()

  private lazy var saturationSlider: FilterSlider = {
    let startSaturationSeconds = Int((duration * 2/3).rounded())
    let endSaturationSeconds = Int((duration * 5/6).rounded())
    let title = "SATURATION (\(startSaturationSeconds)s -> \(endSaturationSeconds)s)"
    let slider = FilterSlider(title: title)
    slider.minimumValue = 0
    slider.maximumValue = 0.5
    return slider
  }()

  private lazy var addStickerButtonContainer: UIView = {
    return makeContainerView()
  }()

  private lazy var backAndExportButtonContainer: UIView = {
    let view = makeContainerView()
    view.isHidden = true
    return view
  }()

  var blurChanged: ValueChanged?
  var brightnessChanged: ValueChanged?
  var saturationChanged: ValueChanged?
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

  func setupObserveValueChanged() {
    blurSlider.valueChanged = blurChanged
    brightnessSlider.valueChanged = brightnessChanged
    saturationSlider.valueChanged = saturationChanged
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
    vStackView.addArrangedSubview(blurSlider)
    vStackView.addArrangedSubview(brightnessSlider)
    vStackView.addArrangedSubview(saturationSlider)
    vStackView.addArrangedSubview(addStickerButtonContainer)
    let button = makeButton(title: "ADD RANDOM STICKER (DOUTAP FOR REMOVING)", tag: 0)
    button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    addStickerButtonContainer.addSubview(button)
    let buttonConstraints = [
      button.topAnchor.constraint(equalTo: addStickerButtonContainer.topAnchor),
      button.bottomAnchor.constraint(equalTo: addStickerButtonContainer.bottomAnchor),
      button.trailingAnchor.constraint(equalTo: addStickerButtonContainer.trailingAnchor),
    ]
    NSLayoutConstraint.activate(buttonConstraints)
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

  func makeButton(title: String, tag: Int = 0) -> UIButton {
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

  @objc func buttonTapped(_ sender: UIButton) {
    switch sender.tag {
    case 0:
      addStickerTapped?()
    case 1:
      backTapped?()
    case 2:
      saveTapped?()
    default:
      break
    }
  }

  @objc func expandTapped(_ sender: UIButton) {
    expandAnimator?.stopAnimation(true)
    expandAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .linear, animations: toggle)
    expandAnimator?.startAnimation()
  }

  func toggle() {
    // alpha
    blurSlider.alpha = isExpanding ? 0 : 1
    brightnessSlider.alpha = isExpanding ? 0 : 1
    saturationSlider.alpha = isExpanding ? 0 : 1
    addStickerButtonContainer.alpha = isExpanding ? 0 : 1
    backAndExportButtonContainer.alpha = isExpanding ? 1 : 0

    // isHidden
    blurSlider.isHidden = isExpanding
    brightnessSlider.isHidden = isExpanding
    saturationSlider.isHidden = isExpanding
    addStickerButtonContainer.isHidden = isExpanding
    backAndExportButtonContainer.isHidden = !isExpanding
  }
}
