//
//  Shell.swift
//  BlinGoBuildScript
//
//  Created by 董家祎 on 2021/8/23.
//

import Foundation

enum ShellError:Error {
    case error(String)
    
}

@discardableResult

func shell(_ command: String, isShowVersion:Bool = true,color:ANSIColors = .cyan) -> String? {
do {
       let result = try runShell(command,isShowVersion: isShowVersion,color: color)
        
        return result
    } catch ShellError.error(let error) {
        printError(error)
       
    } catch{
        printError(error.localizedDescription)
     
    }
    return nil
}

func runShell(_ command: String, isShowVersion:Bool = true,color:ANSIColors = .cyan) throws -> String? {
    if isShowVersion == true {
        printVersion()
    }
    
    print(ANSIColors.magenta+" ******************\(command) ***********************")
    print(color+"")
  

    
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]

    task.launch()
    task.waitUntilExit()

    return ""
}
func setPlist(value:String,path:String) ->Void {
    guard let fullPath = getFull(at: path)  else {
        
        return
    }
    let task = Process()
    task.launchPath = "/usr/libexec/PlistBuddy"
    task.arguments = ["-c", "Set :\(value)",fullPath]
    task.launch()
    task.waitUntilExit()
}

