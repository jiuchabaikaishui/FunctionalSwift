//
//  Helper.swift
//  Spreadsheet
//
//  Created by 綦 on 2022/4/5.
//

import Foundation

extension CharacterSet {
    func contains(_ c: Character) -> Bool {
        let scalars = c.unicodeScalars
        guard scalars.count == 1 else { return false }
        return contains(scalars.first!)
    }
}

func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in f(a, b) } }
}
func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { a in { b in { c in f(a, b, c) } } }
}
