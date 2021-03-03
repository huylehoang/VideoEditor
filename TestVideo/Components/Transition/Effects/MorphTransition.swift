import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class MorphTransition: BaseTransition {
    private var strength: Float = 0.1

    override var functionName: String {
      return "MorphTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&strength, at: 2)
    }
  }
}
