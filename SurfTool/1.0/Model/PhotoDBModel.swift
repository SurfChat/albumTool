//
//  PhotoDBModel.swift
//  SurfTool
//
//  Created by Phenou on 23/11/2023.
//

import Foundation
import WCDBSwift
import CoreImage
import UIKit

final class PhotoDBModel: TableCodable {
    
    var ID: Int64 = 0
    var percent: Double = 0.0
    var originalImage: Data = Data()
    var albumID: Int64 = 0
    var text: String = ""
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = PhotoDBModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self)

        case ID
        case percent
        case originalImage
        case albumID
        case text
    }
    
}

extension PhotoDBModel {
    func applyGaussianBlur() -> UIImage? {
        let origImage = UIImage(data: self.originalImage) ?? UIImage()
        guard let ciImage = CIImage(image: origImage) else {
            return nil
        }
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        // 根据百分比计算模糊半径
        let w = (UIScreen.main.bounds.width-50)/3.0
        let radius = self.percent * Double(w)
        
        filter?.setValue(radius, forKey: kCIInputRadiusKey)
        
        guard let outputCIImage = filter?.outputImage else {
            return nil
        }
        
        let rect =  CGRect (origin:  CGPoint .zero, size: origImage.size)
        let context = CIContext(options: nil)
        guard let outputCGImage = context.createCGImage(outputCIImage, from:rect) else {
            return nil
        }
                
        let outputImage = UIImage(cgImage: outputCGImage)
        return outputImage
    }
}

final class AlbumDBModel: TableCodable {
    var ID: Int64 = 0
    var coverImage: Data = Data()
    var title: String = "Default"
    /// 主題0 happy 1 sad
    var scheme: Int = 0
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = AlbumDBModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self)

        case ID
        case coverImage
        case title
        case scheme
    }
}
