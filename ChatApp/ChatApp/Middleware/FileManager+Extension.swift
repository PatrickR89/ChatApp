//
//  FileManager+Extension.swift
//  ChatApp
//
//  Created by Patrick on 14.03.2023..
//

import Foundation

extension FileManager {
    /// Method which declares found adress of application's documents whithin own domain.
    /// - Returns: `URL` of document folder
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        return paths[0]
    }

    /// Method which searches for specific file with help of method above.
    /// - Parameter name: Name of the file, for which `URL` adress is required
    /// - Returns: `URL` path of the specific file
    func getFilePath(_ name: String) -> URL {
        let filePath = getDocumentsDirectory().appendingPathComponent(name)
        return filePath
    }
}
