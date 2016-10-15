/**
 This file is part of the SFFocusViewLayout package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

class Repository: DataSource {

    lazy var items: [Resource] = self.generateResourcesFromDocuments()

    private func generateResourcesFromDocuments() -> [Resource] {
        guard let fileURL = Bundle.main
            .url(forResource: "Resources", withExtension: "plist") else {
            fatalError("resource file not found")
        }
        let resourcesFromPlist = NSArray(contentsOf: fileURL)!
        return resourcesFromPlist.map { resourceDictionary in
            guard let dictionary = resourceDictionary as? [String : String] else {
                fatalError("invalid dictionary format")
            }
            return Parser.mapElement(element: dictionary)
        }
    }
}

extension Repository {
    private struct Constant {
        static let Filename = "Resources"
        static let Extension = "plist"
    }
}
