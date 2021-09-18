//
//  Utils.swift
//  BlinGoBuildScript
//
//  Created by 董家祎 on 2021/8/13.
//

import Foundation



func loadIosBuildVersion() -> Void{
  
    let pbxprojPath  = "/ios/Runner.xcodeproj/project.pbxproj"
    let dictionary = loadPropertyList(path: pbxprojPath)
    
  
    guard let objectDictionary = dictionary["objects"] as? [String:[String:Any]] else {
        printError("获取CFBundleVersion失败")
        return
    }
 

  let list =   objectDictionary.flatMap { (key:String,value) -> [String] in
    var list:[String] = []
        if let buildSettingMap = value["buildSettings"] as? [String:Any],let buildVersion = buildSettingMap["CURRENT_PROJECT_VERSION"] as? String {
            if let modle = value["name"] as? String ,modle == "Debug"{
                
                iosCurrentCFBundleVersion = buildVersion;
            }
          
            list.append(key)

        }
    return list
    }
    
    print(ANSIColors.green+"当前版本:\(iosCurrentCFBundleVersion)(\(currentVersion)), 是否需要修改build号 YES:修改 NO:不修改")
    
    guard let response = readLine(),(response == "YES" || response == "NO" || response == "yes" || response == "no") else{

        printError("输入参数非法，只能输入YES yes 或者 NO no")
       exit(0)
    }
    if response == "no" || response == "NO" {
        iosLastCFBundleVersion = iosCurrentCFBundleVersion
        return
    }
    
    print(ANSIColors.green+"请输入一个大于0的数字")
   
    guard let buildNumber = readLine(), let number = Int(buildNumber), number > 0 else{

        printError("输入参数非法，请输入数字")
       exit(0)
    }
    iosLastCFBundleVersion = buildNumber
    buildList = list
   
    
}

///修改build号
func editBuildVersion() -> Void {
    if iosLastCFBundleVersion == iosCurrentCFBundleVersion {
        return;
    }
    let pbxprojPath  = "/ios/Runner.xcodeproj/project.pbxproj"
    
    buildList.forEach { (id) in
        let value = "objects:\(id):buildSettings:CURRENT_PROJECT_VERSION \(iosLastCFBundleVersion)"
        print(value)
        setPlist(value: value, path: pbxprojPath)
    }
  
    print(ANSIColors.green+"修改后的版本:\(iosLastCFBundleVersion)(\(currentVersion))")
}




func editXdfRtcBundleId() -> Void {
    print(ANSIColors.magenta+"***************修改 XdfRTC.framework中的bundleId******************")
    
    print(ANSIColors.green+"当前打包参数: \(packageName) \(evn)")
 
    let plistPath = "/ios/Pods/RoomBox/RoomBoxSDK/XdfRTC.framework/Info.plist"
    
    var dictionary =  loadPropertyList(path: plistPath)
   
     dictionary["CFBundleIdentifier"] = roomBoxIdentifier
     
    savePropertyList(dictionary, plistURL: plistPath)
    

}



func ios_build() -> Void{
  
  
    editXdfRtcBundleId()
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm"
    let dateString = dateFormatter.string(from: Date())
    
    
    let archivePath = "~/Library/Developer/Xcode/Archives/\(dateString)/Runner"

    let xcodebuild = "xcodebuild  archive -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release -archivePath \(archivePath) | xcpretty "

    runShell(xcodebuild)
    print(archivePath + "/Runner.xcarchive");
    print(ANSIColors.cyan+"***************开始导出ipa文件******************")

    let desktopPath = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .allDomainsMask, true).first!
    
    let exportPath = desktopPath + "/blingo/iOS/Runner-\(dateString)";
    
    let exportIpa_dev = "xcodebuild -exportArchive -archivePath \(archivePath).xcarchive -exportPath \(exportPath) -exportOptionsPlist ExportOptions_development.plist"
    runShell(exportIpa_dev);
        

    let ipaName = ipaFileName + "_" + "(\(iosLastCFBundleVersion))" + currentVersion + "_" + evn + ".ipa";
    
    
    let ipaPath = exportPath + "/\(iosCFBundleName).ipa"
    let targetPath = exportPath + "/" + ipaName
    do {
        try FileManager.default.moveItem(atPath: ipaPath, toPath: targetPath)
    } catch  {
        printError("ipa重命名失败\(error)")
    }
    
    print(ANSIColors.green+"****************ipa 导出完成********************")
    
    
//    print(ANSIColors.cyan+"是否需要上传当前ipa到 testFight YES:上传到testFight NO:不上传")
//
//    guard let response = readLine(),let number = Int(response) else{
//
//        print("输入参数非法，程 序结束")
//       exit(0)
//    }
//
//    print(ANSIColors.cyan+"开始构建appStore的ipa")
//
//    let exportIpa_testFight = "xcodebuild -exportArchive -archivePath \(archivePath).xcarchive -exportPath \(exportPath) -exportOptionsPlist ExportOptions_appstore.plist"
//
//    runShell(exportIpa_testFight);
//
//    print("当前ipa信息---版本:\(currentVersion) 环境:\(evn)")
//
//    xcrun altool --upload-app --type ios --file "/Path/To/Your/Package/your_package_file.ipa" --username "<user_name>" --password "<app_specific_password>"

}


