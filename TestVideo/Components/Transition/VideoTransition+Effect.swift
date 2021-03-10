import Foundation

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  enum Effect: Int, CaseIterable, CustomStringConvertible {
    case bounce
    case bowTieHorizontal
    case bowTieVertical
    case burn
    case butterflyWaveScrawler
    case cannabisleaf
    case circleCrop
    case circleOpen
    case circle
    case colorPhase
    case colourDistance
    case crazyParametricFun
    case crossHatch
    case crossWarp
    case crossZoom
    case cube
    case directional
    case directionalWarp
    case directionalWipe
    case displacement
    case doomScreen
    case doorway
    case dreamy
    case dreamyZoom
    case fadeColor
    case fadegrayscale
    case fade
    case flyeye
    case glitchDisplace
    case glitchMemories
    case gridFlip
    case heart
    case hexagonalize
    case invertedPageCurl
    case kaleidoScope
    case linearBlur
    case luma
    case lumaRandom
    case lumaRandomSpiral
    case luminanceMelt
    case morph
    case mosaic
    case multiplyBlend
    case none
    case perlin
    case pinwheel
    case pixelize
    case polarFunction
    case polkaDotsCurtain
    case radial
    case randomSquares
    case ripple
    case rotateScaleFade
    case simpleZoom
    case squaresWire
    case squeeze
    case stereoViewer
    case swap
    case swirl
    case tangentMotionBlur
    case tvStatic
    case undulatingBurnOut
    case waterDrop
    case windowBlinds
    case windowSlice
    case wind
    case wipeDown
    case wipeLeft
    case wipeRight
    case wipeUp
    case zoomInCircles

    var transition: BaseTransition {
      switch self {
      case .bounce: return BounceTransition()
      case .bowTieHorizontal: return BowTieHorizontalTransition()
      case .bowTieVertical: return BowTieVerticalTransition()
      case .burn: return BurnTransition()
      case .butterflyWaveScrawler: return ButterflyWaveScrawlerTransition()
      case .cannabisleaf: return CannabisleafTransition()
      case .circleCrop: return CircleCropTransition()
      case .circleOpen: return CircleOpenTransition()
      case .circle: return CircleTransition()
      case .colorPhase: return ColorPhaseTransition()
      case .colourDistance: return ColourDistanceTransition()
      case .crazyParametricFun: return CrazyParametricFunTransition()
      case .crossHatch: return CrossHatchTransition()
      case .crossWarp: return CrossWarpTransition()
      case .crossZoom: return CrossZoomTransition()
      case .cube: return CubeTransition()
      case .directional: return DirectionalTransition()
      case .directionalWarp: return DirectionalWarpTransition()
      case .directionalWipe: return DirectionalWipeTransition()
      case .displacement: return DisplacementTransition()
      case .doomScreen: return DoomScreenTransition()
      case .doorway: return DoorwayTransition()
      case .dreamy: return DreamyTransition()
      case .dreamyZoom: return DreamyZoomTransition()
      case .fadeColor: return FadeColorTransition()
      case .fadegrayscale: return FadegrayscaleTransition()
      case .fade: return FadeTransition()
      case .flyeye: return FlyeyeTransition()
      case .glitchDisplace: return GlitchDisplaceTransition()
      case .glitchMemories: return GlitchMemoriesTransition()
      case .gridFlip: return GridFlipTransition()
      case .heart: return HeartTransition()
      case .hexagonalize: return HexagonalizeTransition()
      case .invertedPageCurl: return InvertedPageCurlTransition()
      case .kaleidoScope: return KaleidoScopeTransition()
      case .linearBlur: return LinearBlurTransition()
      case .luma: return LumaTransition()
      case .lumaRandom: return LumaRandomTransition()
      case .lumaRandomSpiral: return LumaRandomSpiralTransition()
      case .luminanceMelt: return LuminanceMeltTransition()
      case .morph: return MorphTransition()
      case .mosaic: return MosaicTransition()
      case .multiplyBlend: return MultiplyBlendTransition()
      case .none: return NoneTransition()
      case .perlin: return PerlinTransition()
      case .pinwheel: return PinwheelTransition()
      case .pixelize: return PixelizeTransition()
      case .polarFunction: return PolarFunctionTransition()
      case .polkaDotsCurtain: return PolkaDotsCurtainTransition()
      case .radial: return RadialTransition()
      case .randomSquares: return RandomSquaresTransition()
      case .ripple: return RippleTransition()
      case .rotateScaleFade: return RotateScaleFadeTransition()
      case .simpleZoom: return SimpleZoomTransition()
      case .squaresWire: return SquaresWireTransition()
      case .squeeze: return SqueezeTransition()
      case .stereoViewer: return StereoViewerTransition()
      case .swap: return SwapTransition()
      case .swirl: return SwirlTransition()
      case .tangentMotionBlur: return TangentMotionBlurTransition()
      case .tvStatic: return TVStaticTransition()
      case .undulatingBurnOut: return UndulatingBurnOutTransition()
      case .waterDrop: return WaterDropTransition()
      case .windowBlinds: return WindowBlindsTransition()
      case .windowSlice: return WindowSliceTransition()
      case .wind: return WindTransition()
      case .wipeDown: return WipeDownTransition()
      case .wipeLeft: return WipeLeftTransition()
      case .wipeRight: return WipeRightTransition()
      case .wipeUp: return WipeUpTransition()
      case .zoomInCircles: return ZoomInCirclesTransition()
      }
    }

    var description: String {
      return transition
        .description
        .replacingOccurrences(
          of: "Transition",
          with: "",
          options: [.caseInsensitive, .regularExpression])
    }
  }
}
