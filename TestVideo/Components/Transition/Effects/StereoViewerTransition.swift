import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class StereoViewerTransition: BaseTransition {
    // Corner radius as a fraction of the image height
    private var cornerRadius: Float = 0.22

    // How much to zoom (out) for the effect ~ 0.5 - 1.0
    private var zoom: Float = 0.88

    override var functionName: String {
      return "StereoViewerTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&cornerRadius, at: 2)
      encoder.setValue(&zoom, at: 3)
    }
  }
}
