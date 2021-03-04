import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class TVStaticTransition: BaseTransition {
    private var offset: Float = 0.02

    override var functionName: String {
      return "TVStaticTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&offset, at: 2)
    }
  }
}
