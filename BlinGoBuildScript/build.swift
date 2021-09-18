//
//  build.swift
//  BlinGoBuildScript
//
//  Created by 董家祎 on 2021/8/25.
//

import Foundation



func initArgment(with plt:Int, env:Int) -> Void {
    let tuple =  loadVersion()
    
    switch tuple.appName {
    case "blingo":
        App = .blingo
    default:
        App = .none
    }
     var platformNumber = plt
    
    //先打Android包 再打iOS包
    if(platformNumber == 3){
        platformNumber = 2
        ios_android = true
    }
    
    let buildNumber = loadBuildNumber()
    
    if(platformNumber == 1){
        platform = .ios(version: tuple.version, build: buildNumber)
       
    }else if(platformNumber == 2){
        
        platform = .android(version: tuple.version, build: buildNumber)
      
    }
    
    if env == 1 {
        environment = .test
    }else if(env == 2){
        environment = .product
    }

    
}
func buildPack() -> Void {
  
    if platform.rawValue.name == "Android" {
        editAndroidBuild()
    }
    
    let flutterBuild = "flutter build \(platform.rawValue.shellName) \(environment.rawValue.executePath)"
    shell(flutterBuild)
    
    switch platform {
    case .ios(_,_):
        
            editBuildVersion()
     
            ios_build()
            printPath()
            
    case .android(_,_):
        
        android_build()
        
        if ios_android == true {
            print(ANSIColors.yellow+"Android已经打包完毕，正在打包iOS")
            initArgment(with: 1,env: environment.rawValue.number)
            buildPack()
        }else{
            printPath()
        }
        
    }
        
  
}
func printPath() -> Void{
    print(ANSIColors.magenta+"******************文件最终路径***********************")
    if let aPath = androidPath {
        printGreen("Android路径:" + aPath)
    }
    if let  iPath = iosPath {
        printGreen("iOS路径:" + iPath)
    }
  
  
}
func pruductPath() -> (exportPath:String,dateString:String) {
   
    
    let desktopPath = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .allDomainsMask, true).first!
    
    let currentPath = FileManager.default.currentDirectoryPath
    
    let dateString = platform.rawValue.build.replacingOccurrences(of: ".", with: "-")
    let productPath = platform.rawValue.name + "/" + dateString
    
    let exportPath = isJenkins == true ? currentPath + "/PackProducts" + "/" + productPath : desktopPath + "/" + App.rawValue.bundleName + "/" + productPath
    if isJenkins == true {
        
        let jenkinsPath = "http://" + ipAddress + ":" + jenkinsPort + "/job/" + App.rawValue.jenkinsAppName + "/ws/PackProducts/" + productPath
        switch platform {
        case .ios(_,_):
            iosPath = jenkinsPath
        case .android(_,_):
        androidPath = jenkinsPath
        
        }
    }
    
    return (exportPath,dateString)
}
// 以当前时间为build号码
func loadBuildNumber() -> String{
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy.MMdd.HHmm.ss"
 
    let buildNumber = formatter.string(from: Date())
    
    
    return  buildNumber
    
}
