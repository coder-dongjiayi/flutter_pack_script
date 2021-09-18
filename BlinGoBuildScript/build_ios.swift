//
//  build_ios.swift
//  BlinGoBuildScript
//
//  Created by 董家祎 on 2021/8/23.
//

import Foundation
func ios_build() -> Void{
  
    let tuple = pruductPath()
    let exportPath = tuple.exportPath
    
    let archivePath = "~/Library/Developer/Xcode/Archives/\(tuple.dateString)/Runner"

    
    createDirectory(atPath: exportPath)
    
    let xcodeBuildLogPath = exportPath + "/xcodebuild.log"
    
    
    let xcodebuild = "xcodebuild  archive -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release -archivePath \(archivePath)  -destination 'generic/platform=iOS' | xcpretty > \(xcodeBuildLogPath)"
    printGreen("正在build工程，请耐心等候...")
    shell(xcodebuild,isShowVersion: false)
    print(archivePath + "/Runner.xcarchive");
 

    var exportIpa_dev:String?
    var exportIpa_product:String?
    
    if(environment == .product){
         exportIpa_product = "xcodebuild -exportArchive -archivePath \(archivePath).xcarchive -exportPath \(exportPath) -exportOptionsPlist ExportOptions_appstore.plist"
    }
    
     exportIpa_dev = "xcodebuild -exportArchive -archivePath \(archivePath).xcarchive -exportPath \(exportPath) -exportOptionsPlist ExportOptions_development.plist"
  
    let ipaPath = exportPath + "/\(App.rawValue.bundleName).ipa"
    
    
    
    if let dev_path = exportIpa_dev {
      

        print(ANSIColors.cyan+" ******************正在导出 development版本ipa ***********************")
        shell(dev_path);
        
        let ipaName = "dev_" + App.rawValue.packageFileName + "_" + platform.rawValue.version + "(\(platform.rawValue.build))" + "_" + environment.rawValue.name + ".ipa";
        
       
        moveItem(atPath: ipaPath, destPath: exportPath,packName: ipaName,isCopy: true)
        
    }
    
    if let product_path = exportIpa_product {
        print(ANSIColors.cyan+" ******************正在导出AppStore版本ipa ***********************")
    
        shell(product_path);
        
        let ipaName = "appStore_" + App.rawValue.packageFileName + "_" +  platform.rawValue.version + "(\(platform.rawValue.build))" + "_" + environment.rawValue.name  + ".ipa";
        
        
        moveItem(atPath: ipaPath, destPath: exportPath,packName: ipaName,isCopy: true)
    }
    
    
    removeItem(atPath: ipaPath)
  
}

//上传ipad到appStore
func uploadAppStore(atPath:String) -> Void {

    if FileManager.default.fileExists(atPath: atPath) == false {
        printError("文件路径不存在:\(atPath)")
        return
    }

    let ipaFilePath = atPath
    
    var fileList:[String] = []
    do {
        fileList =  try FileManager.default.contentsOfDirectory(atPath: ipaFilePath).filter({ (fileName) -> Bool in
            
            return fileName.hasSuffix("ipa")
        })
    } catch  {
        printError("文件路径不存在:\(error)")
        exit(0)
    }
    
    print(ANSIColors.cyan+"*请选择需要上传的ipa文件*")
    
    for index in 0..<fileList.count {
        printGreen("\(index): "+fileList[index])
    }
    
    guard let response = readLine(),let number = Int(response),number < fileList.count else{
        printError("输入参数非法，程序结束")
        exit(0);
    }
    
    let fileName = fileList[number]
    
    
    let ipaFile = "'\(ipaFilePath)/\(fileName)'"
    let temp = ipaFilePath + "/temp"
  
    print(ANSIColors.yellow+"当前选择上传的文件为:\(fileName)")
    ///创建临时目录
    createDirectory(atPath: temp)
    print(ANSIColors.cyan+"*正在解析ipa文件*")
    shell("unzip \(ipaFile) > /dev/null -d \(temp)",isShowVersion: false)
    
    
    // 读取Info.plist
    let plistPath = temp + "/" + "Payload/Runner.app/Info.plist"
    
    let infoDictionary =  loadPropertyList(fullPath: plistPath)
    
   
    if let displayName = infoDictionary["CFBundleDisplayName"] as? String,let version = infoDictionary["CFBundleShortVersionString"] as? String, let buildNumber = infoDictionary["CFBundleVersion"] as? String {
        printGreen("************当前ipa信息*************\n name: \(displayName)\n version: \(version)\n buildNumber: \(buildNumber)")
    }
    
    //删除临时目录
    removeItem(atPath: temp)
    
    
    print(ANSIColors.cyan+"*开始上传TestFight*")
    
    let appStoreShell = "xcrun altool > /dev/null --upload-app --type ios --file " + ipaFile + " --username " + appStoreName + " --password " + appSpecificPassword + " --output-format json"
    
    shell(appStoreShell,isShowVersion: false, color: .default)
 
}


//修改 ios端 build号
func editBuildVersion() -> Void {
  
    let pbxprojPath  = "/ios/Runner.xcodeproj/project.pbxproj"
    let dictionary = selectPropertyList(path: pbxprojPath)
    
   
    guard let objectDictionary = dictionary["objects"] as? [String:[String:Any]] else {
        printError("获取CFBundleVersion失败")
       exit(0)
    }
 
    let buildList =   objectDictionary.flatMap { (key:String,value) -> [String] in
      var list:[String] = []
        if let buildSettingMap = value["buildSettings"] as? [String:Any],let _ = buildSettingMap["CURRENT_PROJECT_VERSION"] as? String {
        
        
              list.append(key)

          }
      return list
      }
    
    buildList.forEach { (id) in
        let value = "objects:\(id):buildSettings:CURRENT_PROJECT_VERSION \(platform.rawValue.build)"
        print(value)
        setPlist(value: value, path: pbxprojPath)
    }
  
    print(ANSIColors.green+"修改后的版本:\(platform.rawValue.version)" + "(" + platform.rawValue.build + ")")
}

