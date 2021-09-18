//
//  DingTalk.swift
//  BlinGoBuildScript
//
//  Created by 董家祎 on 2021/9/9.
//

import Foundation

enum TaskBuildSate {
    case success
    case faild
    var rawValue:String{
        switch self {
        case .success:
            return "<font color=#32CD32>成功</font>"
        case .faild:
           
            return  "<font color=#FF0000>失败</font>"
        }
    }
}


func  dingTaklSend(with state:TaskBuildSate) -> Void {
    
    let jenkinsAddress =  "http://" + ipAddress + ":" + jenkinsPort + "/job/" + App.rawValue.jenkinsAppName + "/"+jenkinsBuildNumber
    
    
    let task = "[#"+jenkinsBuildNumber+"](\(jenkinsAddress))"
    
    let title = App.rawValue.jenkinsAppName + "(" + App.rawValue.packageFileName + ")"
    
    let console = jenkinsAddress + "/console"
     
    let changes = jenkinsAddress + "/changes"
    
    var platformList:[String] = []
 
    if let  iPath = iosPath {
        platformList.append("[iOS](\(iPath))")
    }
    
    if let aPath = androidPath {
        platformList.append("[Android](\(aPath))")
    }
    let list:[String] = [
        "# " + title,
        
    "***",
        "* 任务 ：" + task,
        "* 状态：" + state.rawValue,
        "* 执行人：" + jenkinsBuildUser,
        "* 环境："+environment.rawValue.name,
        "* 平台：" + platformList.joined(separator: ","),
        "* 分支：" + (argumentBranch ?? "null"),
        "\n",
        "<font color=#428CF3>@\(jenkinsUserMobile)</font>"
    ]
    
    
    
    let markDown = list.joined(separator: "\n")

    let content:[String:Any] = [
        "msgtype":"actionCard",
        
        "actionCard":[
            "title":"jenkins 构建完成 ",
            "text":markDown,
            "btnOrientation":"1",
            
            "btns": [
                [
                    "title": "更改记录",
                    "actionURL": changes
                ],
                [
                    "title": "控制台",
                    "actionURL": console
                ]
            ]
        ],
        "at": [
                  "atMobiles": [
                    jenkinsUserMobile
                  ],
                  
                  "isAtAll": false
              ],
    ]
    
    let jsonData = try! JSONSerialization.data(withJSONObject: content, options: [])
    
    let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
    
   let curl = """
    curl 'https://oapi.dingtalk.com/robot/send?access_token=xxxxxxxx' \
     -H 'Content-Type: application/json' \
    -d '\(jsonString)'
    """
    
    shell(curl)
}
