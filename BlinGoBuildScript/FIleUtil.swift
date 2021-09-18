//
//  FIleUtil.swift
//  BlinGoBuildScript
//
//  Created by 董家祎 on 2021/8/23.
//

import Foundation


func createDirectory(atPath:String) -> Void {
    do {
        if FileManager.default.fileExists(atPath: atPath) {
            try FileManager.default.removeItem(atPath: atPath)
        }
        try FileManager.default.createDirectory(atPath: atPath, withIntermediateDirectories: true, attributes: nil)
    } catch  {
        printError("createDirectory(atPath:\(atPath)失败:\(error)")
        exit(0)
    }
}

func  moveItem(atPath:String,destPath:String,packName:String,isCopy:Bool) -> Void {
    
    do {
        if(FileManager.default.fileExists(atPath: destPath) == false){
            
            try FileManager.default.createDirectory(atPath: destPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        if isCopy == false {
            try FileManager.default.moveItem(atPath: atPath, toPath: destPath + "/\(packName)")
        }else {
            try FileManager.default.copyItem(atPath: atPath, toPath: destPath + "/\(packName)")
        }
       
        print(ANSIColors.green+"****************\(platform.rawValue.shellName) 导出完成********************")
        print(destPath)
    } catch  {
        printError("打包失败:文件路径转移失败\(error)")
        exit(0)
    }
}
func removeItem(atPath:String) -> Void{
    
    do {
        if(FileManager.default.fileExists(atPath: atPath)) {
            try  FileManager.default.removeItem(atPath: atPath)
        }
       
    } catch  {
        printError("文件删除失败\(error)")
    }
}
public var ipAddress: String {
     var addresses = [String]()
     var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
     if getifaddrs(&ifaddr) == 0 {
         var ptr = ifaddr
         while (ptr != nil) {
             let flags = Int32(ptr!.pointee.ifa_flags)
             var addr = ptr!.pointee.ifa_addr.pointee
             if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                 if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                     var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                     if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                         if let address = String(validatingUTF8:hostname) {
                             addresses.append(address)
                         }
                     }
                 }
             }
             ptr = ptr!.pointee.ifa_next
         }
         freeifaddrs(ifaddr)
     }
     return addresses.first ?? "0.0.0.0"
 }
