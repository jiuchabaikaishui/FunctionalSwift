//
//  ViewController.swift
//  Graphic
//
//  Created by 綦 on 2021/10/31.
//

import UIKit

enum Primitive {
    case ellipse
    case rectangle
    case text(String)
}

enum Attribute {
    case fillColor(UIColor)
}

indirect enum Diagram {
    case primitive(CGSize, Primitive)
    case beside(Diagram, Diagram)
    case below(Diagram, Diagram)
    case attributed(Attribute, Diagram)
    case align(CGPoint, Diagram)
}

extension Diagram {
    var size: CGSize {
        switch self {
        case let .primitive(size, _):
            return size
        case let .beside(left, right):
            return CGSize(width: left.size.width + right.size.width, height: max(left.size.height, right.size.height))
        case let .below(top, bottom):
            return CGSize(width: max(top.size.width, bottom.size.width), height: top.size.height + bottom.size.height)
        case let .attributed(_, diagram):
            return diagram.size
        case let .align(_, diagram):
            return diagram.size
        }
    }
}

func *(l: CGFloat, r: CGSize) -> CGSize {
    return CGSize(width: l*r.width, height: l*r.height)
}
func *(l: CGSize, r: CGSize) -> CGSize {
    return CGSize(width: l.width*r.width, height: l.height*r.height)
}
func -(l: CGSize, r: CGSize) -> CGSize {
    return CGSize(width: l.width - r.width, height: l.height - r.height)
}
func +(l: CGPoint, r: CGPoint) -> CGPoint {
    return CGPoint(x: l.x + r.x, y: l.y + r.y)
}
extension CGSize {
    var point: CGPoint {
        return CGPoint(x: width, y: height)
    }
}
extension CGPoint {
    var size: CGSize {
        return CGSize(width: x, height: y)
    }
}

extension CGSize {
    func fit(into rect: CGRect, alignment: CGPoint) -> CGRect {
        let scale = min(rect.width/width, rect.height/height)
        let targetSize = scale*self
        let spacerSize = alignment.size*(rect.size - targetSize)
        return CGRect(origin: rect.origin + spacerSize.point, size: targetSize)
    }
}

extension CGPoint {
    static let left = CGPoint(x: 0.0, y: 0.5)
    static let top = CGPoint(x: 0.5, y: 0.0)
    static let right = CGPoint(x: 1.0, y: 0.5)
    static let bottom = CGPoint(x: 0.5, y: 1.0)
    static let center = CGPoint(x: 0.5, y: 0.5)
}

extension CGRectEdge {
    var isHorizontal: Bool {
        return self == .maxXEdge || self == .minXEdge
    }
}

extension CGRect {
    func split(ratio: CGFloat, edge: CGRectEdge) -> (CGRect, CGRect) {
        let length = edge.isHorizontal ? width : height
        return divided(atDistance: length*ratio, from: edge)
    }
}

extension CGContext {
    func draw(_ primitive: Primitive, in frame: CGRect) {
        switch primitive {
        case .rectangle:
            fill(frame)
        case .ellipse:
            fillEllipse(in: frame)
        case .text(let text):
            let attributeText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
            attributeText.draw(in: frame)
        }
    }
    
    func draw(_ diagram: Diagram, in bound: CGRect) {
        switch diagram {
        case let .primitive(size, primiteve):
            let frame = size.fit(into: bound, alignment: .center)
            draw(primiteve, in: frame)
        case let .align(alignment, diagram):
            let frame = diagram.size.fit(into: bound, alignment: alignment)
            draw(diagram, in: frame)
        case let .beside(left, right):
            let radio = left.size.width/diagram.size.width
            let (leftBound, rightBound) = bound.split(ratio: radio, edge: .minXEdge)
            draw(right, in: rightBound)
            draw(left, in: leftBound)
        case let .below(top, down):
            let radio = top.size.height/diagram.size.height
            let (topBound, downBound) = bound.split(ratio: radio, edge: .minYEdge)
            draw(top, in: topBound)
            draw(down, in: downBound)
        case let .attributed(.fillColor(color), diagram):
            saveGState()
            color.setFill()
            draw(diagram, in: bound)
            restoreGState()
        }
    }
}

func rect(width: CGFloat, height: CGFloat) -> Diagram {
    return Diagram.primitive(CGSize(width: width, height: height), .rectangle)
}
func circle(diameter: CGFloat) -> Diagram {
    return Diagram.primitive(CGSize(width: diameter, height: diameter), .ellipse)
}
func text(content: String, width: CGFloat, height: CGFloat) -> Diagram {
    return Diagram.primitive(CGSize(width: width, height: height), .text(content))
}
func square(side: CGFloat) -> Diagram {
    return rect(width: side, height: side)
}

precedencegroup VerticalCombination {
    associativity: left
}
infix operator --- : VerticalCombination
func ---(top: Diagram, bottom: Diagram) -> Diagram {
    return Diagram.below(top, bottom)
}

precedencegroup HorizontalCombination {
    higherThan: VerticalCombination
    associativity: left
}
infix operator ||| : AdditionPrecedence
func |||(left: Diagram, right: Diagram) -> Diagram {
    return Diagram.beside(left, right)
}

extension Diagram {
    func filled(color: UIColor) -> Diagram {
        return Diagram.attributed(.fillColor(color), self)
    }
    func aligned(position: CGPoint) -> Diagram {
        return Diagram.align(position, self)
    }
}

extension Diagram {
    init() {
        self = rect(width: 0.0, height: 0.0)
    }
}
extension Sequence where Element == Diagram {
    var hcat: Diagram {
        return reduce(Diagram(), |||)
    }
}

extension Sequence where Element == CGFloat {
    var normalized: [CGFloat] {
        let maxValue = reduce(0.0, Swift.max)
        return map { $0/maxValue }
    }
}

func barGraph(input: [(String, Float)]) -> Diagram {
    let values = input.map { CGFloat($0.1) }
    let bars = values.normalized.map { (v) in
        return rect(width: 1.0, height: 3*v).filled(color: UIColor.random).aligned(position: CGPoint.bottom)
    }.hcat
    let labels = input.map { (label, _) in
        return text(content: label, width: 1.0, height: 0.3).aligned(position: .top)
    }.hcat

    return bars --- labels
}


extension UIColor {
    static var random: UIColor {
        return UIColor(red: ((CGFloat)(arc4random()%256))/255.0, green: ((CGFloat)(arc4random()%256))/255.0, blue: ((CGFloat)(arc4random()%256))/255.0, alpha: 1.0)
    }
}

struct CellModel {
    let title: String?
    let image: UIImage?
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    lazy var datas = Array<CellModel>()
    lazy var tableView = { () -> UITableView in
        let tableView = UITableView(frame: self.view.frame)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        return tableView
    } ()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildUI()
        buildData()
    }

    func buildUI() {
        title = "图表"
        view.backgroundColor = UIColor.white
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    func buildData() {
        datas.append(CellModel(title: "绘制正方形和圆", image: drawSC()))
        datas.append(CellModel(title: "加一个圆", image: addC()))
        datas.append(CellModel(title: "画个圆", image: image(in: CGSize(width: 50.0, height: 50.0), draw: { (context, bound) in
            context.draw(circle(diameter: bound.width).filled(color: UIColor.red), in: bound)
        })))
        datas.append(CellModel(title: "画个正方形", image: image(in: CGSize(width: 50.0, height: 50.0), draw: { (context, bound) in
            context.draw(square(side: bound.width).filled(color: UIColor.yellow), in: bound)
        })))
        datas.append(CellModel(title: "画个文字", image: image(in: CGSize(width: 50.0, height: 50.0), draw: { (context, bound) in
            context.draw(text(content: "画个文字", width: bound.width, height: bound.height).filled(color: UIColor.orange).aligned(position: .center), in: bound)
        })))
        datas.append(CellModel(title: "左右排列", image: image(in: CGSize(width: 100.0, height: 50.0), draw: { (context, bound) in
            let left = rect(width: 50.0, height: 20.0).filled(color: UIColor.blue).aligned(position: .bottom)
            let right = rect(width: 50.0, height: 30.0).filled(color: UIColor.purple).aligned(position: .bottom)
            context.draw(left ||| right, in: bound)
        })))
        datas.append(CellModel(title: "上下排列", image: image(in: CGSize(width: 50.0, height: 100.0), draw: { (context, bound) in
            let left = rect(width: 50.0, height: 30.0).filled(color: UIColor.blue).aligned(position: .bottom)
            let right = text(content: "北京", width: 50, height: 30).filled(color: UIColor.purple).aligned(position: .top)
            context.draw(left --- right, in: bound)
        })))
        let contens: [(String, Float)] = [("衡阳", 1153.0), ("北京", 2345.0), ("上海", 4532.0), ("广州", 3232.0), ("深圳", 3474.0)]
        datas.append(CellModel(title: "画个图表", image: image(in: CGSize(width: 50.0*((CGFloat)(contens.count)), height: 165.0), draw: { (context, bound) in
            context.draw(barGraph(input: contens), in: bound)
        })))
    }
    
    func image(in size: CGSize, draw: (CGContext, CGRect) -> Void) -> UIImage {
        let bound = CGRect(origin: CGPoint.zero, size: size)
        let renderner = UIGraphicsImageRenderer(bounds: bound)
        return renderner.image { draw($0.cgContext, bound) }
    }
    func drawSC() -> UIImage {
        let bound = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 40.0)
        let renderner = UIGraphicsImageRenderer(bounds: bound)
        return renderner.image { (context) in
            UIColor.blue.setFill()
            context.fill(CGRect(x: 0.0, y: 10.0, width: 20.0, height: 20.0))
            UIColor.red.setFill()
            context.fill(CGRect(x: 20.0, y: 0.0, width: 40.0, height: 40.0))
            UIColor.green.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 60.0, y: 10.0, width: 20.0, height: 20.0))
        }
    }
    func addC() -> UIImage {
        let bound = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 40.0)
        let renderner = UIGraphicsImageRenderer(bounds: bound)
        return renderner.image { (context) in
            UIColor.blue.setFill()
            context.fill(CGRect(x: 0.0, y: 10.0, width: 20.0, height: 20.0))
            UIColor.cyan.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 20.0, y: 10.0, width: 20.0, height: 20.0))
            UIColor.red.setFill()
            context.fill(CGRect(x: 40.0, y: 0.0, width: 40.0, height: 40.0))
            UIColor.green.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 80.0, y: 10.0, width: 20.0, height: 20.0))
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var result: UITableViewCell
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") {
            result = cell
        } else {
            result = UITableViewCell()
        }
        
        let model = datas[indexPath.row]
        result.textLabel?.numberOfLines = 0
        result.textLabel?.text = model.title
        result.imageView?.image = model.image
        
        return result
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

