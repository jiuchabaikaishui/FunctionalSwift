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

indirect enum Diagram {
    case primitive(CGSize, Primitive)
    case beside(Diagram, Diagram)
    case below(Diagram, Diagram)
    case align(CGPoint, Diagram)
}

enum Attribute {
    case fillColor(UIColor)
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
        case let .align(_, diagram):
            return diagram.size
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

