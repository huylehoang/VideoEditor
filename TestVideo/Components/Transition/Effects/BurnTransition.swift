import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class BurnTransition: BaseTransition {
    private var color = UIColor(red: 0.9, green: 0.4, blue: 0.2, alpha: 1.0)

    override var functionName: String {
      return "BurnTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setColorValueForFloat3(color, at: 2)
    }
  }
}
