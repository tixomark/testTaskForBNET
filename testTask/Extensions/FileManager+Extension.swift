//
//  FileManager+Extension.swift
//  testTask
//
//  Created by tixomark on 4/29/23.
//

import Foundation

extension FileManager {
    var imagesDir: URL {
        let userDomain = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let picturesDir = FileManager.default.createDir(named: "images", in: userDomain)
        
        return picturesDir
    }
    
    private func createDir(named dirName: String, in rootDir: URL) -> URL {
        var dirURL: URL!
        
        if let newDirURL = URL(string: rootDir.absoluteString + dirName + "/") {
            if FileManager.default.directoryExists(atUrl: newDirURL) {
//                print("directory named \(dirName) already exists")
                dirURL = newDirURL
                
            } else {
                do {
                    try FileManager.default.createDirectory(at: newDirURL, withIntermediateDirectories: true)
                    print("duccessfully created \(dirName)")
                    dirURL = newDirURL
                } catch {
                    print("An error occured while creating \(dirName)")
                }
            }
            
        } else {
            dirURL = rootDir
            print("Can not create directory \(dirName)")
        }
        
        return dirURL
    }
    
    func directoryExists(atUrl url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = self.fileExists(atPath: url.path, isDirectory:&isDirectory)
        return exists && isDirectory.boolValue
    }
    
   
}
