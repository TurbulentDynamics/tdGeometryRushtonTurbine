import Foundation
import SwiftUI
import tdLBGeometryRushtonTurbineLib

struct TankControl: View {
    @Binding var diameter: Int
    @Binding var height: Int
    @Binding var shaftRadius: Int

    var body: some View {
        List {
            SliderControl("Diameter", value: $diameter.bindDouble, in: 1...300, output: diameter.description)
            SliderControl("Height", value: $height.bindDouble, in: 1...300, output: height.description)
            SliderControl("ShaftRadius", value: $shaftRadius.bindDouble, in: 1...200, output: shaftRadius.description)
        }
        .navigationBarTitle("Tank")
    }
}
