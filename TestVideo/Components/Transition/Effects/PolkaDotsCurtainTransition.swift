import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class PolkaDotsCurtainTransition: BaseTransition {
    private var dots: Float = 20
    private var center: CGPoint = CGPoint(x: 0, y: 0)

    override var functionName: String {
      return "PolkaDotsCurtainTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&dots, at: 2)
      encoder.setPointValueAsFloat2(center, at: 3)
    }
  }
}
