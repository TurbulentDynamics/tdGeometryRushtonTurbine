import Foundation
import SwiftUI
import tdLBGeometryRushtonTurbineLib

struct ImpellerControl: View {
    @ObservedObject var impeller: Impeller

    var body: some View {
        List {
            SliderControl("Position", value: $impeller.impellerPosition.bindDouble, in: 0...300, output: impeller.impellerPosition.description)
            
            Section(header: Text("Blades")) {
                SliderControl("Count", value: $impeller.numBlades.bindDouble, in: 0...30, output: impeller.numBlades.bindDouble.description)
                SliderControl("Thinkness", value: $impeller.blades.thickness.bindDouble, in: 0...300, output: impeller.blades.thickness.description)
            }
            
            Section(header: Text("Hub")) {
                SliderControl("Radius", value: $impeller.hub.radius.bindDouble, in: 0...300, output: impeller.hub.radius.description)
                SliderControl("Top", value: $impeller.hub.top.bindDouble, in: 0...300, output: impeller.hub.top.description)
                SliderControl("Bottom", value: $impeller.hub.bottom.bindDouble, in: 0...300, output: impeller.hub.bottom.description)
            }
            
            Section(header: Text("Disk")) {
                SliderControl("Radius", value: $impeller.disk.radius.bindDouble, in: 0...300, output: impeller.disk.radius.description)
                SliderControl("Top", value: $impeller.disk.top.bindDouble, in: 0...300, output: impeller.disk.top.description)
                SliderControl("Bottom", value: $impeller.disk.bottom.bindDouble, in: 0...300, output: impeller.disk.bottom.description)
            }
        }
        .navigationBarTitle("Impeller")
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
