import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class DirectionalWipeTransition: BaseTransition {
    private var direction = CGPoint(x: 1.0, y: -1.0)
    private var smoothness: Float = 0.5

    override var functionName: String {
      return "DirectionalWipeTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setPointValueAsFloat2(direction, at: 2)
      encoder.setValue(&smoothness, at: 3)
    }
  }
}
