//
//  NewControls.swift
//  tdGeometryRushtonTurbine
//
//  Created by Niall Ó Broin on 06/08/2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

import Foundation
import SwiftUI

import tdLB
import tdLBGeometryRushtonTurbineLib

extension Int {
    //http://ootips.org/yonat/swiftui-binding-type-conversion/
    var bindDouble: Double {
        get { Double(self) }
        set { self = Int(newValue) }
    }
}

struct ControlView: View {
    @State var step = 0
    @ObservedObject var state: RushtonTurbineRenderState
        
    func demo() {

        
        
            
    }
    
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
                
                ImpellersSection(turbine: state.turbine)

            }
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarItems(leading: Text("Rushton Turbine").fontWeight(.bold))
        }
        .listStyle(GroupedListStyle())
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ImpellersSection: View {
    @ObservedObject var turbine: RushtonTurbine
    
    var generateImpeller: Impeller {
        Impeller(blades: Blades(innerRadius: 50, top: 60, thickness: 5, outerRadius: 110, bottom: 130), uav: 0.7, bladeTipAngularVelW0: 0.1, impellerPosition: .random(in: 0...300), disk: Disk(top: 90, bottom: 110, radius: 100), numBlades: 6, firstBladeOffset: 0, hub: Disk(top: 80, bottom: 120, radius: 60))
    }
    
    var body: some View {
        Section(header:
            HStack {
                Text("Impellers")
                Spacer()
                Button(action: { turbine.add(impeller: self.generateImpeller) }
                ) {
                    Image(systemName: "plus.circle.fill")
                }
            }
        ) {
            ForEach(turbine.impellers.sorted(by: { $0.0 < $1.0 }).map { ($0.key, $0.value) }, id: \.0) { (key, impeller) in
                NavigationLink(destination: ImpellerControl(impeller: impeller)) {
                    Text(key)
                }
            }
            .onDelete(perform: delete)
        }
    }
    
    func delete(at offsets: IndexSet) {
        offsets.forEach { offset in
            let key = turbine.impellers.sorted(by: { $0.0 < $1.0 }).map { $0.key }[offset]
            turbine.impellers[key] = nil
        }
        
    }
}
