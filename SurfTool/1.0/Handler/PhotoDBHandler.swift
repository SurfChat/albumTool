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
    
    var showGuide = false
    
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
    func addPhotos(_ selectedPhotos: [ZLResultModel], albumID: Int64, albumType: Int) {
        
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
            model.createTime = Date().toString()
            if albumType == 1 {
                let percent = Double.random(in: 0..<0.30)
                model.percent = percent
                if firstAdd && i == selectedPhotos.count-1 {
                    model.percent = 1
                }
            }
            dbModels.append(model)
        }
        
        do {
            try self.db.run(transaction: { _ in
                let table = self.db.getTable(named:self.tableName, of: PhotoDBModel.self)
                try table.insert(dbModels)
                self.dbDataUpdate?()
                if albumType == 1 {
                    PHPhotoLibrary.shared().performChanges {
                        PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
                    }
                }
            })
        } catch let error {
            print("『db insert error \(error)』")
        }
        
        // 更新相册封面
        updateAlbumCover(ID: albumID, coverImage: dbModels.last)
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
            updateAlbumCover(ID: albumID, coverImage: photo)
        }
    }
    
    func updatePhotoText(_ photo: PhotoDBModel, albumID: Int64) {
        do {
            try self.db.run(transaction: { _ in
                let table = self.db.getTable(named:self.tableName, of: PhotoDBModel.self)
                try table.update(on: PhotoDBModel.Properties.text, with: photo, where: PhotoDBModel.Properties.ID == photo.ID)
            })
        } catch let error {
            print("『db update error \(error)』")
        }
        self.dbDataUpdate?()
    }
    
    func updatePhotoOriImage(_ photo: PhotoDBModel, albumID: Int64, updateAlbum: Bool = false) {
        do {
            try self.db.run(transaction: { _ in
                let table = self.db.getTable(named:self.tableName, of: PhotoDBModel.self)
                try table.update(on: PhotoDBModel.Properties.originalImage, with: photo, where: PhotoDBModel.Properties.ID == photo.ID)
            })
        } catch let error {
            print("『db update error \(error)』")
        }
        self.dbDataUpdate?()
        
        if updateAlbum {
            // 更新相册封面
            updateAlbumCover(ID: albumID, coverImage: photo)
        }
    }
    
    func queryPhotosInfo() -> [Int] {
        var happys = 0
        var sads = 0
        
        let albums = PhotoDBHandler.share.queryAlbums()
        for album in albums {
            let datas = PhotoDBHandler.share.queryPhotos(albumID: album.ID)
            happys += datas.count
        }
        
        let albums1 = PhotoDBHandler.share.queryAlbums(scheme: 1)
        for album in albums1 {
            let datas = PhotoDBHandler.share.queryPhotos(albumID: album.ID)
            sads += datas.count
        }
        
        if happys > 0 || sads > 0 {
            return [happys, sads]
        } else {
            return []
        }
    }
    
    // MARK: Album增删改查
    func addAlbum(_ albumData: AlbumDBModel) {
        let albums = PhotoDBHandler.share.queryAlbums()
        albumData.ID = Int64(albums.count)
        albumData.createTime = Date().toString()
        
        do {
            try self.db.run(transaction: { _ in
                let table = self.db.getTable(named:self.albumTableName, of: AlbumDBModel.self)
                try table.insert(albumData)
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
        
        dbAlbumDataUpdate?()
    }
    
    func queryAlbums(scheme: Int = 0) -> [AlbumDBModel] {
        
        do {
            let table = db.getTable(named:albumTableName, of: AlbumDBModel.self)
            let objects: [AlbumDBModel] = try table.getObjects(where: AlbumDBModel.Properties.scheme == scheme)
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
    
    func updateAlbumCover(ID: Int64, coverImage: PhotoDBModel?) {
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
    
    // 新用户示例
    func createExampleAlbum() {
        if queryAlbum(ID: 0) != nil {
            return
        }
        
        showGuide = true
        
        let album = AlbumDBModel()
        album.title = "Nice Party"
        album.scheme = 0
        album.ID = 0
        album.createTime = Date().toString()
        
        do {
            try self.db.run(transaction: { _ in
                let table = self.db.getTable(named:self.albumTableName, of: AlbumDBModel.self)
                try table.insert(album)
                self.dbAlbumDataUpdate?()
            })
        } catch let error {
            print("『db insert error \(error)』")
        }
        
        var dbModels: [PhotoDBModel] = []
        for i in 0..<4 {
            let str = "example_\(i)"
            let photo = UIImage(named: str)
            let imageData = photo!.jpegData(compressionQuality: 0)
            let model = PhotoDBModel()
            model.ID = Int64(Date().timeIntervalSince1970 * 1000)
            model.albumID = album.ID
            model.originalImage = imageData ?? Data()
            model.createTime = Date().toString()
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
        
        // 更新相册封面
        updateAlbumCover(ID: album.ID, coverImage: dbModels.last)
    }
}
