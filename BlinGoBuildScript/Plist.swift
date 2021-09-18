//
//  Plist.swift
//  BlinGoBuildScript
//
//  Created by 董家祎 on 2021/8/23.
//

import Foundation
import Yams




//获取当前版本号
func loadVersion() -> (appName:String, version:String) {
    guard let dictionary = selectYaml(),let version = dictionary["version"] as? String ,let appName = dictionary["name"] as? String else {
      
        printError("dictionary 为 nil")
        exit(0)
    }
    return (appName,version)
}


//查询yaml文件
func selectYaml() -> [String:Any]? {
    
    do {
        let text = try String(contentsOfFile: getFull(at: "/pubspec.yaml")!)
        guard let dictionary = try! Yams.load(yaml: text) as? [String: Any]  else {
          
            printError("yaml解析失败")
            exit(0)
        }
        return dictionary
    
    } catch  {
    
        printError("yaml读取失败:\(error)")
    }
    return nil
}

func savePropertyList(_ plist: Any,plistURL:String){
    do{

        let plistData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try plistData.write(to: URL(fileURLWithPath: getFull(at: plistURL)!))

    }catch let error {

        printError("plist 文件保存失败:\(error) path:\(plistURL)")

    }
    
   
}

func selectPropertyList(path:String) ->Dictionary<String, Any>{
    
    return loadPropertyList(fullPath: getFull(at: path)!)
}

func loadPropertyList(fullPath:String) ->Dictionary<String, Any>{

    do{
        let fileManager =  FileManager.default
        if fileManager.fileExists(atPath: fullPath) == false {
            printError("文件路径不存在:\(fullPath)")
            return [:]
        }
       
        if  let data =  fileManager.contents(atPath: fullPath){
           
            let swiftDictionary = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String:Any]

            return swiftDictionary
           
        }else{
          
            printError("data 数据读取失败")
            return [:]
        }
        
       

    }catch let error {

        printError("plist data 转 map 失败:\(error)")

        return [:]

    }

}


//获取全路径
func getFull(at path:String) -> String? {
  
    let fileManager =  FileManager.default

     let currentPath = fileManager.currentDirectoryPath

    let plistPath = currentPath + path
    if fileManager.fileExists(atPath: plistPath) {
        return plistPath
    }

    printError("\(plistPath) 不存在")
    exit(0);
    
}
