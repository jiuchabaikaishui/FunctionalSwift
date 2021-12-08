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

let integer = digit.many.map { Int(String($0)) }
if let v = integer.run("123") { print(v) }
/*输出：
 (Optional(123), "")
 */

if let v = integer.run("123abc") { print(v) }
/*输出：
 (Optional(123), "abc")
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
 (((Optional(2), "*"), Optional(3)), "")
 */

let multiplication2 = multiplication.map { result -> Int? in
    guard let f = result.0.0, let s = result.1 else { return nil }
    return f*s
}
if let v = multiplication2.run("2*3") { print(v) }
/*输出：
 (Optional(6), "")
 */
