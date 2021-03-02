import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class CubeTransition: BaseTransition {
    private var persp: Float = 0.7
    private var unzoom: Float = 0.3
    private var reflection: Float = 0.4
    private var floating: Float = 3

    override var functionName: String {
      return "CubeTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&persp, at: 2)
      encoder.setValue(&unzoom, at: 3)
      encoder.setValue(&reflection, at: 4)
      encoder.setValue(&floating, at: 5)
    }
  }
}
