import Foundation
import SwiftUI
import tdLBGeometryRushtonTurbineLib

struct TransPanControl: View {
    @ObservedObject var state: RushtonTurbineRenderState
    
    var body: some View {
        List {
            Section {
                Toggle("Enable XY", isOn: $state.transEnableXY)
                Toggle("Enable YZ", isOn: $state.transEnableYZ)
                Toggle("Enable XZ", isOn: $state.transEnableXZ)
            }

            Section {
                Toggle("Enable Impeller", isOn: $state.transEnableImpeller)
                Toggle("Enable Rotate", isOn: $state.transEnableRotate)
            }
            
            SliderControl("Rotate Angle", value: $state.transRotateAngle.bindDouble, in: 0...360, output: state.transRotateAngle.description)
        }
        .navigationBarTitle("Trans Pan")
    }
}
