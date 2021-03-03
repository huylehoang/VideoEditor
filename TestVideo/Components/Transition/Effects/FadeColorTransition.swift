import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class FadeColorTransition: BaseTransition {
    private var color = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

    /// if 0.0, there is no black phase, if 0.9, the black phase is very important
    private var colorPhase: Float = 0.4

    override var functionName: String {
      return "FadeColorTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setColorValueAsFloat3(color, at: 2)
      encoder.setValue(&colorPhase, at: 3)
    }
  }
}
