import Foundation
import Yams
import HIPAACheckerCore
import UIKit

public struct HIPAAChecker {
    public private(set) var token = ""
    public private(set) var projectPath = "/Users/userName/projectDirectory/projectName"
    public private(set) var view = UIView()

    var results : [String:Any] = [:]

    public init(_ token: String) {
        self.token = token
        self.getProjectInformation(token: self.token)
    }
    public init(in view: UIView, projectPath: String, email: String, password: String) {
        self.projectPath = projectPath
        self.view = view
        self.auth(email, password: password)
    }

    
    func initializePackage(withToken token: String) {
        // Perform package initialization using the token...
        self.getProjectInformation(token: token)
//        self.getRules(token, projectId: "")
    }
    
    public func getRules(_ token: String, projectId: String){
        APIManager().getRules(token){ result in
            switch result {
            case .success(let data):
                if let responseData = data {
                    print("rule fetch successful")
                    parseRules(responseData, projectId: projectId, token: token)
                } else {
                    print("rule fetch successful, but no rule")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    HUDHelper.showToast(in: view, message: (error.localizedDescription))
                }
                print("Error:", error)
            }
        }
    }
    
    public func getProjectInformation(token: String){
        let bundleName = Bundle.main.bundleIdentifier ?? ""
        let appName = Bundle.main.appName

        APIManager().getProjectInformation(name: appName, bundle:bundleName, token: token ){ result in
            switch result {
            case .success(let data):
                if let responseData = data {
                    self.getRules(token, projectId: responseData)
                    print("Project info fetch successful")
                } else {
                    print("Project info fetch successful, but no rule")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    HUDHelper.showToast(in: view, message: (error.localizedDescription))
                }
                print("Error:", error)
            }
        }
    }
    
    public func sendHIPAAReport(projectId: String, result: [String : Any], token: String){
        APIManager().postHIPAACheckerResults(projectId: projectId, result: result, token: token){ result in
            switch result {
            case .success(let data):
                print(data ?? Data())
                if let responseData = data {
                    print("send report  successful")
                } else {
                    print("send report not successful")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    HUDHelper.showToast(in: view, message: (error.localizedDescription))
                }
                print("Error:", error.localizedDescription)
            }
        }
    }
    
    public func auth(_ email: String, password: String){
        APIManager().authenticate(email: email, password: password) { result in
            switch result {
            case .success(let token):
                if let token = token {
                    print("Authentication successful. Token: \(token)")
                    initializePackage(withToken: token)

                } else {
                    print("Authentication successful, but no token received")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    HUDHelper.showToast(in: view, message: (error.localizedDescription))
                }

                print("Error:", error)
            }
        }
    }
        
    struct RegexObject: Codable {
        let id: String
        let description: String
        let type: String
        let pattern: [String]
        let severity: String
    }
    
    func parseRules(_ responseData: Data, projectId: String?, token: String){
                
        if let jsonData = try? JSONSerialization.jsonObject(with: responseData, options: []), let jsonArray = jsonData as? [[String: Any]]{
            print("Parsed JSON data: \(jsonArray)")
            for patternDictionary in jsonArray {
                
                if let array = patternDictionary["audit"] as? [[String: Any]] {
                    var audit: [RegexObject] = []

                    for pattern in array {
                        if let jsonData = try? JSONSerialization.data(withJSONObject: pattern),let regex = try? JSONDecoder().decode(RegexObject.self, from: jsonData) {
                                audit.append(regex)
                        } else {
                            print("Failed to decode JSON dictionary into regex")
                        }
                    }
                    self.processRule(audit, projectId: projectId ?? "0", token: token)

                }
                else if let array = patternDictionary["authorization"] as? [[String: Any]] {
                    var authorization: [RegexObject] = []

                    for pattern in array {
                        if let jsonData = try? JSONSerialization.data(withJSONObject: pattern),let regex = try? JSONDecoder().decode(RegexObject.self, from: jsonData) {
                                authorization.append(regex)
                        } else {
                            print("Failed to decode JSON dictionary into regex")
                        }
                    }
                    self.processRule(authorization, projectId: projectId ?? "0", token: token)
                }
                else if let array = patternDictionary["authorization_for_destruction"] as? [[String: Any]] {
                    var authorizationForDestruction: [RegexObject] = []

                    for pattern in array {
                        if let jsonData = try? JSONSerialization.data(withJSONObject: pattern),let regex = try? JSONDecoder().decode(RegexObject.self, from: jsonData) {
                                authorizationForDestruction.append(regex)
                        } else {
                            print("Failed to decode JSON dictionary into regex")
                        }
                    }
                    self.processRule(authorizationForDestruction, projectId: projectId ?? "0", token: token)
                }
                else if let array = patternDictionary["data_integrity"] as? [[String: Any]] {
                    var dataIntegrity: [RegexObject] = []

                    for pattern in array {
                        if let jsonData = try? JSONSerialization.data(withJSONObject: pattern),let regex = try? JSONDecoder().decode(RegexObject.self, from: jsonData) {
                                dataIntegrity.append(regex)
                        } else {
                            print("Failed to decode JSON dictionary into regex")
                        }
                    }
                    self.processRule(dataIntegrity, projectId: projectId ?? "0", token: token)
                }
                else if let array = patternDictionary["encryption_decryption"] as? [[String: Any]] {
                    var encryptionDecryption: [RegexObject] = []

                    for pattern in array {
                        if let jsonData = try? JSONSerialization.data(withJSONObject: pattern), let regex = try? JSONDecoder().decode(RegexObject.self, from: jsonData) {
                                encryptionDecryption.append(regex)
                        } else {
                            print("Failed to decode JSON dictionary into regex")
                        }
                    }
                    self.processRule(encryptionDecryption, projectId: projectId ?? "0", token: token)
                }
                else if let array = patternDictionary["guard_against_com_network"] as? [[String: Any]] {
                    var guardAgainstComNetwork: [RegexObject] = []

                    for pattern in array {
                        if let jsonData = try? JSONSerialization.data(withJSONObject: pattern), let regex = try? JSONDecoder().decode(RegexObject.self, from: jsonData) {
                                guardAgainstComNetwork.append(regex)
                        } else {
                            print("Failed to decode JSON dictionary into regex")
                        }
                    }
                    self.processRule(guardAgainstComNetwork, projectId: projectId ?? "0", token: token)
                }
                else if let array = patternDictionary["phi_encryption"] as? [[String: Any]] {
                    var phiEncryption: [RegexObject] = []

                    for pattern in array {
                        if let jsonData = try? JSONSerialization.data(withJSONObject: pattern), let regex = try? JSONDecoder().decode(RegexObject.self, from: jsonData) {
                                phiEncryption.append(regex)
                        } else {
                            print("Failed to decode JSON dictionary into regex")
                        }
                    }
                    self.processRule(phiEncryption, projectId: projectId ?? "0", token: token)
                }
                else if let array = patternDictionary["transmition_secuirity"] as? [[String: Any]] {
                    var transmitionSecurity: [RegexObject] = []

                    for pattern in array {
                        if let jsonData = try? JSONSerialization.data(withJSONObject: pattern), let regex = try? JSONDecoder().decode(RegexObject.self, from: jsonData) {
                                transmitionSecurity.append(regex)
                        } else {
                            print("Failed to decode JSON dictionary into regex")
                        }
                    }
                    self.processRule(transmitionSecurity, projectId: projectId ?? "0", token: token)
                }
                else if let array = patternDictionary["unique_id"] as? [[String: Any]] {
                    var uniqueId: [RegexObject] = []

                    for pattern in array {
                        if let jsonData = try? JSONSerialization.data(withJSONObject: pattern), let regex = try? JSONDecoder().decode(RegexObject.self, from: jsonData) {
                                uniqueId.append(regex)
                        } else {
                            print("Failed to decode JSON dictionary into regex")
                        }
                    }
                    self.processRule(uniqueId, projectId: projectId ?? "0", token: token)
                }
                else if let array = patternDictionary["user_authentication"] as? [[String: Any]] {
                    var userAuthentication: [RegexObject] = []

                    for pattern in array {
                        if let jsonData = try? JSONSerialization.data(withJSONObject: pattern), let regex = try? JSONDecoder().decode(RegexObject.self, from: jsonData) {
                                userAuthentication.append(regex)
                        } else {
                            print("Failed to decode JSON dictionary into regex")
                        }
                    }
                    self.processRule(userAuthentication, projectId: projectId ?? "0", token: token)
                }
                else if let array = patternDictionary["user_inactivity"] as? [[String: Any]] {
                    var userInactivity: [RegexObject] = []

                    for pattern in array {
                        if let jsonData = try? JSONSerialization.data(withJSONObject: pattern), let regex = try? JSONDecoder().decode(RegexObject.self, from: jsonData) {
                                userInactivity.append(regex)
                        } else {
                            print("Failed to decode JSON dictionary into regex")
                        }
                    }
                    self.processRule(userInactivity, projectId: projectId ?? "0", token: token)
                }
                
            }
        }
        else{
            print("Error parsing JSON")

        }
        
    }
    func processRule(_ rules: [RegexObject], projectId: String, token: String){
        var hipaaChecker = self.findPatternsForRules(rule: rules)
        var result = [String: Any]()
        hipaaChecker = hipaaChecker.filter { $0.matched_data.count != 0}

        hipaaChecker.enumerated().forEach { (index, element) in
            var params = [String: Any]()
            params["filepath"] = element.filepath as Any
            params["filename"] = element.filename as Any
            params["description"] = element.description as Any
            params["pattern"] = element.pattern as Any
            params["rule_name"] = element.rule_name as Any
            params["matched_data"] = element.matched_data as Any

            result["\(index)"] = params as Any

        }
        print(result)
        if (result.count != 0){
            self.sendHIPAAReport(projectId: projectId, result: result, token: token)
        }

    }

    func findPatternsForRules(rule: [RegexObject]) -> [(filepath: String, filename: String, description: String, pattern: [String], matched_data: [[String]], rule_name: String)]{
//        let currentFileURL = URL(fileURLWithPath: #file)
//
//        // Navigate up to the directory containing Package.swift
//        let packageDirectoryURL = currentFileURL
//            .deletingLastPathComponent() // Remove the filename
//            .deletingLastPathComponent() // Navigate up one directory
//            .deletingLastPathComponent()
//            .deletingLastPathComponent()
//            .deletingLastPathComponent() // Navigate up one more directory to the SPM project root
//
//        print("Directory of the SPM project:", packageDirectoryURL.path)
//        print("Directory of the SPM project:", packageDirectoryURL.path)
//
        
        return traverseAndRegexCheck(inDirectory: projectPath, regexPatterns: rule)

    }

    
    func traverseAndRegexCheck(inDirectory directoryPath: String, regexPatterns: [RegexObject]) -> [(filepath: String, filename: String, description: String, pattern: [String], matched_data: [[String]], rule_name: String)] {
        var filesWithPattern: [(filepath: String, filename: String, description: String, pattern: [String], matched_data: [[String]], rule_name: String)] = []

        // Function to recursively search for Swift files
        func searchForSwiftFiles(inDirectory directoryPath: String) {
            let fileManager = FileManager.default

            do {
                // Get the contents of the directory
                let contents = try fileManager.contentsOfDirectory(atPath: directoryPath)

                // Iterate through each item in the directory
                for item in contents {
                    let itemPath = URL(fileURLWithPath: directoryPath).appendingPathComponent(item).path
                    var isDirectory: ObjCBool = false

                    // Check if the item is a directory
                    if fileManager.fileExists(atPath: itemPath, isDirectory: &isDirectory) {
                        // Recursively search if it's a directory
                        if isDirectory.boolValue {
                            searchForSwiftFiles(inDirectory: itemPath)
                        } else {
                            // Check if it's a Swift file
                            if item.hasSuffix(".swift") {
                                // Perform regex check
                                if let fileContents = try? String(contentsOfFile: itemPath) {

                                    for patternList in regexPatterns {
                                        var pattern: [String] = []
                                        var match: [[String]] = []

                                        for patternString in patternList.pattern{
                                            pattern.append(patternString)
                                           let matchString = findLineNumbers(forPattern: patternString, inString: fileContents)
                                            if (matchString.count != 0){
                                                match.append(matchString)
                                            }
                                            print(match.count)
                                        }
                                        if match.count > 0{
                                            filesWithPattern.append((filepath: itemPath, filename: item, description: patternList.description, pattern: pattern, matched_data: match, rule_name: patternList.id))
                                            
                                        }
                                    }

                                }
                            }
                        }
                    }
                }
            } catch {
                print("Error listing directory:", error)
            }
        }

        // Function to find line numbers for regex pattern in a string
        func findLineNumbers(forPattern pattern: String, inString string: String) -> [String] {
            var match: [String] = []

            let lines = string.components(separatedBy: .newlines)
            for (index, line) in lines.enumerated() {
                if line.range(of: pattern, options: .regularExpression) != nil {
                    let matchData = MatchedData(lineNumber: (index + 1), codeSegment: line)
                    do {
                        let jsonData = try JSONEncoder().encode(matchData)
                        
                        // Convert JSON data to string
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            print(jsonString)
                            match.append(jsonString)
                        }
                    } catch {
                        print("Error encoding objects array to JSON: \(error)")

                    }

                }
            }
            return match
        }

        // Start the recursive search
        searchForSwiftFiles(inDirectory: directoryPath)

        return filesWithPattern
    }



}

extension Bundle {
    var appName: String {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        object(forInfoDictionaryKey: "CFBundleName") as? String ??
        ""
    }
}
