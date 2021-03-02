import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class NormalTransition: BaseTransition {
    override var outputImage: CIImage? {
      return progress < 0.5 ? fromImage : toImage
    }
  }
}
