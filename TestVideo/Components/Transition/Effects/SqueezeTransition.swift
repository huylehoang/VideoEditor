import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class SqueezeTransition: BaseTransition {
    private var colorSeparation: Float = 0.04

    override var functionName: String {
      return "SqueezeTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&colorSeparation, at: 2)
    }
  }
}
