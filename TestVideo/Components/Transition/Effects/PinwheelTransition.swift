import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class PinwheelTransition: BaseTransition {
    private var speed: Float = 2

    override var functionName: String {
      return "PinwheelTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&speed, at: 2)
    }
  }
}
