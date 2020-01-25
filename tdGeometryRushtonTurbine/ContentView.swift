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
    
    var body: some View {
        NavigationView {
            RenderView(engine: engine)
        }
    }
}
