//
//  Engine+Shaft.swift
//  tdLBGeometryRushtonTurbineGUI
//
//  Created by Alex on 2020-09-26.
//  Copyright © 2020 Turbulent Dynamics. All rights reserved.
//

import Foundation
import SceneKit

extension Engine {
    func createShaft() {
        let geometry = SCNCylinder(radius: CGFloat(state.turbine.shaft.radius), height: CGFloat(state.turbine.tankHeight))
        geometry.firstMaterial?.diffuse.contents = Palette.metalColor
        geometry.firstMaterial?.lightingModel = .phong

        shaft.geometry = geometry
        shaft.name = "shaft"
        scene.rootNode.addChildNode(shaft)
    }

    func updateShaft(shaftRadius: Int, tankHeight: Int) {
        let geometry = SCNCylinder(radius: CGFloat(shaftRadius), height: CGFloat(tankHeight))
        geometry.firstMaterial?.diffuse.contents = Palette.metalColor
        geometry.firstMaterial?.lightingModel = .phong

        shaft.geometry = geometry
    }
}
