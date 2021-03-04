import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class WaterDropTransition: BaseTransition {
    private var speed: Float = 30
    private var amplitude: Float = 30

    override var functionName: String {
      return "WaterDropTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&speed, at: 2)
      encoder.setValue(&amplitude, at: 3)
    }
  }
}
