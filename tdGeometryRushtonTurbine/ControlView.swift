//
//  ControlView.swift
//  tdGeometryRushtonTurbine
//
//  Created by  Ivan Ushakov on 26.01.2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

import SwiftUI

struct ControlView: View {

    var control: ControlModel

    var body: some View {
        List {
            FieldSection(section: control.tankSection)
            FieldSection(section: control.shaftSection)
            FieldSection(section: control.baffleSection)
            FieldSection(section: control.impellerCountSection)

            ForEach(control.impellerSections) { section in
                ImpellerSection(section: section)
            }
        }
    }
}

struct FieldSection: View {

    var section: SectionModel
    @State var expand = false

    var body: some View {
        VStack {
            HStack {
                Text(section.title)
                Spacer()
                Image(systemName: expand ? "chevron.up" : "chevron.down")
            }.background(Color.gray)
                .onTapGesture { self.expand.toggle() }

            if expand {
                ForEach(section.fields) { field in
                    InputRow(title: field.title, text: field.value)
                }
            }
        }
    }
}

struct ImpellerSection: View {

    var section: ImpellerSectionModel
    @State var expand = false

    var body: some View {
        VStack {
            HStack {
                Text(section.title)
                    .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                Spacer()
                Image(systemName: expand ? "chevron.up" : "chevron.down")
            }.background(Color.red)
                .onTapGesture { self.expand.toggle() }

            if expand {
                FieldSection(section: section.hubSection)
                FieldSection(section: section.diskSection)
                FieldSection(section: section.bladeSection)
            }
        }
    }
}

struct InputRow: View {

    var title: String
    var text: Binding<String>

    var body: some View {
        HStack {
            Text(title)
            TextField("", text: text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct ButtonRow: View {

    var title: String

    var body: some View {
        Button(action: {}) {
            Text(title)
        }
    }
}
