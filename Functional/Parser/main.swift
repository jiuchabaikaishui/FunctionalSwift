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

let intger = digit.many.map { Int(String($0)) }
if let v = intger.run("123") { print(v) }
/*输出：
 (Optional(123), "")
 */

if let v = intger.run("123abc") { print(v) }
/*输出：
 (Optional(123), "abc")
 */
