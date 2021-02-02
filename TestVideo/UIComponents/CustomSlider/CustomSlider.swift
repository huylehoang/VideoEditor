import UIKit

class CustomSlider: UISlider {
  private let trackHeight: CGFloat = 4
  private let thumbRadius: CGFloat = 15

  private lazy var thumbView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.frame = CGRect(x: 0, y: thumbRadius / 2, width: thumbRadius, height: thumbRadius)
    view.layer.cornerRadius = thumbRadius / 2
    return view
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setThumbImage(thumbView.asImage(), for: .normal)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func trackRect(forBounds bounds: CGRect) -> CGRect {
    var newRect = super.trackRect(forBounds: bounds)
    newRect.size.height = trackHeight
    return newRect
  }
}
