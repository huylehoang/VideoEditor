import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class RandomSquaresTransition: BaseTransition {
    private var smoothness: Float = 0.5
    private var size = CGSize(width: 10, height: 10)

    override var functionName: String {
      return "RandomSquaresTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&smoothness, at: 2)
      encoder.setSizeValueAsFloat2(size, at: 3)
    }
  }
}
