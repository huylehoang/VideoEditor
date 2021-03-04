import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class RotateScaleFadeTransition: BaseTransition {
    private var scale: Float = 8
    private var rotations: Float = 1
    private var center = CGPoint(x: 0.5, y: 0.5)
    private var backColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)

    override var functionName: String {
      return "RotateScaleFadeTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&scale, at: 2)
      encoder.setValue(&rotations, at: 3)
      encoder.setPointValueAsFloat2(center, at: 4)
      encoder.setColorValueAsFloat4(backColor, at: 5)
    }
  }
}
