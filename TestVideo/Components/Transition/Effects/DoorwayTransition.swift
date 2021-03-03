import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class DoorwayTransition: BaseTransition {
    private var depth: Float = 3
    private var reflection: Float = 0.4
    private var perspective: Float = 0.4

    override var functionName: String {
      return "DoorwayTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&depth, at: 2)
      encoder.setValue(&reflection, at: 3)
      encoder.setValue(&perspective, at: 4)
    }
  }
}
