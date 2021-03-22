import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class Renderer {
    let effect: Effect
    private let transition: BaseTransition

    init(effect: Effect) {
      self.effect = effect
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
      MetalDevice.sharedContext.render(output, to: destinationPixelBuffer)
    }
  }
}
