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
    @State var pointCloudEngine: PointCloudEngine
    @State var turbine: RushtonTurbine

    #if targetEnvironment(macCatalyst)
    var body: some View {
        TabBarView(engine: engine, pointCloudEngine: pointCloudEngine, turbine: turbine)
//        NavigationView {
//            ControlView(state: engine.state)
//                .navigationBarTitle("")
//                .navigationBarHidden(true)
//            RenderView(engine: engine)
//        }
    }
    #else
    var body: some View {
        TabBarView(engine: engine, pointCloudEngine: pointCloudEngine, turbine: turbine)
    }
    #endif
}

struct TabBarView: View {
    var engine: Engine
    var pointCloudEngine: PointCloudEngine
    var turbine: RushtonTurbine
    
    enum Tab: Int {
        case render, pointCloud, control
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
            
            PointCloudView(pointCloudEngine: pointCloudEngine).tabItem{
                self.tabItem(text: "PointCloud")
            }.tag(Tab.pointCloud)

            ControlView(state: engine.state).tabItem {
                self.tabItem(text: "Control")
            }.tag(Tab.control)

            
        }.edgesIgnoringSafeArea(.top)
    }
}
