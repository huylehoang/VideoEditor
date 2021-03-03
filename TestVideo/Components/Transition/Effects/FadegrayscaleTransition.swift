import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class FadegrayscaleTransition: BaseTransition {
    private var intensity: Float = 0.3

    override var functionName: String {
      return "FadegrayscaleTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&intensity, at: 2)
    }
  }
}
