//
//  Battpeship.swift
//  Battleship
//
//  Created by 綦帅鹏 on 2018/11/14.
//
/*
 战舰类游戏核心类
 
 主要解决判断给定的点是否在射程范围内的问题。
 */
import Foundation

/// 首先定义两种类型，Distance（表示距离）、Position（表示位置）
typealias Distance = Double
struct Position {
    var x: Distance
    var y: Distance
}

/// 引入Ship结构体，用来表示战船
struct Ship {
    /// 位置
    var position: Position
    
    /// 射程范围
    var firingRange: Distance
    
    /// 不安全范围
    var unsafeRange: Distance
}

extension Position {
    func minus(tagert: Position) -> Position {
        return Position(x: x - tagert.x, y: y - tagert.y)
    }
    func length() -> Distance {
        return sqrt(x*x + y*y)
    }
}

// MARK: - 扩展Ship类型
extension Ship {
    /// 添加一个canEnageShip函数用于检查是否另一艘船在射程范围内
    ///
    /// - Parameter target: 目标船
    /// - Returns: 是否在射程范围内
    func canEnageShip(target: Ship) -> Bool {
//        let dX: Distance = target.position.x - position.x
//        let dY: Distance = target.position.y - position.y
//        return sqrt(dX*dX + dY*dY) <= firingRange
        
        return position.minus(tagert: target.position).length() <= firingRange
    }
    
    /// 判断是否另一艘船在不安全范围内
    ///
    /// - Parameter target: 目标船
    /// - Returns: 否另一艘船在不安全范围内
    func inUnsafeRange(target: Ship) -> Bool {
//        let dX: Distance = target.position.x - position.x
//        let dY: Distance = target.position.y - position.y
//        return sqrt(dX*dX + dY*dY) <= unsafeRange
        
        return position.minus(tagert: target.position).length() <= unsafeRange
    }
    
    /// 判断是否另一艘船在射程范围内并且在不安全范围外
    ///
    /// - Parameter target: 目标船
    /// - Returns: 否另一艘船在射程范围内并且在不安全范围外
    func canSafelyEngageShip(target: Ship) -> Bool {
        return canEnageShip(target: target) && (!inUnsafeRange(target: target))
    }
}

typealias Region = (Position) -> Bool

func circle(center: Position, radius: Distance) -> Region {
    return { point in center.minus(tagert: point).length() <= radius }
}
func shift(region: @escaping Region, offset: Position) -> Region {
    return { point in region(Position(x: point.x + offset.x, y: point.y + offset.y)) }
}
