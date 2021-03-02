import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class NoneTransition: BaseTransition {
    override var functionName: String {
      return "None"
    }

    override var outputImage: CIImage? {
      return progress < 0.5 ? fromImage?.oriented(.downMirrored) : toImage?.oriented(.downMirrored)
    }
  }
}
