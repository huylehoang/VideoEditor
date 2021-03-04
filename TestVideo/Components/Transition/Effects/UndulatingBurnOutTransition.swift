import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class UndulatingBurnOutTransition: BaseTransition {
    private var color = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    private var smoothness: Float = 0.03
    private var center: CGPoint = CGPoint(x: 0.5, y: 0.5)

    override var functionName: String {
      return "UndulatingBurnOutTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setColorValueAsFloat3(color, at: 2)
      encoder.setValue(&smoothness, at: 3)
      encoder.setPointValueAsFloat2(center, at: 4)
    }
  }
}
