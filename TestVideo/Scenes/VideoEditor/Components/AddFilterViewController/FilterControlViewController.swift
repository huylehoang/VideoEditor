import UIKit
import AVFoundation

final class FilterControlViewController: FilterControlPresentationController {
  var updated: ((Filter) -> Void)?

  private let duration: CMTime
  private(set) var filter: Filter

  private lazy var timeRangeSlider: TimeRangeSlider = {
    let slider = TimeRangeSlider(duration: duration)
    if filter.timeRange.isAvailable {
      slider.from = filter.timeRange.from
      slider.to = filter.timeRange.to
    } else {
      slider.to = duration
    }
    return slider
  }()

  private lazy var filterSlider: FilterSlider = {
    let slider = FilterSlider()
    if let valueRange = filter.kind.valueRange {
      slider.minimumValue = valueRange.min
      slider.maximumValue = valueRange.max
    }
    if let value = filter.kind.value {
      slider.value = value
    }
    return slider
  }()

  init(duration: CMTime, filter: Filter) {
    self.duration = duration
    self.filter = filter
    super.init()
  }

  override func loadView() {
    super.loadView()
    setupView()
  }
}

// MARK: Setup
private extension FilterControlViewController {
  func setupView() {
    view.backgroundColor = .clear

    let centerView = UIView()
    centerView.translatesAutoresizingMaskIntoConstraints = false
    centerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    centerView.layer.cornerRadius = 12
    view.addSubview(centerView)
    let centerViewConstraints = [
      centerView.topAnchor.constraint(equalTo: view.topAnchor),
      centerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      centerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      centerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ]

    let vStackView = UIStackView()
    vStackView.translatesAutoresizingMaskIntoConstraints = false
    vStackView.axis = .vertical
    vStackView.alignment = .fill
    vStackView.distribution = .fill
    vStackView.spacing = 12
    centerView.addSubview(vStackView)
    let vStackViewContraints = [
      vStackView.topAnchor.constraint(equalTo: centerView.topAnchor, constant: 12),
      vStackView.bottomAnchor.constraint(equalTo: centerView.bottomAnchor, constant: -12),
      vStackView.leadingAnchor.constraint(equalTo: centerView.leadingAnchor, constant: 12),
      vStackView.trailingAnchor.constraint(equalTo: centerView.trailingAnchor, constant: -12),
    ]

    let label = UILabel()
    label.font = .systemFont(ofSize: 15, weight: .semibold)
    label.textColor = .black
    label.text = filter.kind.title

    vStackView.addArrangedSubview(label)
    vStackView.addArrangedSubview(timeRangeSlider)
    vStackView.addArrangedSubview(filterSlider)

    let hStackView = UIStackView()
    hStackView.axis = .horizontal
    hStackView.alignment = .fill
    hStackView.distribution = .fillEqually
    hStackView.spacing = 3
    vStackView.addArrangedSubview(hStackView)

    let clearButton = UIButton()
    clearButton.setTitle("CLEAR", for: .normal)
    clearButton.setTitleColor(.darkText, for: .normal)
    clearButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
    clearButton.addTarget(self, action: #selector(clearTapped(_:)), for: .touchUpInside)
    hStackView.addArrangedSubview(clearButton)

    let applyButton = UIButton()
    applyButton.setTitle("APPLY", for: .normal)
    applyButton.setTitleColor(.darkText, for: .normal)
    applyButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
    applyButton.addTarget(self, action: #selector(applyTapped(_:)), for: .touchUpInside)
    hStackView.addArrangedSubview(applyButton)
    
    let constraints = centerViewConstraints + vStackViewContraints
    NSLayoutConstraint.activate(constraints)
  }
}

// MARK: IBAction
private extension FilterControlViewController {
  @objc func clearTapped(_ sender: UIButton) {
    dismiss(animated: true)
    filter.updateTimeRange(Filter.TimeRange())
    filter.updateKind(arguments: [kMetalValue: Float(0.0)])
    updated?(filter)
  }

  @objc func applyTapped(_ sender: UIButton) {
    dismiss(animated: true)
    filter.updateTimeRange(Filter.TimeRange(from: timeRangeSlider.from, to: timeRangeSlider.to))
    filter.updateKind(arguments: [kMetalValue : filterSlider.value])
    updated?(filter)
  }
}
