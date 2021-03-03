import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class DirectionalTransition: BaseTransition {
    private var direction = CGPoint(x: 0, y: 1.0)

    override var functionName: String {
      return "DirectionalTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setPointValueAsFloat2(direction, at: 2)
    }
  }
}
