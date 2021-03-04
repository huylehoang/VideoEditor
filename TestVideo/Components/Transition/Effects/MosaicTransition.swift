import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class MosaicTransition: BaseTransition {
    private var endy: Int = -1
    private var endx: Int = 2

    override var functionName: String {
      return "MosaicTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&endy, at: 2)
      encoder.setValue(&endx, at: 3)
    }
  }
}
