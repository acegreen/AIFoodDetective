import Foundation

class APIResponseLogger {
    static let shared = APIResponseLogger()
    
    private init() {}
    
    func saveResponse(_ response: String, prefix: String) async {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]            
            let filename = "\(prefix).json"
            let fileURL = documentsPath.appendingPathComponent(filename)
            
            try response.write(to: fileURL, atomically: true, encoding: .utf8)
            print("💾 Saved API response to: \(fileURL.path())")
        } catch {
            print("❌ Failed to save API response: \(error.localizedDescription)")
        }
    }
    
    func listSavedResponses() {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let files = try FileManager.default.contentsOfDirectory(at: documentsPath, 
                                                                  includingPropertiesForKeys: nil)
            let jsonFiles = files.filter { $0.pathExtension == "json" }
            
            print("📁 Saved API responses:")
            for file in jsonFiles {
                print("   📄 \(file.lastPathComponent)")
            }
        } catch {
            print("❌ Failed to list saved responses: \(error.localizedDescription)")
        }
    }
    
    func printDocumentsDirectoryContents() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let files = try? FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
        print("📁 Documents directory contents:")
        files?.forEach { print($0.lastPathComponent) }
    }
} 
