import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class CrazyParametricFunTransition: BaseTransition {
    private var a: Float = 4
    private var b: Float = 1
    private var smoothness: Float = 0.1
    private var amplitude: Float = 120

    override var functionName: String {
      return "CrazyParametricFunTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&a, at: 2)
      encoder.setValue(&b, at: 3)
      encoder.setValue(&smoothness, at: 4)
      encoder.setValue(&amplitude, at: 5)
    }
  }
}
