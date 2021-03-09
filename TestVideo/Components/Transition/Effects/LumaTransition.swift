import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  class LumaTransition: BaseTransition {
    fileprivate lazy var luma = UIImage(named: "spiral-1")

    override var functionName: String {
      return "LumaTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setImageAsTexture(luma, at: 3)
    }
  }

  final class LumaRandomTransition: LumaTransition {
    override init() {
      super.init()
      let names = [
        "bilinear-lateral",
        "conical-asym",
        "conical-sym",
        "displacementMap",
        "linear-sawtooth-lateral-4",
        "radial-tri-lateral-4",
        "spiral-1",
        "spiral-2",
        "spiral-3",
        "square"
      ]
      let name = names[Int.random(in: 0..<names.count)]
      luma = UIImage(named: name)
    }

    override var description: String { return "LumaRandomTransition" }
  }

  final class LumaSpiralTransition: LumaTransition {
    init(level: Int = Int.random(in: 1...3)) {
      super.init()
      luma = UIImage(named: "spiral-\(level)")
    }

    override var description: String { return "LumaRandomSpiralTransition" }
  }
}
