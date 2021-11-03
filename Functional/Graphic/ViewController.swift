//
//  ViewController.swift
//  Graphic
//
//  Created by 綦 on 2021/10/31.
//

import UIKit

struct CellModel {
    let title: String?
    let image: UIImage?
}

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
        let scale = min(width/rect.size.width, height/rect.size.height)
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
            let radio = left.size.width/right.size.width
            let (leftBound, rightBound) = bound.split(ratio: radio, edge: .minXEdge)
            
        default:
            <#code#>
        }
    }
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
        datas.append(CellModel(title: "xx", image: nil))
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

