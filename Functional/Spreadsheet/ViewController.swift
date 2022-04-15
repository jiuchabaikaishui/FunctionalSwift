//
//  ViewController.swift
//  Spreadsheet
//
//  Created by 綦 on 2022/4/4.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    var delegate = SpreadsheetDelegate()
    var datasource = SpreadsheetDatasource()
    
    @objc func endEditing(_ note: Notification) {
        guard note.object as? NSObject === tableView else { return }
        
        datasource.editedRow = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = delegate
        tableView.dataSource = datasource
        delegate.editedRowDelegate = datasource
        
        NotificationCenter.default.addObserver(self, selector: #selector(endEditing(_:)), name: NSControl.textDidEndEditingNotification, object: nil)
        
        if let v = Expression.intParser.run("123") { print(v) }
        /*输出：
         (Spreadsheet.Expression.int(123), "")
         */
        
        if let v = Expression.referenceParser.run("A3") { print(v) }
        /*输出：
         (Spreadsheet.Expression.reference("A", 3), "")
         */
        
        if let v = string("SUM").run("SUM") { print(v) }
        /*输出：
         ("SUM", "")
         */
        
        if let v = string("SUM").parenthesized.run("(SUM)") { print(v) }
        /*输出：
         ("SUM", "")
         */
        
        if let v = Expression.funcationParser.run("SUM(A1:A2)") { print(v) }
        /*输出：
         (Spreadsheet.Expression.funcation("SUM", Spreadsheet.Expression.infix(Spreadsheet.Expression.reference("A", 1), ":", Spreadsheet.Expression.reference("A", 2))), "")
         */
        
        if let v = Expression.infixParser.run("10+5-3") { print(v) }
        /*输出：
         (Spreadsheet.Expression.infix(Spreadsheet.Expression.infix(Spreadsheet.Expression.int(10), "+", Spreadsheet.Expression.int(5)), "-", Spreadsheet.Expression.int(3)), "")
         */
        
        if let v = Expression.infixParser.run("2*3*4") { print(v) }
        /*输出：
         (Spreadsheet.Expression.infix(Spreadsheet.Expression.infix(Spreadsheet.Expression.int(2), "*", Spreadsheet.Expression.int(3)), "*", Spreadsheet.Expression.int(4)), "")
         */
        
        if let v = Expression.parser.run("2+4*SUM(A1:A2)") { print(v) }
        /*输出：
         (Spreadsheet.Expression.infix(Spreadsheet.Expression.infix(Spreadsheet.Expression.int(2), "+", Spreadsheet.Expression.int(4)), "*", Spreadsheet.Expression.funcation("SUM", Spreadsheet.Expression.infix(Spreadsheet.Expression.reference("A", 1), ":", Spreadsheet.Expression.reference("A", 2)))), "")
         */
        
        let expressions: [Expression] = [
            .infix(.infix(.int(1), "+", .int(2)), "*", .int(3)),
            .infix(.reference("A", 0), "*", .int(3)),
            .funcation("SUM", .infix(.reference("A", 0), ":", .reference("A", 1)))
        ]
        print(evaluate(expressions: expressions))
        /*输出：
         [Spreadsheet.Result.int(9), Spreadsheet.Result.int(27), Spreadsheet.Result.int(36)]
         */
        
        
        if let v = Expression.parser.run("1") { print(v) }
        if let v = Expression.parser.run("SUM(A1:A2)") { print(v) }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
}


protocol EditedRow: class {
    var editedRow: Int? { get set }
}


class SpreadsheetDelegate: NSObject, NSTableViewDelegate {
    weak var editedRowDelegate: EditedRow?
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        editedRowDelegate?.editedRow = row
        return true
    }
}

class SpreadsheetDatasource: NSObject, NSTableViewDataSource, EditedRow {
    var formulas: [String]
    var results: [Result]
    var editedRow: Int? = nil
    
    override init() {
        let initialValues = Array(1..<10)
        formulas = initialValues.map { "\($0)" }
        results = initialValues.map { Result.int($0) }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return formulas.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return editedRow == row ? formulas[row] : results[row].description
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard let string = object as? String else { fatalError() }
        
        formulas[row] = string
        let expressions = formulas.map { Expression.parser.run($0)?.0 }
        results = evaluate(expressions: expressions)
        tableView.reloadData()
    }
}

extension Result: CustomStringConvertible {
    var description: String {
        switch (self) {
        case .int(let x):
            return "\(x)"
        case .list(let x):
            return String(describing: x)
        case .error(let e):
            return "Error: \(e)"
        }
    }
}
