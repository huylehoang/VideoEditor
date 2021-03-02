import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class ButterflyWaveScrawlerTransition: BaseTransition {
    private var colorSeparation: Float = 0.3
    private var amplitude: Float = 1
    private var waves: Float = 30

    override var functionName: String {
      return "ButterflyWaveScrawlerTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&colorSeparation, at: 2)
      encoder.setValue(&amplitude, at: 3)
      encoder.setValue(&waves, at: 4)
    }
  }
}
