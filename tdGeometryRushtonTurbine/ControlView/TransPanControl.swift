import Foundation
import SwiftUI
import tdLBGeometryRushtonTurbineLib

struct TransPanControl: View {
    @ObservedObject var state: RushtonTurbineRenderState
    
    var body: some View {
        List {
            Section(header: Text("XY")) {
                Toggle("Enable", isOn: $state.transEnableXY)
            }
            
            Section(header: Text("YZ")) {
                Toggle("Enable", isOn: $state.transEnableYZ)
            }
            
            Section(header: Text("XZ")) {
                Toggle("Enable", isOn: $state.transEnableXZ)
            }
            
            Section(header: Text("Impeller")) {
                Toggle("Enable", isOn: $state.transEnableImpeller)
                //Toggle("Rotate", isOn: $state.transEnableRotate)
            }

            
            //dSliderControl("Rotate Angle", value: $state.transRotateAngle.bindDouble, in: 0...360, output: state.transRotateAngle.description)
        }
        .navigationBarTitle("Trans Pan")
    }
}
