//
//  ContentView.swift
//  tdGeometryRushtonTurbine
//
//  Created by  Ivan Ushakov on 24.01.2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

import SwiftUI
import tdLBGeometryRushtonTurbineLib

struct ContentView: View {
    @State var engine: Engine
    @State var turbine: RushtonTurbine

    #if targetEnvironment(macCatalyst)
    var body: some View {
        NavigationView {
            NewControlView(turbine: turbine)
                .navigationBarTitle("")
                .navigationBarHidden(true)
            RenderView(engine: engine)
        }
    }
    #else
    var body: some View {
        TabBarView(engine: engine, turbine: turbine)
    }
    #endif
}

struct TabBarView: View {
    var engine: Engine
    var turbine: RushtonTurbine
    
    enum Tab: Int {
        case control, render
    }

    func tabItem(text: String) -> some View {
        VStack {
            Text(text)
        }
    }

    var body: some View {
        TabView() {
            RenderView(engine: engine).tabItem{
                self.tabItem(text: "Render")
            }.tag(Tab.render)

            NewControlView(turbine: turbine).tabItem {
                self.tabItem(text: "NewControl")
            }.tag(Tab.control)

            
        }.edgesIgnoringSafeArea(.top)
    }
}
