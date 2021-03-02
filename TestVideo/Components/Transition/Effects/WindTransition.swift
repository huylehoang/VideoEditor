import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class WindTransition: BaseTransition {
    private var size: Float = 0.2

    override var functionName: String {
      return "WindTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&size, at: 2)
    }
  }
}

