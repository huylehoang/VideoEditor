import UIKit

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  final class DoomScreenTransition: BaseTransition {
    // How much the bars seem to "run" from the middle of the screen first (sticking to the sides). 0 = no drip, 1 = curved drip
    private var dripScale: Float = 0.5

    // Number of total bars/columns
    private var bars: Int = 30

    // Further variations in speed. 0 = no noise, 1 = super noisy (ignore frequency)
    private var noise: Float = 0.1

    // Speed variation horizontally. the bigger the value, the shorter the waves
    private var frequency: Float = 0.5

    // Multiplier for speed ratio. 0 = no variation when going down, higher = some elements go much faster
    private var amplitude: Float = 2

    override var functionName: String {
      return "DoomScreenTransition"
    }

    override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
      encoder.setValue(&dripScale, at: 2)
      var barsValue = Int32(bars)
      encoder.setValue(&barsValue, at: 3)
      encoder.setValue(&noise, at: 4)
      encoder.setValue(&frequency, at: 5)
      encoder.setValue(&amplitude, at: 6)
    }
  }
}
