import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class LinearBlurTransition: BaseTransition {
    private var intensity: Float = 0.1

    override var functionName: String {
      return "LinearBlurTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&intensity, at: 2)
    }
  }
}
