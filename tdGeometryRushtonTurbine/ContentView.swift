//
//  ContentView.swift
//  tdGeometryRushtonTurbine
//
//  Created by  Ivan Ushakov on 24.01.2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    var engine: Engine

    #if targetEnvironment(macCatalyst)
    var body: some View {
        NavigationView {
            ControlView(control: engine.controlModel)
            RenderView(engine: engine)
        }
    }
    #else
    var body: some View {
        TabBarView(engine: engine)
    }
    #endif
}

struct TabBarView: View {

    var engine: Engine

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
            NavigationView {
                ControlView(control: engine.controlModel)
            }.tabItem {
                self.tabItem(text: "Control")
            }.tag(Tab.control)
            RenderView(engine: engine).tabItem{
                self.tabItem(text: "Render")
            }.tag(Tab.render)
        }.edgesIgnoringSafeArea(.top)
    }
}
