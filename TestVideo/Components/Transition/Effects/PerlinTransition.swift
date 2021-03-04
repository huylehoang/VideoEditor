import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class PerlinTransition: BaseTransition {
    private var scale: Float = 4
    private var seed: Float = 12.9898
    private var smoothness: Float = 0.01

    override var functionName: String {
      return "PerlinTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&scale, at: 2)
      encoder.setValue(&seed, at: 3)
      encoder.setValue(&smoothness, at: 4)
    }
  }
}
