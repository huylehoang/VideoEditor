import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class CrossZoomTransition: BaseTransition {
    private var strength: Float = 0.4

    override var functionName: String {
      return "CrossZoomTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&strength, at: 2)
    }
  }
}
