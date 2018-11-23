//
//  ImageFilter.swift
//  ImageProcessing
//
//  Created by 綦帅鹏 on 2018/11/23.
//

import Foundation
import CoreImage

typealias Filter = (CIImage) -> CIImage

func gaussianBlur(radius: Double) -> Filter {
    return { image in
        let parameters: [String: Any] = [kCIInputRadiusKey: radius, kCIInputImageKey: image]
        guard let filter = CIFilter(name: "CIGaussianBlur", parameters: parameters) else { fatalError() }
        guard let outputImage = filter.outputImage else { fatalError() }
        
        return outputImage
    }
}
