//
//  build_android.swift
//  BlinGoBuildScript
//
//  Created by 董家祎 on 2021/8/23.
//

import Foundation
func android_build() -> Void {
   
    let tuple = pruductPath()
    
    let apkPath = FileManager.default.currentDirectoryPath + "/build/app/outputs/flutter-apk/app-release.apk"
    
    let date = string2Date(platform.rawValue.build)
    
    let versionCode = Int(date.timeIntervalSince1970)
    
    
    let resultName = App.rawValue.packageFileName + "_" + platform.rawValue.build + "_" + platform.rawValue.version + "(\(versionCode))" + "_" + environment.rawValue.name
    let apkName = "dev_" + resultName + ".apk";

    
    moveItem(atPath: apkPath, destPath:tuple.exportPath,packName: apkName,isCopy: true)
 
    

    if environment == .product {
        print(ANSIColors.cyan+"******************正在导出GooglePlay版本aab文件 ***********************")
        let aab = "flutter build appbundle --target-platform android-arm64 " + environment.rawValue.executePath
        shell(aab)
        let aabPath = FileManager.default.currentDirectoryPath + "/build/app/outputs/bundle/release/app.aab"
        let aabName = "GoolePlay_" + resultName + ".aab"
        moveItem(atPath: aabPath, destPath:tuple.exportPath,packName: aabName,isCopy: true)
    }
  
}

//修改版本号
func editAndroidBuild() -> Void{
    let versinoPath = FileManager.default.currentDirectoryPath + "/android/versionCode.properties"
    

    
 
    
    let date = string2Date(platform.rawValue.build)
    
    let versionCode = date.timeIntervalSince1970
    
    let content = "flutter.versionCode="+String(Int(versionCode))
    
    do {
        try content.write(toFile: versinoPath, atomically: true, encoding: .utf8)
        printGreen("设置build号为:"+"\(versionCode)")
    } catch  {
        printError(" 文件写入失败" + error.localizedDescription)
        exit(0)
    }
}
func string2Date(_ string:String, dateFormat:String = "yyyy.MMdd.HHmm.ss") -> Date {
    let formatter = DateFormatter()
    formatter.locale = Locale.init(identifier: "zh_CN")
    formatter.dateFormat = dateFormat
    let date = formatter.date(from: string)
    return date!
}
