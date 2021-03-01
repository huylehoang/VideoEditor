import UIKit

extension VideoTransition {
  private static let context = CIContext(mtlDevice: MTLCreateSystemDefaultDevice()!)

  final class Renderer {
    private let transition: BaseTransition

    init(effect: Effect) {
      transition = effect.transition
    }

    func renderPixelBuffer(
      _ destinationPixelBuffer: CVPixelBuffer,
      usingForegroundSourceBuffer foregroundPixelBuffer: CVPixelBuffer,
      andBackgroundSourceBuffer backgroundPixelBuffer: CVPixelBuffer,
      forTweenFactor tween: Float) {

      let foregroundImage = CIImage(cvPixelBuffer: foregroundPixelBuffer)
      let backgroundImage = CIImage(cvPixelBuffer: backgroundPixelBuffer)

      transition.fromImage = foregroundImage.oriented(.downMirrored)
      transition.toImage = backgroundImage.oriented(.downMirrored)
      transition.progress = tween

      guard let output = transition.outputImage else { return }
      context.render(output, to: destinationPixelBuffer)
    }
  }
}
