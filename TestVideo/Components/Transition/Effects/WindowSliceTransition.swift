import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class WindowSliceTransition: BaseTransition {
    private var count: Float = 10
    private var smoothness: Float = 0.5

    override var functionName: String {
      return "WindowSliceTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&count, at: 2)
      encoder.setValue(&smoothness, at: 3)
    }
  }
}
