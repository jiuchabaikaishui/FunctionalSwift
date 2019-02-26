//
//  ImageFilter.swift
//  ImageProcessing
//
//  Created by 綦帅鹏 on 2018/11/23.
//

import Foundation
import CoreImage
import UIKit

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
        
        return outputImage.cropped(to: image.extent)
    }
}

/// 合成滤镜
///
/// - Parameter overLay: 前景层
/// - Returns: 合成滤镜
func compositeSourceOver(overLay: CIImage) -> Filter {
    return { image in
        let parameters: [String: Any] = [kCIInputBackgroundImageKey: image, kCIInputImageKey: overLay]
        guard let filter = CIFilter(name: "CISourceOverCompositing", parameters: parameters) else { fatalError() }
        guard let outputImage = filter.outputImage else { fatalError() }
        
        return outputImage.cropped(to: image.extent)
    }
}

/// 颜色叠层滤镜
///
/// - Parameter color: 颜色
/// - Returns: 颜色叠层滤镜
func colorOverlay(color: CIColor) -> Filter {
    return { image in
        let overLay = colorGenerator(color: color)(image).cropped(to: CGRect(x: image.extent.size.width/4, y: image.extent.size.height/4, width: image.extent.width/2, height: image.extent.size.height/2))
        return compositeSourceOver(overLay: overLay)(image)
    }
}

/// 组合滤镜
func combine() -> Filter {
    let radius = 5.0
    let color = CIColor(color: UIColor.red)
    ///方案一：将滤镜应用于图像
//    return { image in
//        let blurredImage = gaussianBlur(radius: radius)(image)
//        let overlaidImage = colorOverlay(color: color)(blurredImage)
//
//        return overlaidImage;
//    }
    
    ///方案二：将上面两个滤镜调用表达式合并为一体
//    return { image in
//        return colorOverlay(color: color)(gaussianBlur(radius: radius)(image))
//    }
    
    ///方案三：使用符合函数合并两个滤镜
    return composeFilters(filter1: gaussianBlur(radius: radius), filter2: colorOverlay(color: color))
    
    ///方案四：使用运算符组合两个滤镜
//    return gaussianBlur(radius: radius) >>> colorOverlay(color: color)
}
func composeFilters(filter1: @escaping Filter, filter2: @escaping Filter) -> Filter {
    return { image in
        return filter2(filter1(image))
    }
}

precedencegroup FilterPrecedence {
    associativity: left//左结合
}
infix operator >>>: FilterPrecedence//MultiplicationPrecedence
func >>>(filter1: @escaping Filter, filter2: @escaping Filter) -> Filter {
    return { image in filter2(filter1(image)) }
}

func add1(x: Int, y: Int) -> Int {
    return x + y
}
func add2(x: Int) -> (Int) -> Int {
    return { y in x + y }
}
var result1 = add1(x: 1, y: 2)
var result2 = add2(x: 1)(2)

struct Filter1 {
    let output : (CIImage) -> CIImage
}
func gaussianBlur1(radius: CGFloat) -> Filter1 {
    return Filter1(output: { image in
        let parameters: [String: Any] = [kCIInputRadiusKey: radius, kCIInputImageKey: image]
        guard let filter = CIFilter(name: "CIGaussianBlur", parameters: parameters) else { fatalError() }
        guard let outputImage = filter.outputImage else { fatalError() }
        
        return outputImage
    })
}
func colorGenerator1(color: CIColor) -> Filter1 {
    return Filter1(output: { _ in
        let parameters: [String: Any] = [kCIInputColorKey: color]
        guard let filter = CIFilter(name: "CIConstantColorGenerator", parameters: parameters) else { fatalError() }
        guard let outputImage = filter.outputImage else { fatalError() }
        
        return outputImage
    })
}
func compositeSourceOver1(image: CIImage) -> Filter1 {
    return Filter1(output: { backImage in
        let parameters: [String: Any] = [kCIInputBackgroundImageKey: backImage, kCIInputImageKey: image]
        guard let filter = CIFilter(name: "CISourceOverCompositing", parameters: parameters) else { fatalError() }
        guard let outputImage = filter.outputImage else { fatalError() }
        
        return outputImage.cropped(to: image.extent)
    })
}
func colorOverlay1(color: CIColor) -> Filter1 {
    return Filter1(output: { image in
        compositeSourceOver1(image: colorGenerator1(color: color).output(image).cropped(to: CGRect(x: image.extent.size.width/4, y: image.extent.size.height/4, width: image.extent.width/2, height: image.extent.size.height/2))).output(image)
    })
}
/// 组合滤镜
func combine1() -> Filter1 {
    let radius: CGFloat = 5.0
    let color = UIColor.red.ciColor
    ///方案一：将滤镜应用于图像
//    return Filter1(output: { image in
//        let blur = gaussianBlur1(radius: radius).output(image)
//        let colorOver = colorOverlay1(color: color).output(blur)
//        return colorOver
//    })
    
    ///方案二：将上面两个滤镜调用表达式合并为一体
//    return Filter1(output: { image in colorOverlay1(color: color).output(gaussianBlur1(radius: radius).output(image)) })
    
    ///方案三：使用符合函数合并两个滤镜
//    return composeFilters1(filter1: gaussianBlur1(radius: radius), filter2: colorOverlay1(color: color))
    
    ///方案四：使用运算符组合两个滤镜
    return gaussianBlur1(radius: radius) *** colorOverlay1(color: color)
}

extension Filter1 {
    func composeFilters1(filter1: Filter1, filter2: Filter1) -> Filter1 {
        return Filter1(output: { image in filter1.output(filter2.output(image)) })
    }
}

precedencegroup Filter1Precedence {
    associativity: left//左结合
}
infix operator ***: Filter1Precedence//MultiplicationPrecedence
func ***(filter1: Filter1, filter2: Filter1) -> Filter1 {
    return Filter1(output: { image in filter1.output(filter2.output(image)) })
}
