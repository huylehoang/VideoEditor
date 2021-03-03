import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
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
        let toTexture = toImage?.metalTexture,
        let outputTexture = makeOutputTexture(withFromTexture: fromTexture),
        let commandBuffer = MetalDevice.sharedCommandQueue.makeCommandBuffer(),
        let encoder = commandBuffer.makeComputeCommandEncoder()
      else {
        return self.fromImage
      }
      
      let threadgroupSize = makeThreadgroupSize(from: kernel)
      let threadgroupCount = makeThreadgroupCount(fromSize: threadgroupSize, andFromTexture: fromTexture)
      var ratio = makeRatio(fromCIImage: fromImage)

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

    // Override this function in subclasses if kernel function need more arguments than the standard
    /// ***
    ///
    /// Standard kernel transition function with always needed arguments
    ///
    /// kernel void Transition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
    ///                 texture2d<float, access::sample> fromTexture [[ texture(1) ]],
    ///                 texture2d<float, access::sample> toTexture [[ texture(2) ]],
    ///                 constant float & ratio [[ buffer(0) ]],
    ///                 constant float & progress [[ buffer(1) ]],
    ///                 uint2 gid [[ thread_position_in_grid ]],
    ///                 uint2 tpg [[ threads_per_grid ]])
    ///
    /// ***
    // Set new constant argument from index 2...
    // Set new texture argument from index 3...
    // VideoTranition+Extension: extension MTLComputeCommandEncoder {} for common methods
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

  func makeTextureDescriptor(fromTexture texture: MTLTexture) -> MTLTextureDescriptor {
    let descriptor = MTLTextureDescriptor()
    descriptor.pixelFormat = .rgba8Unorm
    descriptor.width = texture.width
    descriptor.height = texture.height
    descriptor.usage = [.shaderRead, .shaderWrite]
    return descriptor
  }

  func makeOutputTexture(withFromTexture fromTexture: MTLTexture) -> MTLTexture? {
    let descriptor = makeTextureDescriptor(fromTexture: fromTexture)
    return MetalDevice.sharedDevice.makeTexture(descriptor: descriptor)
  }

  func makeThreadgroupSize(from kernel: MTLComputePipelineState) -> MTLSize {
    let threadgroupWidth = kernel.threadExecutionWidth
    let threadgroupSize = MTLSize(
      width: threadgroupWidth,
      height: kernel.maxTotalThreadsPerThreadgroup / threadgroupWidth,
      depth: 1)
    return threadgroupSize
  }

  func makeThreadgroupCount(fromSize size: MTLSize, andFromTexture texture: MTLTexture) -> MTLSize {
    let threadgroupCount = MTLSize(
      width: (texture.width + size.width - 1) / size.width,
      height: (texture.height + size.height - 1) / size.height,
      depth: 1)
    return threadgroupCount
  }

  func makeRatio(fromCIImage ciImage: CIImage) -> Float {
    return Float(ciImage.extent.size.width / ciImage.extent.size.height)
  }
}
