import UIKit

protocol TransitionPickerViewControllerDelegate: class {
  func transitionPickerViewController(
    _ picker: TransitionPickerViewController,
    effects: [VideoTransition.Effect])
}

final class TransitionPickerViewController: TransitionPickerPresentationController {
  private let transitions = VideoTransition.Effect.allCases

  weak var delegate: TransitionPickerViewControllerDelegate?

  private var firstTransitionIndex: Int!
  private var secondTransitionIndex: Int!

  override func loadView() {
    super.loadView()
    firstTransitionIndex = Int.random(in: 0...transitions.count - 1)
    secondTransitionIndex = Int.random(in: 0...transitions.count - 1)
    setupView()
  }
}

private extension TransitionPickerViewController {
  func setupView() {
    view.backgroundColor = .white
    view.layer.cornerRadius = 12

    let vStackView = UIStackView()
    vStackView.translatesAutoresizingMaskIntoConstraints = false
    vStackView.axis = .vertical
    vStackView.spacing = 8
    vStackView.alignment = .fill
    vStackView.distribution = .fill
    vStackView.addArrangedSubview(makeTitleLabel())
    vStackView.addArrangedSubview(makePickerView())
    vStackView.addArrangedSubview(makeButtonsStackView())
    view.addSubview(vStackView)
    let constraints = [
      vStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
      vStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
      vStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
      vStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
    ]
    NSLayoutConstraint.activate(constraints)
  }

  func makeTitleLabel() -> UILabel {
    let label = UILabel()
    label.text = "Choose Transitions for 3 merged videos"
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 16, weight: .semibold)
    label.textColor = .darkText
    label.setContentHuggingPriority(.defaultHigh, for: .vertical)
    return label
  }

  func makePickerView() -> UIPickerView {
    let view = UIPickerView()
    view.delegate = self
    view.dataSource = self
    view.selectRow(firstTransitionIndex, inComponent: 0, animated: false)
    view.selectRow(secondTransitionIndex, inComponent: 1, animated: false)
    return view
  }

  func makeButtonsStackView() -> UIView {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 3
    stackView.alignment = .fill
    stackView.distribution = .fillEqually
    let cancelButton = makeButton(title: "CANCEL")
    cancelButton.addTarget(self, action: #selector(cancelTapped(_:)), for: .touchUpInside)
    stackView.addArrangedSubview(cancelButton)
    let selectButton = makeButton(title: "SELECT")
    selectButton.addTarget(self, action: #selector(selectTapped(_:)), for: .touchUpInside)
    stackView.addArrangedSubview(selectButton)
    return stackView
  }

  func makeButton(title: String) -> UIButton {
    let button = UIButton()
    button.setTitle(title, for: .normal)
    button.setTitleColor(.link, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
    button.setContentHuggingPriority(.defaultHigh, for: .vertical)
    return button
  }
}

private extension TransitionPickerViewController {
  @objc func cancelTapped(_ sender: UIButton) {
    dismiss(animated: true)
  }

  @objc func selectTapped(_ sender: UIButton) {
    let firstTransition = transitions[firstTransitionIndex]
    let secondTransition = transitions[secondTransitionIndex]
    delegate?.transitionPickerViewController(self, effects: [firstTransition, secondTransition])
  }
}

extension TransitionPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 2
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return transitions.count
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return transitions[row].description
  }

  func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    let label = view as? UILabel ?? UILabel()
    label.text = transitions[row].description
    label.textColor = .darkText
    label.font = .systemFont(ofSize: 14, weight: .semibold)
    label.textAlignment = component == 0 ? .left : .right
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    return label
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if component == 0 {
      firstTransitionIndex = row
    } else {
      secondTransitionIndex = row
    }
  }
}
