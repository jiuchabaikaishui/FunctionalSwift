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
        let bound = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 40.0)
        let renderner = UIGraphicsImageRenderer(bounds: bound)
        let image = renderner.image { (context) in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0.0, y: 10.0, width: 20.0, height: 20.0))
            UIColor.green.setFill()
            context.fill(CGRect(x: 20.0, y: 0.0, width: 40.0, height: 40.0))
            UIColor.blue.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 60.0, y: 10.0, width: 20.0, height: 20.0))
        }
        self.datas.append(CellModel(title: "绘制正方形和圆", image: image))
        datas.append(CellModel(title: "xx", image: nil))
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

