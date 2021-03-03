import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class CrossHatchTransition: BaseTransition {
    private var threshold: Float = 3
    private var center = CGPoint(x: 0.5, y: 0.5)
    private var fadeEdge: Float = 0.1

    override var functionName: String {
      return "CrossHatchTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&threshold, at: 2)
      encoder.setPointValueAsFloat2(center, at: 3)
      encoder.setValue(&fadeEdge, at: 4)
    }
  }
}
