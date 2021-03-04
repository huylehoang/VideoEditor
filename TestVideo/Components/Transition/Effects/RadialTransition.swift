import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class RadialTransition: BaseTransition {
    private var smoothness: Float = 1

    override var functionName: String {
      return "RadialTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&smoothness, at: 2)
    }
  }
}
