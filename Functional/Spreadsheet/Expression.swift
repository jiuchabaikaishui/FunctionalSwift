//
//  Expression.swift
//  Spreadsheet
//
//  Created by 綦 on 2022/4/5.
//

import Foundation


indirect enum Expression {
    case int(Int)
    case reference(String, Int)
    case infix(Expression, String, Expression)
    case funcation(String, Expression)
}

extension Expression {
    static var intParser: Parser<Expression> {
        return { int($0) } <^> integer
    }
    
    static var referenceParser: Parser<Expression> {
        return curry { reference(String($0), $1) } <^> capitalLetter <*> integer
    }
    
    static var funcationParser: Parser<Expression> {
        let name = { String($0) } <^> capitalLetter.many1
        let argument = curry { infix($0, $1, $2) } <^> referenceParser <*> string(":") <*> referenceParser
        return curry { funcation($0, $1) } <^> name <*> argument.parenthesized
    }
    
    static var infixParser: Parser<Expression> {
        let calculation = curry { ($0, $1) } <^> (string("+") <|> string("-") <|> string("*") <|> string("/")) <*> primitiveParser
        return curry(combineOperands(first:rest:)) <^> primitiveParser <*> calculation.many1
    }
    
    static var primitiveParser: Parser<Expression> {
        return intParser <|> referenceParser <|> funcationParser
    }

    static var parser = infixParser <|> lazy(parser: infixParser).parenthesized <|> primitiveParser
}

func combineOperands(first: Expression, rest: [(String, Expression)]) -> Expression {
    return rest.reduce(first) { .infix($0, $1.0, $1.1) }
}


enum Result {
    case int(Int)
    case list([Result])
    case error(String)
}

func lift(_ op: @escaping (Int, Int) -> Int) -> (Result, Result) -> Result {
    return { lhs, rhs in
        guard case let (Result.int(x), Result.int(y)) = (lhs, rhs) else {
            return .error("Invalid operands \(lhs), \(rhs) for integer operator")
        }
        
        return .int(op(x, y))
    }
}


extension Expression {
    func evaluate(context: [Expression?]) -> Result {
        switch self {
        case let .int(x):
            return .int(x)
        case let .reference(_, row):
            return context[row]?.evaluate(context: context) ?? Result.error("Invalid reference \(self)")
        case .funcation:
            return evaluateFunction(context: context) ?? .error("Invalid function call \(self)")
        case let .infix(l, op, r):
            return self.evaluateArithmetic(context: context) ?? self.evaluateList(context: context) ?? .error("Invalid operator \(op) for operands \(l), \(r)")
        }
    }
    
    func evaluateFunction(context: [Expression?]) -> Result? {
        guard case let Expression.funcation(name, parameter) = self, case let .list(list) = parameter.evaluate(context: context) else {
            return nil
        }
        
        switch name {
        case "SUM":
            return list.reduce(.int(0), lift(+))
        case "MIN":
            return list.reduce(.int(Int.max), lift { min($0, $1) })
        default:
            return .error("Unknown function \(name)")
        }
    }
    
    func evaluateArithmetic(context: [Expression?]) -> Result? {
        guard case let .infix(l, op, r) = self else {
            return nil
        }
        
        let x = l.evaluate(context: context)
        let y = r.evaluate(context: context)
        switch op {
        case "+":
            return lift(+)(x, y)
        case "-":
            return lift(-)(x, y)
        case "*":
            return lift(*)(x, y)
        case "/":
            return lift(/)(x, y)
        default:
            return nil
        }
    }
    
    func evaluateList(context: [Expression?]) -> Result? {
        guard case let .infix(l, op, r) = self, op == ":", case let .reference(_, row1) = l, case let .reference(_, row2) = r else {
            return nil
        }
        
        return .list((row1...row2).map{ Expression.reference("A", $0).evaluate(context: context) })
    }
}


func evaluate(expressions: [Expression?]) -> [Result] {
    return expressions.map{ $0?.evaluate(context: expressions) ?? .error("Invalid expression \($0)") }
}


