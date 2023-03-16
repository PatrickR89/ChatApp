//
//  FileManager+Extension.swift
//  ChatApp
//
//  Created by Patrick on 14.03.2023..
//

import Foundation

extension FileManager {
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        return paths[0]
    }

    func getFilePath(_ name: String) -> URL {
        let filePath = getDocumentsDirectory().appendingPathComponent(name)
        return filePath
    }
}
