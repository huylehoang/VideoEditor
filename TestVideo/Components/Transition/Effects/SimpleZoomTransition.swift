import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class SimpleZoomTransition: BaseTransition {
    private var zoomQuickness: Float = 0.8

    override var functionName: String {
      return "SimpleZoomTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&zoomQuickness, at: 2)
    }
  }
}
