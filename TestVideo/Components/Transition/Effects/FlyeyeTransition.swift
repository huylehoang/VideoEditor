import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class FlyeyeTransition: BaseTransition {
    private var colorSeparation: Float = 0.3
    private var zoom: Float = 50
    private var size: Float = 0.04

    override var functionName: String {
      return "FlyeyeTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&colorSeparation, at: 2)
      encoder.setValue(&zoom, at: 3)
      encoder.setValue(&size, at: 4)
    }
  }
}
