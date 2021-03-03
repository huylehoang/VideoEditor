import Foundation

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  enum Effect: Int, CaseIterable, CustomStringConvertible {
    case wind
    case pinwheel
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
    case luminanceMelt
    case morph
    case mosaic
    case multiplyBlend
    case none

    var transition: BaseTransition {
      switch self {
      case .wind: return WindTransition()
      case .pinwheel: return PinwheelTransition()
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
      case .luminanceMelt: return LuminanceMeltTransition()
      case .morph: return MorphTransition()
      case .mosaic: return MosaicTransition()
      case .multiplyBlend: return MultiplyBlendTransition()
      case .none: return NoneTransition()
      }
    }

    var description: String {
      return transition.functionName
    }
  }
}
