import UIKit

class FilterSlider: UIView {
  var valueChanged: ((Double) -> Void)?

  private(set) var currentValue = 0.0 {
    didSet {
      valueChanged?(currentValue)
    }
  }

  var minimumValue = 0.0 {
    didSet {
      slider.maximumValue = Float(minimumValue)
    }
  }

  var maximumValue = 1.0 {
    didSet {
      slider.maximumValue = Float(maximumValue)
    }
  }

  private lazy var slider: UISlider = {
    let view = CustomSlider()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.value = 0
    view.isContinuous = true
    view.maximumTrackTintColor = .lightGray
    view.minimumTrackTintColor = .link
    view.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    return view
  }()

  private lazy var titleLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.font = .systemFont(ofSize: 12, weight: .bold)
    view.textColor = .link
    return view
  }()

  init(title: String) {
    super.init(frame: .zero)
    setupView()
    titleLabel.text = title
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private extension FilterSlider {
  func setupView() {
    addSubview(slider)
    let sliderConstraints = [
      slider.centerYAnchor.constraint(equalTo: centerYAnchor),
      slider.leadingAnchor.constraint(equalTo: leadingAnchor),
      slider.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 2/5),
    ]

    addSubview(titleLabel)
    let titleLabelConstraints = [
      titleLabel.topAnchor.constraint(equalTo: topAnchor),
      titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
      titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: slider.trailingAnchor, constant: 8)
    ]

    let constraints = titleLabelConstraints + sliderConstraints
    NSLayoutConstraint.activate(constraints)
  }

  @objc func sliderValueChanged(_ sender: UISlider) {
    currentValue = Double(sender.value)
  }
}
