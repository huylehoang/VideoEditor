import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class CircleCropTransition: BaseTransition {
    private var bgColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

    override var functionName: String {
      return "CircleCropTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setColorValueForFloat4(bgColor, at: 2)
    }
  }
}
