//
//  PhotoDBHandler.swift
//  SurfTool
//
//  Created by Phenou on 23/11/2023.
//

import Foundation
import WCDBSwift
import UIKit
import ZLPhotoBrowser

class PhotoDBHandler {
    static let share = PhotoDBHandler()
    
    var dbDataUpdate: (() -> Void)?
    
    private lazy var db: Database = {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let dbName = "photoData.db"
        let dbPath = documentsDirectory!.appendingPathComponent(dbName).path
        return Database(at: dbPath)
    }()
    
    private let tableName = "photoDataTable"
    
    init() {
        do {
            if try !db.isTableExists(tableName) {
                try db.create(table: tableName, of: PhotoDBModel.self)
            }
        } catch let error {
            print("『db create error \(error)』")
        }
    }
    
    func addPhotos(_ selectedPhotos: [ZLResultModel]) {
       
        var dbModels: [PhotoDBModel] = []
        for photo in selectedPhotos {
            let imageData = photo.image.jpegData(compressionQuality: 0)
            let model = PhotoDBModel()
            model.ID = Int64(Date().timeIntervalSince1970)
            model.originalImage = imageData ?? Data()
            let percent = Double.random(in: 0..<0.10)
            model.percent = percent
            dbModels.append(model)
        }
        do {
            try self.db.run(transaction: { _ in
                let table = self.db.getTable(named:self.tableName, of: PhotoDBModel.self)
                try table.insert(dbModels)
                self.dbDataUpdate?()
            })
        } catch let error {
            print("『db insert error \(error)』")
        }
        
    }
    
    func deletePhotos(_ selectedPhotos: [PhotoDBModel]) {
       
        for photo in selectedPhotos {
            do {
                try self.db.run(transaction: { _ in
                    let table = self.db.getTable(named:self.tableName, of: PhotoDBModel.self)
                    try table.delete(where: PhotoDBModel.Properties.ID == photo.ID)
                })
            } catch let error {
                print("『im db delete error \(error)』")
            }
        }
        self.dbDataUpdate?()
        
    }
    
    func queryPhotos() -> [PhotoDBModel]? {
        
        do {
            let table = db.getTable(named:tableName, of: PhotoDBModel.self)
            let objects: [PhotoDBModel] = try table.getObjects()
            return objects.reversed()
        } catch let error {
            print("『db query error \(error)』")
        }
        return []
        
    }
    
    func updatePhotos(_ updatedPhotos: [PhotoDBModel]) {
        for photo in updatedPhotos {
            do {
                try self.db.run(transaction: { _ in
                    let table = self.db.getTable(named:self.tableName, of: PhotoDBModel.self)
                    try table.update(on: PhotoDBModel.Properties.percent, with: photo, where: PhotoDBModel.Properties.ID == photo.ID)
                })
            } catch let error {
                print("『db update error \(error)』")
            }
        }
        self.dbDataUpdate?()
    }
}
