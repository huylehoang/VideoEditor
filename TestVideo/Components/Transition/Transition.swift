//
//  Transition.swift
//  TestVideo
//
//  Created by Admin on 2/2/21.
//

import Foundation
import UIKit

class Transition {
  static let context = CIContext(mtlDevice: MTLCreateSystemDefaultDevice()!)

  private let fragmentName: String
  private let inputImage: CIImage
  private let destImage: CIImage

  init(fragmentName: String, inputImage: CIImage, destImage: CIImage) {
    self.fragmentName = fragmentName
    self.inputImage = inputImage
    self.destImage = destImage
  }
}
