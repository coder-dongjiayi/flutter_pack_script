//
//  MacroDefine.swift
//  BlinGoBuildScript
//
//  Created by 董家祎 on 2021/8/23.
//

import Foundation


enum PackApp {

    case app


    
    case none
    
    var rawValue:(bundleName:String,packageFileName:String,jenkinsAppName:String){
        switch self {
        case .blingo:
            return ("bundleName","App中文名","jenkins上项目名称")
        case .none:
            return("","","","")
        }
    }
}


var App:PackApp = .blingo

let appStoreName:String = ""
let appSpecificPassword:String = ""


