import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class DirectionalWarpTransition: BaseTransition {
    private var direction = CGPoint(x: -1.0, y: 1.0)

    override var functionName: String {
      return "DirectionalWarpTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setPointValueAsFloat2(direction, at: 2)
    }
  }
}
