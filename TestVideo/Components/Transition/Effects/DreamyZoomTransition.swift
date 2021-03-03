import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class DreamyZoomTransition: BaseTransition {
    private var rotation: Float = 6
    private var scale: Float = 1.2

    override var functionName: String {
      return "DreamyZoomTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&rotation, at: 2)
      encoder.setValue(&scale, at: 3)
    }
  }
}
