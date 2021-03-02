import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class CircleOpenTransition: BaseTransition {
    private var smoothness: Float = 0.3
    private var opening: Bool = true

    override var functionName: String {
      return "CircleOpenTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&smoothness, at: 2)
      encoder.setValue(&opening, at: 3)
    }
  }
}
