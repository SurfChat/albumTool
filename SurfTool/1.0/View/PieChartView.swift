//
//  PieChartView.swift
//  SurfTool
//
//  Created by Phenou on 7/12/2023.
//

import SwiftUI
 
struct PieChartView: View {
    var values: [Double] = []
    
    var pieSizeRatio: Double = 0.8
    var holeSizeRatio: Double = 0
    var lineWidthMultiplier: Double = 0
    
    var colors: [Color] = []
    var backgroundColor: Color = .init(UIColor.clear)
    // Color.teal is for iOS 15.0+
    let teal: Color = .init(red: 48 / 255, green: 176 / 255, blue: 199 / 255)
    var defaultColors: [Color] { [.blue, .green, .orange, .purple, .red, teal, .yellow] }
    

    
    var body: some View {
        GeometryReader { geometry in
            
            let totalValue = values.reduce(0, +)
            let angles = values.reduce(into: [-180.0]) { (angles, value) in
                angles.append(angles.last! + value / totalValue * 180)
            }
            let shorterSideLength: CGFloat = min(geometry.size.width, geometry.size.height)
            let center: CGPoint = .init(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let lineWidth: CGFloat = shorterSideLength * pieSizeRatio * lineWidthMultiplier
            let radius: CGFloat = shorterSideLength * pieSizeRatio / 2 + lineWidth / 2
            let holeRadius: CGFloat = radius * holeSizeRatio - lineWidth / 4
            
            ZStack {
                // Slices
                ForEach (values.indices, id: \.self ) { i in
                    let path = Path { path in
                        path.move(to: center)
                        path.addArc(center: center,
                                    radius: radius,
                                    startAngle: Angle(degrees: angles[i]),
                                    endAngle: Angle(degrees: angles[i + 1]),
                                    clockwise: false)
                        path.closeSubpath()
                    }
                    path
                        .fill(colors[i % colors.count])
                        .overlay(path.stroke(backgroundColor, lineWidth: lineWidth))
                }
                
                // Hole
                Path { path in
                    path.move(to: center)
                    path.addArc(center: center,
                                radius: holeRadius,
                                startAngle: Angle(degrees: -180),
                                endAngle: Angle(degrees: 0),
                                clockwise: false)
                    path.closeSubpath()
                }
                .fill(backgroundColor)
            }
            .background(backgroundColor)
            .clipped()
        }
    }
}
 
extension PieChartView {
    
    struct Configuration {
        
        var pieSizeRatio: Double
        var lineWidthMultiplier: Double
        var holeSizeRatio: Double
        
        public init(
            space: Double = 0,
            hole: Double = 0,
            pieSizeRatio: Double = 0.8
        ) {
            self.pieSizeRatio = min(max(pieSizeRatio, 0), 1)
            self.lineWidthMultiplier = min(max(space, 0), 1) / 10
            self.holeSizeRatio = min(max(hole, 0), 1)
        }
    }
    
    struct Item<Value> {
        
        let value: Value
        let color: Color
        
        public init(value: Value, color: Color) {
            self.value = value
            self.color = color
        }
    }
    
    init(
        values: [some BinaryInteger],
        colors: [Color] = [],
        backgroundColor: Color = .init(UIColor.systemBackground),
        configuration: Configuration = .init()
    ) {
        self.values = values.map { Double($0) }
        self.colors = colors.isEmpty ? defaultColors : colors
        self.pieSizeRatio = configuration.pieSizeRatio
        self.lineWidthMultiplier = configuration.lineWidthMultiplier
        self.holeSizeRatio = configuration.holeSizeRatio
        self.backgroundColor = backgroundColor
    }

}

