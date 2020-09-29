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
