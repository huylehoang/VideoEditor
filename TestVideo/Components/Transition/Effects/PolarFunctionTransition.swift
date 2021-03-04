import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class PolarFunctionTransition: BaseTransition {
    private var segments: Int = 5

    override var functionName: String {
      return "PolarFunctionTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&segments, at: 2)
    }
  }
}
