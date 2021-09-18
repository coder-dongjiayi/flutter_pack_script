//
//  PackageArguments.swift
//  BlinGoBuildScript
//
//  Created by 董家祎 on 2021/8/23.
//

import Foundation
enum Environment{
    //生产
    case product
    //测试
    case test
    var rawValue: (name:String,number:Int,executePath:String){
        switch self {
        case .product:
            return ("生产环境",2,"lib/main.dart")
        case .test:
            return ("t环境",1,"lib/main_t.dart")
        }
    }
    

}


enum Platform{
    
    case ios(version:String,build:String)
    case android(version:String,build:String)

    var rawValue: (name:String,shellName:String,version:String,build:String){
        switch self {
        case .ios(let version,let build):
        
            return ("iOS","ios",version,build)
            
        case .android(let version,let build):
            return ("Android","apk",version,build)
        }
    }

}


var platform:Platform = .ios(version: "", build: "")

var environment:Environment = .product


var ios_android:Bool = false

var currentBranckName:String = ""

var androidPath:String?

var iosPath:String?

//是否使用的是 jenkins打包
var isJenkins:Bool = false

//使用jenkins 服务的端口号
var jenkinsPort:String = ""

//当前jenkins构建的number
var jenkinsBuildNumber:String = "000"

//jenkins当前登录用户
var jenkinsBuildUser:String = "null"

//当前登录用户手机号
var jenkinsUserMobile:String = "";


