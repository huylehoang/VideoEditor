import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class LumaTransition: BaseTransition {
    private lazy var luma = UIImage(named: "spiral-1")

    override var functionName: String {
      return "LumaTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setImageAsTexture(luma, at: 3)
    }
  }
}
