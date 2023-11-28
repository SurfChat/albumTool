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
import Photos

class PhotoDBHandler {
    static let share = PhotoDBHandler()
    
    var dbDataUpdate: (() -> Void)?
    var dbAlbumDataUpdate: (() -> Void)?
    
    private lazy var db: Database = {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let dbName = "photoData.db"
        let dbPath = documentsDirectory!.appendingPathComponent(dbName).path
        return Database(at: dbPath)
    }()
    
    private let tableName = "photoDataTable"
    private let albumTableName = "albumDataTable"
    
    init() {
        do {
            if try !db.isTableExists(tableName) {
                try db.create(table: tableName, of: PhotoDBModel.self)
            }
            if try !db.isTableExists(albumTableName) {
                try db.create(table: albumTableName, of: AlbumDBModel.self)
            }
        } catch let error {
            print("『db create error \(error)』")
        }
    }
    
    // MARK: Photo增删改查
    func addPhotos(_ selectedPhotos: [ZLResultModel], albumID: Int64) {
        
        let firstAdd = !UserDefaults.standard.bool(forKey: "newUserAdd")
        
        var dbModels: [PhotoDBModel] = []
        var assets: [PHAsset] = []
        
        for i in 0..<selectedPhotos.count {
            let photo = selectedPhotos[i]
            assets.append(photo.asset)
            let imageData = photo.image.jpegData(compressionQuality: 0)
            let model = PhotoDBModel()
            model.ID = Int64(Date().timeIntervalSince1970 * 1000)
            model.albumID = albumID
            model.originalImage = imageData ?? Data()
            let percent = Double.random(in: 0..<0.30)
            model.percent = percent
            if firstAdd && i == selectedPhotos.count-1 {
                model.percent = 1
            }
            dbModels.append(model)
        }
        
        do {
            try self.db.run(transaction: { _ in
                let table = self.db.getTable(named:self.tableName, of: PhotoDBModel.self)
                try table.insert(dbModels)
                self.dbDataUpdate?()
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
                }
            })
        } catch let error {
            print("『db insert error \(error)』")
        }
        
        // 更新相册封面
        updateAlbumPhotos(ID: albumID, coverImage: dbModels.last)
    }
    
    func deletePhotos(_ selectedPhotos: [PhotoDBModel], albumID: Int64) {
        
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
    
    func queryPhotos(albumID: Int64) -> [PhotoDBModel] {
        
        do {
            let table = db.getTable(named:tableName, of: PhotoDBModel.self)
            let objects: [PhotoDBModel] = try table.getObjects(where: PhotoDBModel.Properties.albumID == albumID)
            return objects.reversed()
        } catch let error {
            print("『db query error \(error)』")
        }
        return []
        
    }
    
    func updatePhotos(_ updatedPhotos: [PhotoDBModel], albumID: Int64) {
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
    
    func updatePhoto(_ photo: PhotoDBModel, albumID: Int64, updateAlbum: Bool = false) {
        do {
            try self.db.run(transaction: { _ in
                let table = self.db.getTable(named:self.tableName, of: PhotoDBModel.self)
                try table.update(on: PhotoDBModel.Properties.percent, with: photo, where: PhotoDBModel.Properties.ID == photo.ID)
            })
        } catch let error {
            print("『db update error \(error)』")
        }
        
        if updateAlbum {
            // 更新相册封面
            updateAlbumPhotos(ID: albumID, coverImage: photo)
        }
    }
    
    // MARK: Album增删改查
    func addAlbum(_ albumTitle: String?) {
        let album = AlbumDBModel()
        if let title = albumTitle {
            album.title = title
        }
        let albums = PhotoDBHandler.share.queryAlbums()
        album.ID = Int64(albums.count)
        
        do {
            try self.db.run(transaction: { _ in
                let table = self.db.getTable(named:self.albumTableName, of: AlbumDBModel.self)
                try table.insert(album)
                self.dbAlbumDataUpdate?()
            })
        } catch let error {
            print("『db insert error \(error)』")
        }
    }
    
    func deleteAlbum(_ albums: [AlbumDBModel]) {
        for album in albums {
            let photos = queryPhotos(albumID: album.ID)
            deletePhotos(photos, albumID: album.ID)
            do {
                try self.db.run(transaction: { _ in
                    let table = self.db.getTable(named:self.albumTableName, of: AlbumDBModel.self)
                    try table.delete(where: AlbumDBModel.Properties.ID == album.ID)
                })
            } catch let error {
                print("『im db delete error \(error)』")
            }
        }
        
        let albums = queryAlbums()
        
        if albums.isEmpty {
            NotificationCenter.default.post(name: Notification.Name("changeRootVc"), object: nil)
        } else {
            dbAlbumDataUpdate?()
        }
    }
    
    func queryAlbums() -> [AlbumDBModel] {
        
        do {
            let table = db.getTable(named:albumTableName, of: AlbumDBModel.self)
            let objects: [AlbumDBModel] = try table.getObjects()
            return objects.reversed()
        } catch let error {
            print("『db query error \(error)』")
        }
        return []
        
    }
    
    func queryAlbum(ID: Int64) -> AlbumDBModel? {
        
        do {
            let table = db.getTable(named:albumTableName, of: AlbumDBModel.self)
            let object = try table.getObject(where: AlbumDBModel.Properties.ID == ID)
            return object
        } catch let error {
            print("『db query error \(error)』")
        }
        return nil
        
    }
    
    func updateAlbumTitle(ID: Int64, title: String) {
        let album = AlbumDBModel()
        album.title = title
        
        do {
            try self.db.run(transaction: { _ in
                let table = self.db.getTable(named:self.albumTableName, of: AlbumDBModel.self)
                try table.update(on: AlbumDBModel.Properties.title, with: album, where: AlbumDBModel.Properties.ID == ID)
            })
        } catch let error {
            print("『db update error \(error)』")
        }
    }
    
    func updateAlbumPhotos(ID: Int64, coverImage: PhotoDBModel?) {
        if let coverImage = coverImage {
            let album = AlbumDBModel()
            let imageData = coverImage.applyGaussianBlur()?.jpegData(compressionQuality: 0)
            guard let imageData = imageData else { return }
            album.coverImage = imageData
            
            do {
                try self.db.run(transaction: { _ in
                    let table = self.db.getTable(named:self.albumTableName, of: AlbumDBModel.self)
                    try table.update(on: AlbumDBModel.Properties.coverImage, with: album, where: AlbumDBModel.Properties.ID == ID)
                    
                    self.dbAlbumDataUpdate?()
                })
            } catch let error {
                print("『db update error \(error)』")
            }
        }
    }
}
