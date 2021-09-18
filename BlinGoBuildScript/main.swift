//
//  main.swift
//  BlinGoBuildScript
//
//  Created by 董家祎 on 2021/8/13.
//


import Foundation


 //pack -p(1.iOS 2.Android 3.Android和iOS)  -e (测试 生产) -b master(当前分支)



var argumentPlatform:String?
var argumentEnvironment:String?
var argumentBranch:String?



let lines =  CommandLine.arguments

for index in 0..<lines.count {
    let cmd = lines[index]

    if cmd == "-p" {
        let value = lines[index+1]
        if value == "iOS" {
            argumentPlatform = "1"
        }
        if value == "Android" {
            argumentPlatform = "2"
        }
        if value == "iOS,Android" {
            argumentPlatform = "3"
        }

    }
    if cmd == "-e" {
        let value = lines[index+1]
        if value == "t环境" || value == "生产环境" {
            argumentEnvironment = value
        }

    }
    if cmd == "-b" {
        argumentBranch = lines[index+1]

    }
    if (cmd == "-testFight"){
        let path = lines[index + 1]
        uploadAppStore(atPath: path)
        exit(0)
    }
    //1 使用jenkins打包 2直接使用命令打包
    if cmd == "-jenkins" {
        let jenkins = lines[index + 1]
        if jenkins == "1" {
            isJenkins = true
        }
    }
    if cmd == "-jenkinsPort" {
        jenkinsPort = lines[index + 1]
    }
    if cmd == "-jenkinsBuildNumber" {
        jenkinsBuildNumber = lines[index + 1]
    }
    if cmd == "-jenkinsBuildUser" {
        jenkinsBuildUser = lines[index + 1]
    }
    if cmd == "-jenkinsUserMobile" {
        jenkinsUserMobile = lines[index + 1]
    }

}



//使用脚本直接传参

if let pnumber = argumentPlatform ,let platform = Int(pnumber) ,let enumber = argumentEnvironment{
    let number:Int = enumber == "生产环境" ? 2 : 1
    initArgment(with: platform, env: number)

}else{
// 通过命令行选择参数
    print(ANSIColors.cyan+"请选择需要打包的平台: 1.iOS  2.Android 3.Android和iOS")

    guard let response1 = readLine(),let platformNumber = Int(response1) else{

        printError("输入参数非法，程序结束")
       exit(0)
    }


    print(ANSIColors.cyan+"请选择环境:1.t环境   2.生产环境")

    guard let response2 = readLine(),let environmentNumber = Int(response2) else{
        printError("输入参数非法，程序结束")
        exit(0);
    }


    initArgment(with: platformNumber,env:environmentNumber)

}

shell("git pull")

shell("flutter clean")

shell("flutter pub upgrade")

buildPack()
if(isJenkins == true){
    dingTaklSend(with: .success)

}






