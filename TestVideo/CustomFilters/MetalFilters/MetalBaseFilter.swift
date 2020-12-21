import Metal
import UIKit

// TODO: Currently not use Metal Filter since it will block UI due to commandBuffer completionHandler,
// finding solutions

/// Reference BBMetalImage github: https://github.com/Silence-GitHub/BBMetalImage
class MetalBaseFilter {
  private let computePipeline: MTLComputePipelineState
  private let threadgroupSize: MTLSize
  private let lock: DispatchSemaphore
  private var outputImage: CIImage?

  init(kernelFunctionName: String) {
    guard
      let library = try? MetalDevice.sharedDevice.makeDefaultLibrary(bundle: Bundle(for: Self.self)),
      let kernelFunction = library.makeFunction(name: kernelFunctionName),
      let computePipeline = try? MetalDevice.sharedDevice.makeComputePipelineState(function: kernelFunction)
    else {
      fatalError("Unable to make compute pipeline state")
    }
    self.computePipeline = computePipeline
    threadgroupSize = MTLSize(width: 16, height: 16, depth: 1)
    lock = DispatchSemaphore(value: 1)
  }

  func filterImage(_ image: CIImage) -> CIImage? {
    outputAvailableForImage(image)
    return outputImage
  }

  func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      fatalError("\(#function) must be overridden by subclass")
  }

  private func outputAvailableForImage(_ inputImage: CIImage) {
    lock.wait()

    guard let inputTexture = inputImage.metalTexture else {
      lock.signal()
      return
    }

    let outputWidth = inputTexture.width
    let outputHeight = inputTexture.height

    let descriptor = MTLTextureDescriptor()
    descriptor.pixelFormat = .rgba8Unorm
    descriptor.width = outputWidth
    descriptor.height = outputHeight
    descriptor.usage = [.shaderRead, .shaderWrite]

    guard
      let outputTextture = MetalDevice.sharedDevice.makeTexture(descriptor: descriptor),
      let commanBuffer = MetalDevice.sharedCommandQueue.makeCommandBuffer()
    else {
      lock.signal()
      return
    }

    commanBuffer.addCompletedHandler { [weak self] buffer in
      switch buffer.status {
      case .completed:
        self?.outputImage = outputTextture.ciImage ?? inputImage
      default:
        self?.outputImage = inputImage
      }

      self?.lock.signal()
    }

    let threadgroupCount = MTLSize(
      width: (outputWidth + threadgroupSize.width - 1) / threadgroupSize.width,
      height: (outputHeight + threadgroupSize.height - 1) / threadgroupSize.height,
      depth: 1)

    guard let encoder = commanBuffer.makeComputeCommandEncoder() else {
      lock.signal()
      return
    }

    encoder.setComputePipelineState(computePipeline)
    encoder.setTexture(outputTextture, index: 0)
    encoder.setTexture(inputTexture, index: 1)
    updateParameters(forComputeCommandEncoder: encoder)
    encoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadgroupSize)
    encoder.endEncoding()

    commanBuffer.commit()
    commanBuffer.waitUntilCompleted()
  }
}
