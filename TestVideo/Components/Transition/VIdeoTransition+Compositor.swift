import AVFoundation
import UIKit
import CoreImage

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class Compositor: NSObject, AVVideoCompositing {
    /// Returns the pixel buffer attributes required by the video compositor for new buffers created for processing.
    var requiredPixelBufferAttributesForRenderContext: [String : Any] =
      [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]

    /// The pixel buffer attributes of pixel buffers that will be vended by the adaptor’s CVPixelBufferPool.
    var sourcePixelBufferAttributes: [String : Any]? =
      [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]

    /// Set if all pending requests have been cancelled.
    var shouldCancelAllRequests = false

    /// Dispatch Queue used to issue custom compositor rendering work requests.
    private let renderingQueue = DispatchQueue(label: "leex.testvideo.renderingqueue")

    /// Dispatch Queue used to synchronize notifications that the composition will switch to a different render context.
    private let renderContextQueue = DispatchQueue(label: "leex.testvideo.rendercontextqueue")

    /// The current render context within which the custom compositor will render new output pixels buffers.
    private var renderContext: AVVideoCompositionRenderContext?

    /// Maintain the state of render context changes.
    private var internalRenderContextDidChange = false

    /// Actual state of render context changes.
    private var renderContextDidChange: Bool {
      get {
        return renderContextQueue.sync { internalRenderContextDidChange }
      }
      set (newRenderContextDidChange) {
        renderContextQueue.sync { internalRenderContextDidChange = newRenderContextDidChange }
      }
    }

    private lazy var renderer = Renderer(effect: .none)

    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
      renderContextQueue.sync { renderContext = newRenderContext }
      renderContextDidChange = true
    }

    func startRequest(_ asyncVideoCompositionRequest: AVAsynchronousVideoCompositionRequest) {
      autoreleasepool {
        renderingQueue.async {
          // Check if all pending requests have been cancelled.
          guard !self.shouldCancelAllRequests else {
            asyncVideoCompositionRequest.finishCancelledRequest()
            return
          }

          guard
            let currentInstruction = asyncVideoCompositionRequest.videoCompositionInstruction
              as? CompositionInstruction
          else {
            asyncVideoCompositionRequest.finish(with: Error.newRenderedPixelBufferForRequestFailure)
            return
          }

          if self.renderer.effect != currentInstruction.effect {
            self.renderer = Renderer(effect: currentInstruction.effect)
          }

          guard
            let resultPixels = self.newRenderedPixelBufferForRequest( asyncVideoCompositionRequest)
          else {
            asyncVideoCompositionRequest.finish(with: Error.newRenderedPixelBufferForRequestFailure)
            return
          }
          // The resulting pixelbuffer from Metal renderer is passed along to the request.
          asyncVideoCompositionRequest.finish(withComposedVideoFrame: resultPixels)
        }
      }
    }

    func cancelAllPendingVideoCompositionRequests() {
      /*
       Pending requests will call finishCancelledRequest, those already rendering will call
       finishWithComposedVideoFrame.
       */
      renderingQueue.sync { shouldCancelAllRequests = true }
      renderingQueue.async {
        // Start accepting requests again.
        self.shouldCancelAllRequests = false
      }
    }

    func factorForTimeInRange( _ time: CMTime, range: CMTimeRange) -> Float64 { /* 0.0 -> 1.0 */
      let elapsed = CMTimeSubtract(time, range.start)
      return CMTimeGetSeconds(elapsed) / CMTimeGetSeconds(range.duration)
    }

    func newRenderedPixelBufferForRequest(_ request: AVAsynchronousVideoCompositionRequest) -> CVPixelBuffer? {
      // Source pixel buffers are used as inputs while rendering the transition.
      guard
        let currentInstruction = request.videoCompositionInstruction as? CompositionInstruction,
        // Source pixel buffers are used as inputs while rendering the transition.
        let foregroundSourceBuffer = request.sourceFrame(byTrackID: currentInstruction.foregroundTrackID),
        let backgroundSourceBuffer = request.sourceFrame(byTrackID: currentInstruction.backgroundTrackID),
        // Destination pixel buffer into which we render the output.
        let dstPixels = renderContext?.newPixelBuffer()
      else { return nil }

      if renderContextDidChange {
        renderContextDidChange = false
      }

      /*
       tweenFactor indicates how far within that timeRange are we rendering this frame. This is normalized to vary
       between 0.0 and 1.0. 0.0 indicates the time at first frame in that videoComposition timeRange. 1.0 indicates
       the time at last frame in that videoComposition timeRange.
       */
      let tweenFactor = factorForTimeInRange(request.compositionTime, range: request.videoCompositionInstruction.timeRange)

      renderer.renderPixelBuffer(
        dstPixels,
        usingForegroundSourceBuffer: foregroundSourceBuffer,
        andBackgroundSourceBuffer: backgroundSourceBuffer,
        forTweenFactor: Float(tweenFactor))

      return dstPixels
    }
  }
}

