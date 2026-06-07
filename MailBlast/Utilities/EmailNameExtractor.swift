import Foundation

enum EmailNameExtractor {
    static func extractFirstName(from email: String) -> String {
        let prefix = email.components(separatedBy: "@").first ?? ""
        let separators = CharacterSet(charactersIn: "._-")
        let firstPart = prefix.components(separatedBy: separators).first ?? prefix
        return capitalizedWord(firstPart)
    }

    static func extractCompanyName(from email: String) -> String {
        let domain = email.components(separatedBy: "@").last ?? ""
        let firstPart = domain.components(separatedBy: ".").first ?? domain
        return capitalizedWord(firstPart)
    }

    private static func capitalizedWord(_ word: String) -> String {
        guard let initial = word.first else { return "" }
        return initial.uppercased() + word.dropFirst().lowercased()
    }
}
