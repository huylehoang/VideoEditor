import UIKit

extension VideoTransition {
  final class NormalTransition: BaseTransition {
    override var outputImage: CIImage? {
      return progress < 0.5 ? fromImage : toImage
    }
  }
}
