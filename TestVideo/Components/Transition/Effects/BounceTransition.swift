import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class BounceTransition: BaseTransition {
    private var bounces: Float = 3
    private var shadowColour = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
    private var shadowHeight: Float = 0.075
    
    override var functionName: String {
      return "BounceTransition"
    }
    
    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&bounces, at: 2)
      encoder.setColorValueForFloat4(shadowColour, at: 3)
      encoder.setValue(&shadowHeight, at: 4)
    }
  }
}
