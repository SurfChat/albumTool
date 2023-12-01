//
//  IslandAttributes.swift
//  SurfTool
//
//  Created by Phenou on 30/11/2023.
//

import Foundation
import ActivityKit

struct islandAttributes: ActivityAttributes {
   
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var star: Int
    }
}

