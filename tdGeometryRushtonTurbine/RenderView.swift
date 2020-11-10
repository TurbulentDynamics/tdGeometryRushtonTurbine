//
//  RenderView.swift
//  tdGeometryRushtonTurbine
//
//  Created by  Ivan Ushakov on 25.01.2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

import SwiftUI
import SceneKit

struct RenderView: UIViewRepresentable {
    
    var engine: Engine
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<RenderView>) {
            
    }
    
    func makeUIView(context: UIViewRepresentableContext<RenderView>) -> UIView {
        let view = SCNView()
        view.scene = engine.scene
        view.delegate = engine
        view.rendersContinuously = true
        view.allowsCameraControl = true
        return view
    }
}
