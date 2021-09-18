//
//  Color.swift
//  BlinGoBuildScript
//
//  Created by 董家祎 on 2021/8/17.
//

import Foundation
enum ANSIColors: String {
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;31m"     // error
    case green = "\u{001B}[0;32m"   // success
    case yellow = "\u{001B}[0;33m"  // warning
    case blue = "\u{001B}[0;34m"    // info
    case magenta = "\u{001B}[0;35m" // important
    case cyan = "\u{001B}[0;36m"    // tips
    case white = "\u{001B}[0;37m"   // unimportant
    case `default` = "\u{001B}[0;0m"
    
    func name() -> String {
        switch self {
        case .black: return "Black"
        case .red: return "Red"
        case .green: return "Green"
        case .yellow: return "Yellow"
        case .blue: return "Blue"
        case .magenta: return "Magenta"
        case .cyan: return "Cyan"
        case .white: return "White"
        case .default: return "Default"
        }
    }
    
    static func all() -> [ANSIColors] {
        return [.black, .red, .green, .yellow, .blue, .magenta, .cyan, .white, .default]
    }
    
    static func + (_ left: ANSIColors, _ right: String) -> String {
        return left.rawValue + right
    }
}

func printError(_ error:String) -> Void {
    print(ANSIColors.red+" "+error)
}
func printGreen(_ message:String) -> Void{
    print(ANSIColors.green+" "+message)
}
func printVersion() -> Void{
    
    var buildNumber = ""
    var versionNumber = ""
    switch platform {
    case .ios(let version,let build):
        buildNumber = build
        versionNumber = version
    case .android(let version,let build):
        buildNumber = build
        versionNumber = version
    }

    print(ANSIColors.green+" 当前打包参数:\(App.rawValue.packageFileName) \(platform.rawValue.name) \(environment.rawValue.name) 版本号:\(versionNumber)(\(buildNumber)) 分支:\(currentBranckName)")
    
}
