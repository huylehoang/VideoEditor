import AVFoundation
import UIKit
import CoreImage

final class VideoCompositing: NSObject, AVVideoCompositing {
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

  func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
    renderContextQueue.sync { renderContext = newRenderContext }
    renderContextDidChange = true
  }

  enum PixelBufferRequestError: Error {
    case newRenderedPixelBufferForRequestFailure
  }

  func startRequest(_ asyncVideoCompositionRequest: AVAsynchronousVideoCompositionRequest) {
    autoreleasepool {
      renderingQueue.async {
        // Check if all pending requests have been cancelled.
        if self.shouldCancelAllRequests {
          asyncVideoCompositionRequest.finishCancelledRequest()
        } else {
          guard
            let resultPixels = self.newRenderedPixelBufferForRequest(asyncVideoCompositionRequest)
          else {
            asyncVideoCompositionRequest.finish(
              with: PixelBufferRequestError.newRenderedPixelBufferForRequestFailure)
            return
          }
          // The resulting pixelbuffer from Metal renderer is passed along to the request.
          asyncVideoCompositionRequest.finish(withComposedVideoFrame: resultPixels)
        }
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
      let currentInstruction = request.videoCompositionInstruction as? VideoCompositionInstruction,
      // Source pixel buffers are used as inputs while rendering the transition.
      let foregroundSourceBuffer = request.sourceFrame(byTrackID: currentInstruction.foregroundTrackID),
      let backgroundSourceBuffer = request.sourceFrame(byTrackID: currentInstruction.backgroundTrackID),
      // Destination pixel buffer into which we render the output.
      let dstPixels = renderContext?.newPixelBuffer()
    else { return nil }

    if renderContextDidChange {
      renderContextDidChange = false
    }

    let foregroundImage = CIImage(cvImageBuffer: foregroundSourceBuffer)
    let backgroundImage = CIImage(cvImageBuffer: backgroundSourceBuffer)
    let output = CIBlendKernel.lighten.apply(foreground: backgroundImage, background: foregroundImage)!
    let context = CIContext(mtlDevice: MTLCreateSystemDefaultDevice()!)
    context.render(output, to: dstPixels)

    return dstPixels
  }
}
