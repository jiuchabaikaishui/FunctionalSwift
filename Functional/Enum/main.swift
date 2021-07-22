//
//  main.swift
//  Enum
//
//  Created by 綦 on 2021/7/22.
//

import Foundation


enum Encoding {
    case ascii
    case nextstep
    case japaneseEUC
    case utf8
}
extension Encoding {
    var nsStringEncoding: String.Encoding {
        switch self {
        case .ascii:
            return String.Encoding.ascii
        case .nextstep:
            return String.Encoding.nextstep
        case .japaneseEUC:
            return String.Encoding.japaneseEUC
        case .utf8:
            return String.Encoding.utf8
        }
    }
}
extension Encoding {
    init?(encoding: String.Encoding) {
        switch encoding {
        case String.Encoding.ascii:
            self = .ascii
        case String.Encoding.nextstep:
            self = .nextstep
        case String.Encoding.japaneseEUC:
            self = .japaneseEUC
        case String.Encoding.utf8:
            self = .utf8
        default:
            return nil
        }
    }
}
extension Encoding {
    var localizedName: String {
        String.localizedName(of: nsStringEncoding)
    }
}

enum LookupError: Error {
    case capitalNotFound
    case populationNotFound
}
enum PopulationResult {
    case success(Int)
    case error(LookupError)
}

let capitals = ["China": "Beijing"]
let citys = ["Beijing": 2200]
func populationOfCapital(country: String) -> PopulationResult {
    guard let capital = capitals[country] else {
        return .error(LookupError.capitalNotFound)
    }
    guard let population = citys[capital] else {
        return .error(LookupError.populationNotFound)
    }
    return PopulationResult.success(population)
}

switch populationOfCapital(country: "France") {
case let PopulationResult.success(population):
    print("人口是\(population)")
case let PopulationResult.error(error):
    switch error {
    case LookupError.capitalNotFound:
        print("首都没找到")
    case LookupError.populationNotFound:
        print("人口没记录")
    }
}

let mayors = [
"Paris": "Hidalgo",
"Madrid": "Carmena", "Amsterdam": "van der Laan", "Berlin": "Müller"
]
func mayorOfCapital(country: String) -> String? {
    capitals[country].flatMap { mayors[$0] }
}


enum MayorResult {
    case success(String)
    case error(Error)
}

enum Result<T> {
    case success(T)
    case error(Error)
}

enum LookupError1: Error {
    case capitalNotFound
    case populationNotFound
    case mayorNotFound
}
func populationOfCapital1(country: String) -> Result<Int> {
    guard let capital = capitals[country] else {
        return Result.error(LookupError1.capitalNotFound)
    }
    guard let population = citys[capital] else {
        return Result.error(LookupError1.populationNotFound)
    }
    return Result.success(population)
}
func mayorOfCapital1(country: String) -> Result<String> {
    guard let capital = capitals[country] else {
        return Result.error(LookupError1.capitalNotFound)
    }
    guard let mayor = mayors[capital] else {
        return Result.error(LookupError1.mayorNotFound)
    }
    return Result.success(mayor)
}


func populationOfCapital2(country: String) throws -> Int {
    guard let capital = capitals[country] else {
        throw LookupError1.capitalNotFound
    }
    guard let population = citys[capital] else {
        throw LookupError1.populationNotFound
    }
    return population
}

do {
    let population = try populationOfCapital2(country: "France")
    print("人口是\(population)")
} catch {
    switch error {
    case LookupError1.capitalNotFound:
        print("首都没有找到")
    case LookupError1.populationNotFound:
        print("人口没有找到")
    default:
        print("其他原因导致人口查询失败")
    }
}


enum Optional<Wrapped> {
    case none
    case some(Wrapped)
    // ……
}


func ??<T>(result: Result<T>, handleError: (Error) -> T) -> T {
    switch result {
    case .success(let value):
        return value
    case .error(let error):
        return handleError(error)
    }
}

let handelError: (Error) -> Int = {
    print("发生错误：\($0)")
    return 0
}
print(Result.success(100) ?? handelError)
print(Result.error(LookupError1.populationNotFound) ?? handelError)


