//
//  ControlModel.swift
//  tdGeometryRushtonTurbine
//
//  Created by  Ivan Ushakov on 26.01.2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

import SwiftUI
import Combine

class ControlModel {

    var tankSection: SectionModel
    var shaftSection: SectionModel
    var baffleSection: SectionModel
    var impellerCountSection: SectionModel
    var impellerSections: [ImpellerSectionModel]

    init(state: TurbineState, callback: PassthroughSubject<TurbineState, Never>) {
        self.tankSection = SectionModel(title: "Tank", fields: [
            InputFieldModel(title: "Diameter", inputBlock: {
                return String(state.tankDiameter)
            }, outputBlock: { value in callback.send(state.changeValues(tankDiameter: Float(value))) }),
            InputFieldModel(title: "Height", inputBlock: {
                return String(state.tankHeight)
            }, outputBlock: { _ in })
        ])

        self.shaftSection = SectionModel(title: "Shaft", fields: [
            InputFieldModel(title: "Radius", inputBlock: {
                return String(state.shaftRadius)
            }, outputBlock: { _ in })
        ])

        self.baffleSection = SectionModel(title: "Baffle", fields: [
            InputFieldModel(title: "Count", inputBlock: {
                return String(state.baffleCount)
            }, outputBlock: { _ in }),
            InputFieldModel(title: "Inner Radius", inputBlock: {
                return String(state.baffleInnerRadius)
            }, outputBlock: { _ in }),
            InputFieldModel(title: "Outer Radius", inputBlock: {
                return String(state.baffleOuterRadius)
            }, outputBlock: { _ in }),
            InputFieldModel(title: "Width", inputBlock: {
                return String(state.baffleWidth)
            }, outputBlock: { _ in })
        ])

        self.impellerCountSection = SectionModel(title: "Impeller Count", fields: [
            InputFieldModel(title: "Count", inputBlock: {
                return String(state.impellerCount)
            }, outputBlock: { value in callback.send(state.changeValues(tankDiameter: Float(value))) })
        ])

        var array = [ImpellerSectionModel]()
        for i in 0..<state.impellerCount {
            let hubSection = SectionModel(title: "Hub", fields: [
                InputFieldModel(title: "Radius", inputBlock: {
                    return String(state.hubRadius[i])
                }, outputBlock: { _ in }),
                InputFieldModel(title: "Height", inputBlock: {
                    return String(state.hubHeight[i])
                }, outputBlock: { _ in })
            ])

            let diskSection = SectionModel(title: "Disk", fields: [
                InputFieldModel(title: "Radius", inputBlock: {
                    return String(state.diskRadius[i])
                }, outputBlock: { _ in }),
                InputFieldModel(title: "Height", inputBlock: {
                    return String(state.diskHeight[i])
                }, outputBlock: { _ in })
            ])

            let bladeSection = SectionModel(title: "Blade", fields: [
                InputFieldModel(title: "Count", inputBlock: {
                    return String(state.bladeCount[i])
                }, outputBlock: { _ in }),
                InputFieldModel(title: "Inner Radius", inputBlock: {
                    return String(state.bladeInnerRadius[i])
                }, outputBlock: { _ in }),
                InputFieldModel(title: "Outer Radius", inputBlock: {
                    return String(state.bladeOuterRadius[i])
                }, outputBlock: { _ in }),
                InputFieldModel(title: "Width", inputBlock: {
                    return String(state.bladeWidth[i])
                }, outputBlock: { _ in }),
                InputFieldModel(title: "Height", inputBlock: {
                    return String(state.bladeHeight[i])
                }, outputBlock: { _ in })
            ])

            array.append(ImpellerSectionModel(
                title: "Impeller \(i + 1)",
                hubSection: hubSection,
                diskSection: diskSection,
                bladeSection: bladeSection
            ))
        }
        self.impellerSections = array
    }
}

struct SectionModel {
    var title: String
    var fields: [InputFieldModel]
}

struct ImpellerSectionModel: Identifiable {
    var id = UUID()
    var title: String
    var hubSection: SectionModel
    var diskSection: SectionModel
    var bladeSection: SectionModel
}

class InputFieldModel: Identifiable {

    let id = UUID()
    let title: String

    var value: Binding<String> {
        return Binding<String>(
            get: { return self.inputBlock() }
        ) { [weak self] in
            self?.update(value: $0)
        }
    }

    private let acceptableNumbers = "0987654321"

    private let inputBlock: () -> String
    private let outputBlock: (String) -> Void

    init(title: String, inputBlock: @escaping () -> String, outputBlock: @escaping (String) -> Void) {
        self.title = title
        self.inputBlock = inputBlock
        self.outputBlock = outputBlock
    }

    private func update(value: String) {
        if value.count > 0, CharacterSet(charactersIn: acceptableNumbers).isSuperset(of: CharacterSet(charactersIn: value)) {
            outputBlock(value)
        }
    }
}
