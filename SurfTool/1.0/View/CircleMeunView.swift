//
//  CircleMeunView.swift
//  SurfTool
//
//  Created by Phenou on 7/12/2023.
//

import SwiftUI

struct CircleMeunView: View {
    @State private var showButtons = false

    var addAlbumAction: (() -> Void)?
    var editListAction: (() -> Void)?
    var endEditAction: (() -> Void)?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack (spacing: 20) {
//                Text("Triggers").font(.largeTitle)
//                Text("Button").foregroundColor(.gray).font(.title)
                Spacer()
            }.frame(maxWidth: .infinity)
            
            Group {
                Button(action:editListClick){
                    Image(systemName: "trash").padding(.all,15)
                        .rotationEffect(.degrees(showButtons ? 0 : -90), anchor: .center)
                }.background(Circle().fill(Color.white).shadow(radius: 8, x: 4, y: 4))
                    .offset(x: 0, y: showButtons ? -110 : 0)
                    .opacity(showButtons ? 1 : 0 )
                    .foregroundColor(.black)
              
                Button(action: addAlbumClick){
                    Image(systemName: "rectangle.stack.badge.plus").padding(.all,15)
                        .rotationEffect(.degrees(showButtons ? 0 : 90), anchor: .center)
                }.background(Circle().fill(Color.white).shadow(radius: 8, x: 4, y: 4))
                    .offset(x: showButtons ? -70 : 0, y: showButtons ? -70 : 0)
                    .opacity(showButtons ? 1 : 0 )
                    .foregroundColor(.black)
             
                Button(action: endEditListClick){
                    Image(systemName: "trash.slash").padding(.all,15)
                        .rotationEffect(.degrees(showButtons ? 0 : 90), anchor: .center)
                }.background(Circle().fill(Color.white).shadow(radius: 8, x: 4, y: 4))
                    .offset(x: showButtons ? -110 : 0, y: 0)
                    .opacity(showButtons ? 1 : 0 )
                    .foregroundColor(.black)
                
                Button(action: menuClick){
                    Image(systemName: "plus").padding(.all,15)
                        .rotationEffect(.degrees(showButtons ? 0 : 90), anchor: .center)
                }.background(Circle().fill(Color.white).shadow(radius: 8, x: 4, y: 4))
                    .foregroundColor(.black)
                    .font(.title)
            }
                .accentColor(.white)
                .animation(.default, value: showButtons)
        }
    }
    
    private func editListClick() {
        menuClick()
        editListAction?()
    }
    
    private func endEditListClick() {
        menuClick()
        endEditAction?()
    }
    
    private func addAlbumClick() {
        menuClick()
        addAlbumAction?()
    }
    
    private func menuClick() {
        self.showButtons.toggle()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CircleMeunView()
    }
}
