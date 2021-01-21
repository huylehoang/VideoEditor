import UIKit

final class FilterOption: UIView {
  private lazy var titleLabel: UILabel = {
    return makeLabel(textAlignment: .left)
  }()

  private lazy var timeRangeLabel: UILabel = {
    return makeLabel(textAlignment: .right)
  }()

  init(title: String) {
    super.init(frame: .zero)
    setupView()
    titleLabel.text = title
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setTimeRange(_ timeRange: String) {
    timeRangeLabel.text = timeRange
  }
}

private extension FilterOption {
  func setupView() {
    addSubview(titleLabel)
    let titleLabelConstraints = [
      titleLabel.topAnchor.constraint(equalTo: topAnchor),
      titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
    ]

    addSubview(timeRangeLabel)
    let timeRangeLabelConstraints = [
      timeRangeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
      timeRangeLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
    ]

    let constraints = titleLabelConstraints + timeRangeLabelConstraints
    NSLayoutConstraint.activate(constraints)
  }

  func makeLabel(textAlignment: NSTextAlignment) -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 12, weight: .bold)
    label.textColor = .link
    label.textAlignment = textAlignment
    return label
  }
}
