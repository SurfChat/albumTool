//
//  PhotoBlurHandler.swift
//  SurfTool
//
//  Created by Phenou on 25/11/2023.
//

import Foundation

class PhotoBlurHandler {
    static let share = PhotoBlurHandler()
    
    var percent: Int {
        if totalCount > 0 {
            return 5-Int(totalPercent)/totalCount
        } else {
            return Int.random(in: 1...5)
        }
    }
    
    private var totalCount: Int = 0
    private var totalPercent: Double = 0
    
    static func updateBlur() {
        let lanuchTime = UserDefaults.standard.value(forKey: "sadAlbumLanuchTime") as! Double
        let now = Date().timeIntervalSince1970
        
        // 同一天不更新
        guard !isSameDay(timestamp1: now, timestamp2: lanuchTime) else {
            return
        }

        let albums = PhotoDBHandler.share.queryAlbums()
        for album in albums {
            let datas = PhotoDBHandler.share.queryPhotos(albumID: album.ID)
            if !datas.isEmpty {
                for data in datas {
                    share.totalCount += 1
                    let percent = Double.random(in: 0..<0.30)
                    if data.percent < 1 {
                        data.percent += percent
                    }
                    share.totalPercent += data.percent
                }
                PhotoDBHandler.share.updatePhotos(datas, albumID: album.ID)
            }
        }
    }
}

extension PhotoBlurHandler {
    static func isSameDay(timestamp1: TimeInterval, timestamp2: TimeInterval) -> Bool {
        let date1 = Date(timeIntervalSince1970: timestamp1)
        let date2 = Date(timeIntervalSince1970: timestamp2)
        
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        
        return components1.year == components2.year && components1.month == components2.month && components1.day == components2.day
    }
}
