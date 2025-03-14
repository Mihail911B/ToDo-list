//
//  NotesLocalStore.swift
//  Notes
//
//  Created by М Й on 14.03.2025.
//
import UIKit

class NotesLocalStore {
    private static let fileName = "notes.json"
    
    private static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private static func fileURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent(fileName)
    }
    
    static func loadNotes() -> [Note] {
        let url = fileURL()
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let notes = try decoder.decode([Note].self, from: data)
            return notes
        } catch {
            print("Ошибка загрузки заметок: \(error)")
        }
        return []
    }
    
    static func saveNotes(_ notes: [Note]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(notes)
            try data.write(to: fileURL())
        } catch {
            print("Ошибка сохранения заметок: \(error)")
        }
    }
}
