import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class DisplacementTransition: BaseTransition {
    private lazy var displacementMap = UIImage(named: "displacementMap")
    private var strength: Float = 0.5

    override var functionName: String {
      return "DisplacementTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setImageAsTexture(displacementMap, at: 3)
      encoder.setValue(&strength, at: 2)
    }
  }
}
