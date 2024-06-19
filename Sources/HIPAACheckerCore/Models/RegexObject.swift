//
//  File.swift
//  
//
//  Created by Macbook Pro on 21/2/24.
//

import Foundation
import Yams

public struct RegexObject: Codable {
    let id: String
    let description: String
    let type: String?
    let pattern: [String]
    let severity: String?

    // MARK: Equatable

//    public static func == (lhs: RuleDescription, rhs: RuleDescription) -> Bool {
//        return lhs.identifier == rhs.identifier
//    }
}

public struct pattern: Codable{
    let pattern: String
}

public struct MatchedData: Codable {
    var lineNumber: Int?
    var codeSegment: String?
    
    public init(lineNumber: Int, codeSegment: String) {
            self.lineNumber = lineNumber
            self.codeSegment = codeSegment
        }
}



// Function to read YAML file and retrieve regex objects
public func readRegexObjects(fromFilePath filePath: String) throws -> [RegexObject] {
    let yamlContent = try String(contentsOfFile: filePath)
    let regexObjects = try YAMLDecoder().decode([RegexObject].self, from: yamlContent)
    return regexObjects
}

public func readFileFromBundle(fileName: String, fileType: String) -> String? {
    if let filePath = Bundle.main.path(forResource: fileName, ofType: fileType) {
        do {
            let fileContents = try String(contentsOfFile: filePath)
            return fileContents
        } catch {
            print("Error reading file: \(error)")
            return nil
        }
    } else {
        print("File not found.")
        return nil
    }
}
