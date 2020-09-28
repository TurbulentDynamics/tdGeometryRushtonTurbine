import SwiftUI

struct SliderControl: View {
    let name: String
    let value: Binding<Double>
    let range: ClosedRange<Double>
    let output: String
    
    init(_ name: String, value: Binding<Double>, in range: ClosedRange<Double>, output: String) {
        self.name = name
        self.value = value
        self.range = range
        self.output = output
    }
    
    var body: some View {
        HStack {
            Text(self.name).frame(width: 70, alignment: .leading).font(.body)
            Slider(value: value, in: range, step: 1)
            Text(output).frame(width: 70).font(.body)
        }
    }
}
