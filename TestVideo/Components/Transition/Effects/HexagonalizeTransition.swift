import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class HexagonalizeTransition: BaseTransition {
    private var steps: Int = 50
    private var horizontalHexagons: Float = 20

    override var functionName: String {
      return "HexagonalizeTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      var stepsValue = Int32(steps)
      encoder.setValue(&stepsValue, at: 2)
      encoder.setValue(&horizontalHexagons, at: 3)
    }
  }
}
