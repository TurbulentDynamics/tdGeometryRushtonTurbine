//
//  NewControls.swift
//  tdGeometryRushtonTurbine
//
//  Created by Niall Ó Broin on 06/08/2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

import Foundation
import SwiftUI
import tdGeometryRushtonTurbineLib

extension Int {
    //http://ootips.org/yonat/swiftui-binding-type-conversion/
    var bindDouble: Double {
        get { Double(self) }
        set { self = Int(newValue) }
    }
}


struct NewControlView: View {

    @ObservedObject var turbine: RushtonTurbine

    var body: some View {
        NavigationView {
            
            NavigationLink(destination: TankControl(diameter: $turbine.tankDiameter, height: $turbine.tankHeight, shaftRadius: $turbine.shaft.radius)) {
                Text("Tank")
            }
                
            NavigationLink(destination: BaffleControl(count: $turbine.baffles.numBaffles, innerRadius: $turbine.baffles.innerRadius, outerRadius: $turbine.baffles.outerRadius, baffleWidth: $turbine.baffles.thickness)) {
                Text("Baffles")
            }
            
            NavigationLink(destination: ImpellerControl(hubRadius: $turbine.impeller.hub.radius , hubHeight: $turbine.impeller.hub.radius, discRadius: $turbine.impeller.hub.radius, discHeight: $turbine.impeller.hub.radius, impellerCount: $turbine.impeller.hub.radius, impellerInnerRadius: $turbine.impeller.hub.radius, impellerOuterRadius: $turbine.impeller.hub.radius, impellerHeight: $turbine.impeller.hub.radius, impellerWidth: $turbine.impeller.hub.radius)) {
                Text("Impeller")
            }
            
            
        }
    }
}



extension NewControlView {
    struct TankControl: View {
        @Binding var diameter: Int
        @Binding var height: Int
        @Binding var shaftRadius: Int

        let width:CGFloat = 70

        var body: some View {
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
    }
}



extension NewControlView {
    struct BaffleControl: View {
        
        @Binding var count: Int
        @Binding var innerRadius: Int
        @Binding var outerRadius: Int
        @Binding var baffleWidth: Int

        
        let width:CGFloat = 70

        var body: some View {
            HStack {
                Text("Count").frame(width: width).font(.body)
                Slider(value: $count.bindDouble, in: 1...10, step: 1)
                Text(count.description).frame(width: width).font(.body)
            }
            HStack {
                Text("Inner Radius").frame(width: width).font(.body)
                Slider(value: $innerRadius.bindDouble, in: 100...300, step: 1)
                Text(innerRadius.description).frame(width: width).font(.body)
            }
            HStack {
                Text("Outer Radius").frame(width: width).font(.body)
                Slider(value: $outerRadius.bindDouble, in: 100...300, step: 1)
                Text(outerRadius.description).frame(width: width).font(.body)
            }
            HStack {
                Text("Width").frame(width: width).font(.body)
                Slider(value: $baffleWidth.bindDouble, in: 1...100, step: 1)
                Text(baffleWidth.description).frame(width: width).font(.body)
            }
        }
    }
}



extension NewControlView {
    struct ImpellerControl: View {
        
        @Binding var hubRadius: Int
        @Binding var hubHeight: Int

        @Binding var discRadius: Int
        @Binding var discHeight: Int
        
        @Binding var impellerCount: Int
        @Binding var impellerInnerRadius: Int
        @Binding var impellerOuterRadius: Int
        @Binding var impellerHeight: Int
        @Binding var impellerWidth: Int

    
        let width:CGFloat = 70

        var body: some View {
            HStack {
                Text("hubRadius").frame(width: width).font(.body)
                Slider(value: $hubRadius.bindDouble, in: 1...10, step: 1)
                Text(hubRadius.description).frame(width: width).font(.body)
            }
            HStack {
                Text("hubHeight").frame(width: width).font(.body)
                Slider(value: $hubHeight.bindDouble, in: 100...300, step: 1)
                Text(hubHeight.description).frame(width: width).font(.body)
            }
            HStack {
                Text("discRadius").frame(width: width).font(.body)
                Slider(value: $discRadius.bindDouble, in: 100...300, step: 1)
                Text(discRadius.description).frame(width: width).font(.body)
            }
            HStack {
                Text("discHeight").frame(width: width).font(.body)
                Slider(value: $discHeight.bindDouble, in: 1...100, step: 1)
                Text(discHeight.description).frame(width: width).font(.body)
            }
            

        
            HStack {
                Text("impellerCount").frame(width: width).font(.body)
                Slider(value: $impellerCount.bindDouble, in: 1...10, step: 1)
                Text(impellerCount.description).frame(width: width).font(.body)
            }
            HStack {
                Text("impellerInnerRadius").frame(width: width).font(.body)
                Slider(value: $impellerInnerRadius.bindDouble, in: 1...10, step: 1)
                Text(impellerInnerRadius.description).frame(width: width).font(.body)
            }
            HStack {
                Text("impellerOuterRadius").frame(width: width).font(.body)
                Slider(value: $impellerOuterRadius.bindDouble, in: 100...300, step: 1)
                Text(impellerOuterRadius.description).frame(width: width).font(.body)
            }
            HStack {
                Text("impellerHeight").frame(width: width).font(.body)
                Slider(value: $impellerHeight.bindDouble, in: 100...300, step: 1)
                Text(impellerHeight.description).frame(width: width).font(.body)
            }
            HStack {
                Text("impellerWidth").frame(width: width).font(.body)
                Slider(value: $impellerWidth.bindDouble, in: 1...100, step: 1)
                Text(impellerWidth.description).frame(width: width).font(.body)
            }
            
            
            
        }
    }
}
