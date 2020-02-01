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

    var tankSection: SectionModel<InputFieldModel>
    var shaftSection: SectionModel<InputFieldModel>
    var baffleSection: SectionModel<InputFieldModel>
    var impellerCountSection: SectionModel<InputFieldModel>
    var impellerSections: [ImpellerSectionModel]
    var outputPlaneSection: SectionModel<PlaneInputModel>

    init(state: TurbineState, callback: PassthroughSubject<TurbineState, Never>) {
        self.tankSection = SectionModel(title: "Tank", fields: [
            InputFieldModel(title: "Diameter", inputBlock: {
                return String(state.tankDiameter)
            }, outputBlock: { callback.send(state.changeValues(tankDiameter: Float($0))) }),
            InputFieldModel(title: "Height", inputBlock: {
                return String(state.tankHeight)
            }, outputBlock: { callback.send(state.changeValues(tankHeight: Float($0))) })
        ])

        self.shaftSection = SectionModel(title: "Shaft", fields: [
            InputFieldModel(title: "Radius", inputBlock: {
                return String(state.shaftRadius)
            }, outputBlock: { callback.send(state.changeValues(shaftRadius: Float($0))) })
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
            }, outputBlock: { callback.send(state.changeValues(impellerCount: Int($0))) })
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

        self.outputPlaneSection = SectionModel(title: "Output Plane", fields: [
            PlaneInputModel(
                title: "XY Plane",
                minValue: Int(state.tankDiameter * -0.5),
                maxValue: Int(state.tankDiameter * 0.5),
                active: state.transEnableXY,
                input: state.transPanXY,
                outputBlock: { callback.send(state.changeValues(transPanXY: $1, transEnableXY: $0)) }
            ),
            PlaneInputModel(
                title: "YZ Plane",
                minValue: Int(state.tankDiameter * -0.5),
                maxValue: Int(state.tankDiameter * 0.5),
                active: state.transEnableYZ,
                input: state.transPanYZ,
                outputBlock: { callback.send(state.changeValues(transPanYZ: $1, transEnableYZ: $0)) }
            ),
            PlaneInputModel(
                title: "XZ Plane",
                minValue: Int(state.tankHeight * -0.5),
                maxValue: Int(state.tankHeight * 0.5),
                active: state.transEnableXZ,
                input: state.transPanXZ,
                outputBlock: { callback.send(state.changeValues(transPanXZ: $1, transEnableXZ: $0)) }
            ),
            PlaneInputModel(
                title: "Rotate Plane",
                minValue: 0,
                maxValue: 360,
                active: state.transEnableRotate,
                input: state.transRotateAngle,
                outputBlock: { callback.send(state.changeValues(transRotateAngle: $1, transEnableRotate: $0)) }
            )
        ])
    }
}

struct SectionModel<T> {
    var title: String
    var fields: [T]
}

struct ImpellerSectionModel: Identifiable {
    var id = UUID()
    var title: String
    var hubSection: SectionModel<InputFieldModel>
    var diskSection: SectionModel<InputFieldModel>
    var bladeSection: SectionModel<InputFieldModel>
}

class PlaneInputModel: Identifiable {

    let id = UUID()
    let title: String
    let minValue: Int
    let maxValue: Int

    var active = false {
        didSet {
            update()
        }
    }

    var value: Binding<Int> {
        return Binding<Int>(
            get: { return self.input }
        ) { [weak self] _ in self?.update() }
    }

    private let input: Int
    private let outputBlock: (Bool, Int) -> Void

    init(title: String, minValue: Int, maxValue: Int, active: Bool, input: Int, outputBlock: @escaping (Bool, Int) -> Void) {
        self.title = title
        self.minValue = minValue
        self.maxValue = maxValue
        self.active = active
        self.input = input
        self.outputBlock = outputBlock
    }

    private func update() {
        outputBlock(active, value.wrappedValue)
    }
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
