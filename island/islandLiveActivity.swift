//
//  islandLiveActivity.swift
//  island
//
//  Created by Phenou on 30/11/2023.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct islandLiveActivity: Widget {
    var body: some WidgetConfiguration {
        
        ActivityConfiguration(for: islandAttributes.self) { context in
            // Lock screen/banner UI goes here
//            VStack {
//                Text("Hello \(context.state.emoji)")
//            }
//            .activityBackgroundTint(Color.cyan)
//            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    IslandLeading()
                }
                DynamicIslandExpandedRegion(.trailing) {
                    IslandTrailing()
                }
                DynamicIslandExpandedRegion(.center) {
                    IslandCenter(count: context.state.star)
                }
                
            } compactLeading: {
                Image("miniLogo", bundle: nil).frame(width: 15, height: 15)
            } compactTrailing: {
                
            } minimal: {
                Image("miniLogo", bundle: nil)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

struct IslandTrailing: View {
    
    var body: some View {
        Image("double_tap_white", bundle: nil)
            .scaledToFill()
            .frame(width: 50 ,height: 50)
    }
}

struct IslandLeading: View {
    
    var body: some View {
        Image("logo", bundle: nil)
            .clipShape(.rect(cornerRadius: 10))
            .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
            .frame(width: 58 ,height: 58)
       
    }
}

struct IslandCenter: View {
    var count: Int
    
    var body: some View {
        HStack {

            ForEach(0..<5) { i in
                if i > count-1 {
                    Image("launch_shape_2", bundle: nil)
                } else {
                    Image("launch_shape_1", bundle: nil)
                }
            }
        }

    }
}
