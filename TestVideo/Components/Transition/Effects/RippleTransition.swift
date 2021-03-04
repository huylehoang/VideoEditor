import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class RippleTransition: BaseTransition {
    private var speed: Float = 50
    private var amplitude: Float = 100

    override var functionName: String {
      return "RippleTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&speed, at: 2)
      encoder.setValue(&amplitude, at: 3)
    }
  }
}
