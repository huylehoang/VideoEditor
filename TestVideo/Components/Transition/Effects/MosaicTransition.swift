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
      var endyValue = Int32(endy)
      encoder.setValue(&endyValue, at: 2)
      var endxValue = Int32(endx)
      encoder.setValue(&endxValue, at: 3)
    }
  }
}
