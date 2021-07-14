//
//  main.swift
//  ImmutableValue
//
//  Created by 綦 on 2021/7/14.
//

import Foundation


// 不可变性的价值
struct PointStruct {
    var x: Int
    var y: Int
}

var point = PointStruct(x: 1, y: 2)
var samePoint = point
samePoint.x = 3
print(point, samePoint)

class PointClass: CustomStringConvertible {
    var x: Int
    var y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    var description: String {
        return "x: \(x), y: \(y)"
    }
}

var pointClass = PointClass(x: 1, y: 2)
var samePointClass = pointClass
samePointClass.x = 3
print(pointClass, samePointClass)


func setStructToOrigin(point: PointStruct) -> PointStruct {
    var newPoint = point
    newPoint.x = 0
    newPoint.y = 0
    return newPoint
}
func setClassToOrigin(point: PointClass) -> PointClass {
    point.x = 0
    point.y = 0
    return point
}
var strutOrigin = setStructToOrigin(point: point)
var classOrigin = setClassToOrigin(point: pointClass)
print(point, strutOrigin, pointClass, classOrigin)

extension PointStruct {
    mutating func setStructToOrigin() {
        x = 0
        y = 0
    }
}
var myPoint = PointStruct(x: 100, y: 100)
let otherPoint = myPoint
myPoint.setStructToOrigin()
print(myPoint, otherPoint)


func sum(integers: [Int]) -> Int {
    var result = 0
    for value in integers {
        result += value
    }
    return result
}

func qsort(array: [Int]) -> [Int] {
    var data = array
    if data.isEmpty {
        return []
    }
    let pivot = data.removeFirst()
    let lesser = data.filter { $0 < pivot }
    let gretter = data.filter { $0 >= pivot }
    
    return qsort(array: lesser) + [pivot] + qsort(array: gretter)
}
