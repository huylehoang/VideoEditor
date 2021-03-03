import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class LuminanceMeltTransition: BaseTransition {
    /// direction of movement :  0 : up, 1, down
    private var direction: Bool = true

    /// does the movement takes effect above or below luminance threshold ?
    private var above: Bool = false

    /// luminance threshold
    private var l_threshold: Float = 0.8

    override var functionName: String {
      return "LuminanceMeltTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&direction, at: 2)
      encoder.setValue(&above, at: 3)
      encoder.setValue(&l_threshold, at: 4)
    }
  }
}
