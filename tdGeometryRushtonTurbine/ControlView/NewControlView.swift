//
//  NewControls.swift
//  tdGeometryRushtonTurbine
//
//  Created by Niall Ó Broin on 06/08/2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

import Foundation
import SwiftUI
import tdLBGeometryRushtonTurbineLib

extension Int {
    //http://ootips.org/yonat/swiftui-binding-type-conversion/
    var bindDouble: Double {
        get { Double(self) }
        set { self = Int(newValue) }
    }
}

struct NewControlView: View {
    @State var step = 0
    @ObservedObject var state: RushtonTurbineRenderState

    var body: some View {
        NavigationView {
            List {
                
                NavigationLink(destination: TankControl(diameter: $state.turbine.tankDiameter, height: $state.turbine.tankHeight, shaftRadius: $state.turbine.shaft.radius)) {
                    Text("Tank")
                }
                    
                NavigationLink(destination: BaffleControl(baffles: state.turbine.baffles)) {
                    Text("Baffles")
                }
                
                NavigationLink(destination: TransPanControl(state: state)) {
                    Text("Trans Pan")
                }
                
                Section(header:
                    Stepper("Impellers", value: state.turbine.impellerBinding, in: 0...9)
                ) {
                    ForEach(state.turbine.impeller.sorted(by: { $0.0 < $1.0 }).map { ($0.key, $0.value) }, id: \.0) { (key, impeller) in
                        NavigationLink(destination: ImpellerControl(impeller: impeller)) {
                            Text(key)
                        }
                    }
                }
            }
            .navigationBarTitle("Rushton turbine")
            
        }
        .listStyle(GroupedListStyle())
    }
}
