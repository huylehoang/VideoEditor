import UIKit

extension VideoTransition {
  class BaseTransition {
    var functionName: String { return "" }

    var fromImage: CIImage?

    var toImage: CIImage?

    var progress: Float = 0.0

    var outputImage: CIImage? {
      guard
        let kernel = self.kernel,
        let fromImage = self.fromImage,
        let fromTexture = fromImage.metalTexture,
        let toTexture = toImage?.metalTexture
      else {
        return self.fromImage
      }

      let fromWidth = fromTexture.width
      let fromHeight = fromTexture.height

      let descriptor = MTLTextureDescriptor()
      descriptor.pixelFormat = .rgba8Unorm
      descriptor.width = fromWidth
      descriptor.height = fromHeight
      descriptor.usage = [.shaderRead, .shaderWrite]

      guard
        let outputTexture = MetalDevice.sharedDevice.makeTexture(descriptor: descriptor),
        let commandBuffer = MetalDevice.sharedCommandQueue.makeCommandBuffer(),
        let encoder = commandBuffer.makeComputeCommandEncoder()
      else {
        return fromImage
      }

      let threadgroupCount = MTLSize(
        width: (fromWidth + threadgroupSize.width - 1) / threadgroupSize.width,
        height: (fromHeight + threadgroupSize.height - 1) / threadgroupSize.height,
        depth: 1)

      var ratio = Float(fromImage.extent.size.width / fromImage.extent.size.height)

      encoder.setComputePipelineState(kernel)
      encoder.setTexture(outputTexture, index: 0)
      encoder.setTexture(fromTexture, index: 1)
      encoder.setTexture(toTexture, index: 2)
      encoder.setBytes(&ratio, length: MemoryLayout<Float>.size, index: 0)
      encoder.setBytes(&progress, length: MemoryLayout<Float>.size, index: 1)
      updateParameters(forComputeCommandEncoder: encoder)
      encoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadgroupSize)
      encoder.endEncoding()

      commandBuffer.commit()
      commandBuffer.waitUntilCompleted()

      return outputTexture.ciImage
    }

    func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {}
  }
}

private extension VideoTransition.BaseTransition {
  var kernel: MTLComputePipelineState? {
    guard
      let library = try? MetalDevice.sharedDevice.makeDefaultLibrary(bundle: Bundle(for: Self.self)),
      let kernelFunction = library.makeFunction(name: functionName),
      let computePipeline = try? MetalDevice.sharedDevice.makeComputePipelineState(function: kernelFunction)
    else {
      return nil
    }
    return computePipeline
  }

  var threadgroupSize: MTLSize {
    return MTLSize(width: 16, height: 16, depth: 1)
  }
}
