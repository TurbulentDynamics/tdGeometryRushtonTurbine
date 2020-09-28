//
//  BaffleControl.swift
//  tdLBGeometryRushtonTurbineGUI
//
//  Created by Alex on 2020-09-27.
//  Copyright © 2020 Turbulent Dynamics. All rights reserved.
//

import Foundation
import SwiftUI
import tdLBGeometryRushtonTurbineLib

struct BaffleControl: View {
    @ObservedObject var baffles: Baffles

    var body: some View {
        List {
            SliderControl("Count", value: $baffles.numBaffles.bindDouble, in: 1...10, output: baffles.numBaffles.description)
            SliderControl("Inner Radius", value: $baffles.innerRadius.bindDouble, in: 1...10, output: baffles.innerRadius.description)
            SliderControl("Outer Radius", value: $baffles.outerRadius.bindDouble, in: 100...300, output: baffles.outerRadius.description)
            SliderControl("Width", value: $baffles.thickness.bindDouble, in: 1...100, output: baffles.thickness.description)
        }
        .navigationBarTitle("Baffles")
    }
}
