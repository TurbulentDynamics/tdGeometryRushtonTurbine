//
//  ControlView.swift
//  tdGeometryRushtonTurbine
//
//  Created by  Ivan Ushakov on 26.01.2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

import SwiftUI

struct ControlView: View {

    @ObservedObject var engine: Engine

    var body: some View {
        ScrollView {
            VStack {
                SettingsSection(engine: engine)

                FieldSection(section: engine.controlModel.tankSection)
                FieldSection(section: engine.controlModel.shaftSection)
                FieldSection(section: engine.controlModel.baffleSection)
                FieldSection(section: engine.controlModel.impellerCountSection)

                ForEach(engine.controlModel.impellerSections) { section in
                    ImpellerSection(section: section)
                }

                OutputPlaneSection(section: engine.controlModel.outputPlaneSection)
            }
        }.background(Palette.backgroundColor)
    }
}

struct SectionHeader: View {

    var title: String
    @Binding var expanded: Bool

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: expanded ? "chevron.up" : "chevron.down")
        }
        .padding(10)
        .foregroundColor(expanded ? Color.white : Palette.textColor)
        .background(Palette.sectionBackgroundColor)
    }
}

struct SettingsSection: View {

    var engine: Engine

    @State private var expanded = false

    var body: some View {
        VStack {
            SectionHeader(title: "Settings", expanded: $expanded)
                .onTapGesture { self.expanded.toggle() }

            if expanded {
                Button(action: { self.engine.loadJson() }) {
                    Text("Load Json")
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                .padding(.vertical, 5)
                .buttonStyle(BorderlessButtonStyle())
                Button(action: { self.engine.saveJson() }) {
                    Text("Save Json")
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                .padding(.vertical, 5)
                .buttonStyle(BorderlessButtonStyle())
            }
        }
    }
}

struct FieldSection: View {

    var section: SectionModel<InputFieldModel>

    @State private var expanded = false

    var body: some View {
        VStack {
            SectionHeader(title: section.title, expanded: $expanded)
                .onTapGesture { self.expanded.toggle() }

            if expanded {
                ForEach(section.fields) { field in
                    InputRow(title: field.title, text: field.value)
                }
            }
        }
    }
}

struct ImpellerSection: View {

    var section: ImpellerSectionModel

    @State private var expanded = false

    var body: some View {
        VStack {
            SectionHeader(title: section.title, expanded: $expanded)
                .onTapGesture { self.expanded.toggle() }

            if expanded {
                FieldSection(section: section.hubSection)
                FieldSection(section: section.diskSection)
                FieldSection(section: section.bladeSection)
            }
        }
    }
}

struct OutputPlaneSection: View {

    var section: SectionModel<PlaneInputModel>

    @State private var expanded = false

    var body: some View {
        VStack {
            SectionHeader(title: section.title, expanded: $expanded)
                .onTapGesture { self.expanded.toggle() }

            if expanded {
                ForEach(section.fields) { field in
                    PlaneRow(input: field)
                }
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
                .foregroundColor(Palette.textColor)
            TextField("", text: text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct PlaneRow: View {

    var input: PlaneInputModel

    var body: some View {
        VStack {
            HStack {
                Image(systemName: input.active ? "checkmark.square" : "square")
                    .foregroundColor(Palette.textColor)
                    .onTapGesture { self.input.active.toggle() }
                Text(input.title)
                    .foregroundColor(Palette.textColor)
                Spacer()
            }

            if input.active {
                Stepper(value: input.value, in: input.minValue...input.maxValue) {
                    Text("Value")
                        .foregroundColor(Palette.textColor)
                }
            }
        }.padding(.horizontal, 5)
    }
}
