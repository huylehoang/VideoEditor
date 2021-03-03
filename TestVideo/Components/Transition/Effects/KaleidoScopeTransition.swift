import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class KaleidoScopeTransition: BaseTransition {
    private var angle: Float = 1
    private var speed: Float = 1
    private var power: Float = 1.5

    override var functionName: String {
      return "KaleidoScopeTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&angle, at: 2)
      encoder.setValue(&speed, at: 3)
      encoder.setValue(&power, at: 4)
    }
  }
}
