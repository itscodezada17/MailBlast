import Foundation

enum PDFStorageHelper {
    static let fileName = "resume.pdf"

    static var storedResumeURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(fileName)
    }

    static var hasStoredResume: Bool {
        FileManager.default.fileExists(atPath: storedResumeURL.path)
    }

    @discardableResult
    static func importResume(from sourceURL: URL) throws -> URL {
        let destination = storedResumeURL
        let needsScopedAccess = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if needsScopedAccess { sourceURL.stopAccessingSecurityScopedResource() }
        }

        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.copyItem(at: sourceURL, to: destination)
        return destination
    }

    static func resumeData() -> Data? {
        guard hasStoredResume else { return nil }
        return try? Data(contentsOf: storedResumeURL)
    }
}
