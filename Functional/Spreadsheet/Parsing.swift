//
//  Parsing.swift
//  Spreadsheet
//
//  Created by 綦 on 2022/4/5.
//

import Foundation

struct Parser<Result> {
    typealias Stream = String
    let parse: (Stream) -> (Result, Stream)?
}


extension Parser {
    func run(_ string: String) -> (Result, String)? {
        guard let result = parse(string) else { return nil }
        return result
    }
    
    var many: Parser<[Result]> {
        return Parser<[Result]> { input in
            var result: [Result] = []
            var remainder = input
            while let (element, newRemainder) = run(remainder) {
                result.append(element)
                remainder = newRemainder
            }
            return (result, remainder)
        }
    }
    
    func map<T>(_ transform: @escaping (Result) -> T) -> Parser<T> {
        return Parser<T> { input in
            guard let (result, remainder) = run(input) else { return nil }
            return (transform(result), remainder)
        }
    }
    
    func followed<A>(by other: Parser<A>) -> Parser<(Result, A)> {
        return Parser<(Result, A)> { input in
            guard let (result1, remainder1) = run(input) else { return nil }
            guard let (result2, remainder2) = other.run(remainder1) else { return nil }
            return ((result1, result2), remainder2)
        }
    }
    
    func or(_ other: Parser<Result>) -> Parser<Result> {
        return Parser { run($0) ?? other.run($0) }
    }
    
    var many1: Parser<[Result]> {
        return { x in { manyX in [x] + manyX } }<^>self<*>self.many
    }
    var optional: Parser<Result?> {
        return Parser<Result?> { input in
            guard let result = self.run(input) else { return (nil, input) }
            
            return result
        }
    }
    
    var parenthesized: Parser<Result> {
        return string("(") *> self <* string(")")
    }
}


precedencegroup SequencePrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}

infix operator <^> : SequencePrecedence
func <^><A, B>(lsh: @escaping (A) -> B, rsh: Parser<A>) -> Parser<B> {
    return rsh.map(lsh)
}

infix operator <*> : SequencePrecedence
func <*><A, B>(lhs: Parser<(A) -> B>, rhs: Parser<A>) -> Parser<B> {
    return lhs.followed(by: rhs).map { $0.0($0.1) }
}

infix operator *> : SequencePrecedence
func *><A, B>(lsh: Parser<A>, rsh: Parser<B>) -> Parser<B> {
    return curry { _, y in y }<^>lsh<*>rsh
}

infix operator <* : SequencePrecedence
func <*<A, B>(lsh: Parser<A>, rsh: Parser<B>) -> Parser<A> {
    return curry { x, _ in x }<^>lsh<*>rsh
}

infix operator <|> : SequencePrecedence
func <|><A>(lsh: Parser<A>, rsh: Parser<A>) -> Parser<A> {
    return Parser { lsh.run($0) ?? rsh.run($0) }
}


func character(matching condition: @escaping (Character) -> Bool) -> Parser<Character> {
    return Parser { input in
        guard let char = input.first, condition(char) else { return nil }
        return (char, String(input.dropFirst()))
    }
}


func string(_ string: String) -> Parser<String> {
    return Parser<String> { input in
        var remainder = input
        for c in string {
            let paser = character { $0 == c }
            guard let (_, newRemainder) =  paser.run(remainder) else { return nil }
            remainder = newRemainder
        }
        
        return (string, remainder)
    }
}
func lazy<A>(parser: @autoclosure @escaping () -> Parser<A>) -> Parser<A> {
    return Parser<A> { parser().run($0) }
}


let digit = character { CharacterSet.decimalDigits.contains($0) }
let integer = digit.many1.map { Int(String($0))! }
let capitalLetter = character { CharacterSet.uppercaseLetters.contains($0) }
