import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class GridFlipTransition: BaseTransition {
    private var bgColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    private var randomness: Float = 0.1
    private var pause: Float = 0.1
    private var dividerWidth: Float = 0.05
    private var size: SIMD2<Int32> = SIMD2(4, 4)
    
    override var functionName: String {
      return "GridFlipTransition"
    }
    
    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setColorValueAsFloat4(bgColor, at: 2)
      encoder.setValue(&randomness, at: 3)
      encoder.setValue(&pause, at: 4)
      encoder.setValue(&dividerWidth, at: 5)
      encoder.setValue(&size, at: 6)
    }
  }
}
