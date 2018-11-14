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

// MARK: - 扩展Ship类型
extension Ship {
    /// 添加一个canEnageShip函数用于检查是否另一艘船在射程范围内
    ///
    /// - Parameter target: 目标船
    /// - Returns: 是否在射程范围内
    func canEnageShip(target: Ship) -> Bool {
        let dX: Distance = target.position.x - position.x
        let dY: Distance = target.position.y - position.y
        return sqrt(dX*dX + dY*dY) <= firingRange
    }
    func inUnsafeRange(target: Ship) -> Bool {
        let dX: Distance = target.position.x - position.x
        let dY: Distance = target.position.y - position.y
        return sqrt(dX*dX + dY*dY) <= unsafeRange
    }
    func canSafelyEngageShip(target: Ship) -> Bool {
        return canEnageShip(target: target) && (!inUnsafeRange(target: target))
    }
    func canSafelyEngageShip1(target: Ship, friend: Ship) -> Bool {
        return canSafelyEngageShip(target: target) && friend.canSafelyEngageShip(target: target)
    }
}
