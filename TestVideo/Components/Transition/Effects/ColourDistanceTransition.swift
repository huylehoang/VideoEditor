import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class ColourDistanceTransition: BaseTransition {
    private var power: Float = 5

    override var functionName: String {
      return "ColourDistanceTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&power, at: 2)
    }
  }
}
