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
    @ObservedObject var turbine: RushtonTurbine

    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: TankControl(diameter: $turbine.tankDiameter, height: $turbine.tankHeight, shaftRadius: $turbine.shaft.radius)) {
                    Text("Tank")
                }
                    
                NavigationLink(destination: BaffleControl(baffles: turbine.baffles)) {
                    Text("Baffles")
                }
                
                Section(header:
                    Stepper("Impellers", value: turbine.impellerBinding, in: 0...9)
                ) {
                    ForEach(turbine.impeller.sorted(by: { $0.0 < $1.0 }).map { ($0.key, $0.value) }, id: \.0) { (key, impeller) in
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

extension RushtonTurbine {
    var impellerBinding: Binding<Int> {
        Binding(get: { self.impeller.count }, set: { newCount in
            if newCount > self.impeller.count {
                self.impeller["\(newCount)"] = Impeller(blades: Blades(innerRadius: 50, top: 60, thickness: 5, outerRadius: 110, bottom: 130), uav: 0.7, bladeTipAngularVelW0: 0.1, impellerPosition: 100, disk: Disk(top: 90, bottom: 110, radius: 100), numBlades: 6, firstBladeOffset: 0, hub: Disk(top: 80, bottom: 120, radius: 60))
            } else {
                if let key = self.impeller.keys.sorted(by: >).first {
                    self.impeller[key] = nil
                }
                
            }
        })
    }
}


extension NewControlView {
    struct TankControl: View {
        @Binding var diameter: Int
        @Binding var height: Int
        @Binding var shaftRadius: Int

        let width:CGFloat = 70

        var body: some View {
            List {
                HStack {
                    Text("Diameter").frame(width: width).font(.body)
                    Slider(value: $diameter.bindDouble, in: 1...300, step: 1)
                    Text(diameter.description).frame(width: width).font(.body)
                }
                HStack {
                    Text("Height").frame(width: width).font(.body)
                    Slider(value: $height.bindDouble, in: 1...300, step: 1)
                    Text(height.description).frame(width: width).font(.body)
                }
                HStack {
                    Text("ShaftRadius").frame(width: width).font(.body)
                    Slider(value: $shaftRadius.bindDouble, in: 1...200, step: 1)
                    Text(shaftRadius.description).frame(width: width).font(.body)
                }
            }
            .navigationBarTitle("Tank")
        }
    }
}



extension NewControlView {
    struct BaffleControl: View {
        @ObservedObject var baffles: Baffles
        
        let width:CGFloat = 70

        var body: some View {
            List {
                HStack {
                    Text("Count").frame(width: width).font(.body)
                    Slider(value: $baffles.numBaffles.bindDouble, in: 1...10, step: 1)
                    Text(baffles.numBaffles.description).frame(width: width).font(.body)
                }
                HStack {
                    Text("Inner Radius").frame(width: width).font(.body)
                    Slider(value: $baffles.innerRadius.bindDouble, in: 100...300, step: 1)
                    Text(baffles.innerRadius.description).frame(width: width).font(.body)
                }
                HStack {
                    Text("Outer Radius").frame(width: width).font(.body)
                    Slider(value: $baffles.outerRadius.bindDouble, in: 100...300, step: 1)
                    Text(baffles.outerRadius.description).frame(width: width).font(.body)
                }
                HStack {
                    Text("Width").frame(width: width).font(.body)
                    Slider(value: $baffles.thickness.bindDouble, in: 1...100, step: 1)
                    Text(baffles.thickness.description).frame(width: width).font(.body)
                }
            }
            .navigationBarTitle("Baffles")
        }
    }
}



extension NewControlView {
    struct ImpellerControl: View {
        @ObservedObject var impeller: Impeller
    
        let width:CGFloat = 70

        var body: some View {
            List {
                HStack {
                    Text("Position").frame(width: width).font(.body)
                    Slider(value: $impeller.impellerPosition.bindDouble, in: 0...300, step: 1)
                    Text(impeller.impellerPosition.description).frame(width: width).font(.body)
                }
                
                Section(header: Text("Hub")) {
                    HStack {
                        Text("Radius").frame(width: width).font(.body)
                        Slider(value: $impeller.hub.radius.bindDouble, in: 0...300, step: 1)
                        Text(impeller.hub.radius.description).frame(width: width).font(.body)
                    }
                    
                    HStack {
                        Text("Top").frame(width: width).font(.body)
                        Slider(value: $impeller.hub.top.bindDouble, in: 0...300, step: 1)
                        Text(impeller.hub.top.description).frame(width: width).font(.body)
                    }
                    
                    HStack {
                        Text("Bottom").frame(width: width).font(.body)
                        Slider(value: $impeller.hub.bottom.bindDouble, in: 0...300, step: 1)
                        Text(impeller.hub.bottom.description).frame(width: width).font(.body)
                    }
                }
                
                Section(header: Text("Disk")) {
                    HStack {
                        Text("Radius").frame(width: width).font(.body)
                        Slider(value: $impeller.disk.radius.bindDouble, in: 0...300, step: 1)
                        Text(impeller.disk.radius.description).frame(width: width).font(.body)
                    }
                    
                    HStack {
                        Text("Top").frame(width: width).font(.body)
                        Slider(value: $impeller.disk.top.bindDouble, in: 0...300, step: 1)
                        Text(impeller.disk.top.description).frame(width: width).font(.body)
                    }
                    
                    HStack {
                        Text("Bottom").frame(width: width).font(.body)
                        Slider(value: $impeller.disk.bottom.bindDouble, in: 0...300, step: 1)
                        Text(impeller.disk.bottom.description).frame(width: width).font(.body)
                    }
                }
                

//                HStack {
//                    Text("hubHeight").frame(width: width).font(.body)
//                    Slider(value: $impeller.hub.height.bindDouble, in: 100...300, step: 1)
//                    Text(impeller.hub.height.description).frame(width: width).font(.body)
//                }
//                HStack {
//                    Text("discRadius").frame(width: width).font(.body)
//                    Slider(value: $impeller.disc.radius.bindDouble, in: 100...300, step: 1)
//                    Text(impeller.disc.radius.description).frame(width: width).font(.body)
//                }
//                HStack {
//                    Text("discHeight").frame(width: width).font(.body)
//                    Slider(value: $impeller.disc.height.bindDouble, in: 1...100, step: 1)
//                    Text(impeller.disc.height.description).frame(width: width).font(.body)
//                }
            
//                HStack {
//                    Text("impellerCount").frame(width: width).font(.body)
//                    Slider(value: $impellerCount.bindDouble, in: 1...10, step: 1)
//                    Text(impellerCount.description).frame(width: width).font(.body)
//                }
                
//                HStack {
//                    Text("impellerInnerRadius").frame(width: width).font(.body)
//                    Slider(value: $impeller.innerRadius.bindDouble, in: 1...10, step: 1)
//                    Text(impeller.innerRadius.description).frame(width: width).font(.body)
//                }
//                HStack {
//                    Text("impellerOuterRadius").frame(width: width).font(.body)
//                    Slider(value: $impeller.outerRadius.bindDouble, in: 100...300, step: 1)
//                    Text(impeller.outerRadius.description).frame(width: width).font(.body)
//                }
//                HStack {
//                    Text("impellerHeight").frame(width: width).font(.body)
//                    Slider(value: $impeller.height.bindDouble, in: 100...300, step: 1)
//                    Text(impeller.height.description).frame(width: width).font(.body)
//                }
//                HStack {
//                    Text("impellerWidth").frame(width: width).font(.body)
//                    Slider(value: $impeller..bindDouble, in: 1...100, step: 1)
//                    Text(impellerWidth.description).frame(width: width).font(.body)
//                }
            }
        }
    }
}
