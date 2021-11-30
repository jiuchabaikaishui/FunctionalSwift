//
//  main.swift
//  Parser
//
//  Created by 綦 on 2021/11/30.
//

import Foundation

//typealias Parser<Result> = (String) -> (Result, String)?

//typealias Stream = String.UnicodeScalarView
//typealias Parser<Result> = (Stream) -> (Result, String)?

struct Parser<Result> {
    typealias Stream = String.UnicodeScalarView
    let parse: (Stream) -> (Result, Stream)?
}

func character(matching condition: @escaping (Character) -> Bool) -> Parser<Character> {
    return Parser { input in
        guard let scalar = input.first, let char = Character(scalar), condition(char) else { return nil }
    }
}
