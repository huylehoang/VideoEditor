import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class ColorPhaseTransition: BaseTransition {
    // Usage: fromStep and toStep must be in [0.0, 1.0] range
    // and all(fromStep) must be < all(toStep)
    private var fromStep = UIColor(red: 0.0, green: 0.2, blue: 0.4, alpha: 0.0)
    private var toStep = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)

    override var functionName: String {
      return "ColorPhaseTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setColorValueForFloat4(fromStep, at: 2)
      encoder.setColorValueForFloat4(toStep, at: 3)
    }
  }
}
