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
    return { _ in
        let parameters: [String: Any] = [kCIInputColorKey: color]
        guard let filter = CIFilter(name: "CIConstantColorGenerator", parameters: parameters) else { fatalError() }
        guard let outputImage = filter.outputImage else { fatalError() }
        
        return outputImage
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
        let overLay = colorGenerator(color: color)(image)
        return compositeSourceOver(overLay: overLay)(image)
    }
}

/// 组合滤镜
func combine() -> Filter {
    let radius = 5.0
    let color = UIColor.red.ciColor
    ///方案一：将滤镜应用于图像
//    return { image in
//        let blurredImage = gaussianBlur(radius: radius)(image)
//        let overlaidImage = colorOverlay(color: color)(blurredImage)
//
//        return overlaidImage;
//    }
    
    ///方案er：将上面两个滤镜调用表达式合并为一体
//    return { image in
//        let radius = 5.0
//        let color = UIColor.red.ciColor
//
//        return colorOverlay(color: color)(gaussianBlur(radius: radius)(image))
//    }
    
    ///方案三：将上面两个滤镜调用表达式合并为一体
//    return composeFilters(filter1: gaussianBlur(radius: radius), filter2: colorOverlay(color: color))
    
    ///方案四：将上面两个滤镜调用表达式合并为一体
    return gaussianBlur(radius: radius) >>> colorOverlay(color: color)
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
extension Filter1 {
    func gaussianBlur(radius: CGFloat) -> Filter1 {
        return Filter1(output: { image in
            let parameters: [String: Any] = [kCIInputRadiusKey: radius, kCIInputImageKey: image]
            guard let filter = CIFilter(name: "CIGaussianBlur", parameters: parameters) else { fatalError() }
            guard let outputImage = filter.outputImage else { fatalError() }
            
            return outputImage
        })
    }
    func colorGenerator(color: CIColor) -> Filter1 {
        return Filter1(output: { _ in
            let parameters: [String: Any] = [kCIInputColorKey: color]
            guard let filter = CIFilter(name: "CIConstantColorGenerator", parameters: parameters) else { fatalError() }
            guard let outputImage = filter.outputImage else { fatalError() }
            
            return outputImage
        })
    }
    func compositeSourceOver(image: CIImage) -> Filter1 {
        return Filter1(output: { image in
            let parameters: [String: Any] = [kCIInputBackgroundImageKey: image, kCIInputImageKey: image]
            guard let filter = CIFilter(name: "CISourceOverCompositing", parameters: parameters) else { fatalError() }
            guard let outputImage = filter.outputImage else { fatalError() }
            
            return outputImage.cropped(to: image.extent)
        })
    }
    func colorOverlay(color: CIColor) -> Filter1 {
        return Filter1(output: { image in
            self.compositeSourceOver(image: self.colorGenerator(color: color).output(image)).output(image)
        })
    }
    /// 组合滤镜
    func combine() -> Filter1 {
        let radius: CGFloat = 5.0
        let color = UIColor.red.ciColor
        ///方案一：将滤镜应用于图像
//        return Filter1(output: { image in
//            let blur = self.gaussianBlur(radius: radius)
//            let colorO = self.colorOverlay(color: color)
//
//            return colorO.output(blur.output(image))
//        })
        
        ///方案二：将上面两个滤镜调用表达式合并为一体
//        return Filter1(output: { image in self.colorOverlay(color: color).output(self.gaussianBlur(radius: radius).output(image))})
        
        ///方案三：将上面两个滤镜调用表达式合并为一体
//        return self.composeFilters(filter1: self.gaussianBlur(radius: radius), filter2: self.colorOverlay(color: color))
        
        ///方案四：将上面两个滤镜调用表达式合并为一体
        return self.gaussianBlur(radius: radius) *** self.colorOverlay(color: color)
    }
    
    func composeFilters(filter1: Filter1, filter2: Filter1) -> Filter1 {
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
