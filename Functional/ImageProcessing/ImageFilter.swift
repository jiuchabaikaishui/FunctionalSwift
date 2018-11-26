//
//  ImageFilter.swift
//  ImageProcessing
//
//  Created by 綦帅鹏 on 2018/11/23.
//

import Foundation
import CoreImage

/// 图片滤镜
typealias Filter = (CIImage) -> CIImage

/// 高斯模糊滤镜
///
/// - Parameter radius: 半径
/// - Returns: 高斯模糊滤镜
func gaussianBlur(radius: Double) -> Filter {
    return { image in
        let parameters: [String: Any] = [kCIInputRadiusKey: radius, kCIInputImageKey: image]
        guard let filter = CIFilter(name: "CIGaussianBlur", parameters: parameters) else { fatalError() }
        guard let outputImage = filter.outputImage else { fatalError() }
        
        return outputImage
    }
}

/// 颜色生成滤镜
///
/// - Parameter color: 颜色
/// - Returns: 颜色生成滤镜
func colorGenerator(color: CIColor) -> Filter {
    return { image in
        let parameters: [String: Any] = [kCIInputColorKey: color]
        guard let filter = CIFilter(name: "CIConstantColorGenerator", parameters: parameters) else { fatalError() }
        guard let outputImage = filter.outputImage else { fatalError() }
        
//        print("---------\(image.extent)")
        let enImage = outputImage.cropped(to: image.extent)
//        print("---------\(enImage.extent)")
        
        return enImage
    }
}
func compositeSourceOver(overLay: CIImage) -> Filter {
    return { image in
        let parameters: [String: Any] = [kCIInputBackgroundImageKey: image, kCIInputImageKey: overLay]
        guard let filter = CIFilter(name: "CISourceOverCompositing", parameters: parameters) else { fatalError() }
        guard let outputImage = filter.outputImage else { fatalError() }
        
        return outputImage
    }
}
func colorOverlay(color: CIColor) -> Filter {
    return { image in
        let overLay = colorGenerator(color: color)(image)
        return compositeSourceOver(overLay: overLay)(image)
    }
}
func composeFilters(filter1: @escaping Filter, filter2: @escaping Filter) -> Filter {
    return { image in
        return filter2(filter1(image))
    }
}
infix operator >>>: MultiplicationPrecedence
func >>>(filter1: @escaping Filter, filter2: @escaping Filter) -> Filter {
    return { image in filter2(filter1(image)) }
}
