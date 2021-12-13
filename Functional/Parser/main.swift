//
//  main.swift
//  Parser
//
//  Created by 綦 on 2021/11/30.
//

import Foundation

//typealias Parser<Result> = (String) -> (Result, String)?

//typealias Stream = String
//typealias Parser<Result> = (Stream) -> (Result, String)?

struct Parser<Result> {
    typealias Stream = String
    let parse: (Stream) -> (Result, Stream)?
}

func character(matching condition: @escaping (Character) -> Bool) -> Parser<Character> {
    return Parser { input in
        guard let char = input.first, condition(char) else { return nil }
        return (char, String(input.dropFirst()))
    }
}

let one = character { $0 == "1" }
if let v = one.parse("123") { print(v) }
/*输出：
 ("1", "23")
 */

extension Parser {
    func run(_ string: String) -> (Result, String)? {
        guard let result = parse(string) else { return nil }
        return result
    }
}

if let v = one.run("123") { print(v) }
/*输出：
 ("1", "23")
 */


extension CharacterSet {
    func contains(_ c: Character) -> Bool {
        let scalars = c.unicodeScalars
        guard scalars.count == 1 else { return false }
        return contains(scalars.first!)
    }
}

let digit = character { CharacterSet.decimalDigits.contains($0) }
if let v = digit.run("456") { print(v) }
/*输出：
 ("4", "56")
 */


extension Parser {
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
}
if let v = digit.many.run("123") { print(v) }
/*输出：
 (["1", "2", "3"], "")
 */


extension Parser {
    func map<T>(_ transform: @escaping (Result) -> T) -> Parser<T> {
        return Parser<T> { input in
            guard let (result, remainder) = run(input) else { return nil }
            return (transform(result), remainder)
        }
    }
}

let integer = digit.many.map { Int(String($0))! }
if let v = integer.run("123") { print(v) }
/*输出：
 (123, "")
 */

if let v = integer.run("123abc") { print(v) }
/*输出：
 (123, "abc")
 */



extension Parser {
    func followed<A>(by other: Parser<A>) -> Parser<(Result, A)> {
        return Parser<(Result, A)> { input in
            guard let (result1, remainder1) = run(input) else { return nil }
            guard let (result2, remainder2) = other.run(remainder1) else { return nil }
            return ((result1, result2), remainder2)
        }
    }
}

let multiplication = integer
    .followed(by: character { $0 == "*" })
    .followed(by: integer)
if let v = multiplication.run("2*3") { print(v) }
/*输出：
 (((2, "*"), 3), "")
 */

let multiplication2 = multiplication.map { $0.0.0*$0.1 }
if let v = multiplication2.run("2*3") { print(v) }
/*输出：
 (6, "")
 */


func multiply(lhs: (Int, Character), rhs: Int) -> Int {
    return lhs.0*rhs
}

func multiply(_ x: Int, _ op: Character, _ y: Int) -> Int {
    return x*y
}

func curriedMultiply(_ x: Int) -> (Character) -> (Int) -> Int {
    return { op in
        { y in
            return x*y
        }
    }
}
print(curriedMultiply(2)("*")(3))
/*输出：
 6
 */

func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in f(a, b) } }
}

let p1 = integer.map(curriedMultiply)

let p2 = p1.followed(by: character { $0 == "*" })

let p3 = p2.map { $0.0($0.1) }

let p4 = p3.followed(by: integer)
let p5 = p4.map { $0.0($0.1) }

if let v = p5.run("2*3") { print(v) }
/*输出：
 (6, "")
 */

let multiplication3 = integer.map(curriedMultiply)
    .followed(by: character { $0 == "*"} )
    .map { $0.0($0.1) }
    .followed(by: integer)
    .map { $0.0($0.1) }

precedencegroup SequencePrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}
infix operator <*> : SequencePrecedence
func <*><A, B>(lhs: Parser<(A) -> B>, rhs: Parser<A>) -> Parser<B> {
    return lhs.followed(by: rhs).map { $0.0($0.1) }
}

let multiplication4 = integer.map(curriedMultiply)<*>character { $0 == "*" }<*>integer

infix operator <^> : SequencePrecedence
func <^><A, B>(lsh: @escaping (A) -> B, rsh: Parser<A>) -> Parser<B> {
    return rsh.map(lsh)
}

let multiplication5 = curriedMultiply<^>integer<*>character { $0 == "*" }<*>integer


infix operator *> : SequencePrecedence
func *><A, B>(lsh: Parser<A>, rsh: Parser<B>) -> Parser<B> {
    return curry { _, y in y }<^>lsh<*>rsh
}

infix operator <* : SequencePrecedence
func <*<A, B>(lsh: Parser<A>, rsh: Parser<B>) -> Parser<A> {
    return curry { x, _ in x }<^>lsh<*>rsh
}


extension Parser {
    func or(_ other: Parser<Result>) -> Parser<Result> {
        return Parser { run($0) ?? other.run($0) }
    }
}

let star = character { $0 == "*" }
let plus = character { $0 == "+" }
let starOrPlus = star.or(plus)
if let v = starOrPlus.run("+") { print(v) }
/*输出：
 ("+", "")
 */

infix operator <|>
func <|><A>(lsh: Parser<A>, rsh: Parser<A>) -> Parser<A> {
    return Parser { lsh.run($0) ?? rsh.run($0) }
}
if let v = (star<|>plus).run("+") { print(v) }
/*输出：
 ("+", "")
 */


extension Parser {
    var many1: Parser<[Result]> {
        return { x in { manyX in [x] + manyX } }<^>self<*>self.many
    }
}
