import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class SquaresWireTransition: BaseTransition {
    private var direction = CGPoint(x: 1.0, y: -0.5)
    private var squares: SIMD2<Int32> = SIMD2(10, 10)
    private var smoothness: Float = 1.6

    override var functionName: String {
      return "SquaresWireTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setPointValueAsFloat2(direction, at: 2)
      encoder.setValue(&squares, at: 3)
      encoder.setValue(&smoothness, at: 4)
    }
  }
}
