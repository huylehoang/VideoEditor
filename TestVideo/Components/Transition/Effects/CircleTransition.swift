import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class CircleTransition: BaseTransition {
    private var center = CGPoint(x: 0.5, y: 0.5)
    private var backColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

    override var functionName: String {
      return "CircleTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setPointValueForFloat2(center, at: 2)
      encoder.setColorValueForFloat3(backColor, at: 3)
    }
  }
}
