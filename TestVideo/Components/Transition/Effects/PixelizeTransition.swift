import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class PixelizeTransition: BaseTransition {
    // minimum number of squares (when the effect is at its higher level)
    //  public var squaresMin: int2 = int2(20, 20)
    private var squaresMin: SIMD2<Int32> = SIMD2(20, 20)

    // zero disable the stepping
    private var steps: Int = 50

    override var functionName: String {
      return "PixelizeTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&squaresMin, at: 2)
      encoder.setValue(&steps, at: 3)
    }
  }
}
