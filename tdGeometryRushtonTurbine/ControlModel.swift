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

    init(state: TurbineState, stateSubject: PassthroughSubject<TurbineState, Never>) {
        self.tankSection = SectionModel(title: "Tank", fields: [
            floatField(title: "Diameter", input: state.tankDiameter, outputBlock: {
                stateSubject.send(state.changeValues(tankDiameter: $0))
            }),
            floatField(title: "Height", input: state.tankHeight, outputBlock: {
                stateSubject.send(state.changeValues(tankHeight: $0))
            })
        ])

        self.shaftSection = SectionModel(title: "Shaft", fields: [
            floatField(title: "Radius", input: state.shaftRadius, outputBlock: {
                stateSubject.send(state.changeValues(shaftRadius: $0))
            })
        ])

        self.baffleSection = SectionModel(title: "Baffle", fields: [
            integerField(title: "Count", input: state.baffleCount, outputBlock: {
                stateSubject.send(state.changeValues(baffleCount: $0))
            }),
            floatField(title: "Inner Radius", input: state.baffleInnerRadius, outputBlock: {
                stateSubject.send(state.changeValues(baffleInnerRadius: $0))
            }),
            floatField(title: "Outer Radius", input: state.baffleOuterRadius, outputBlock: {
                stateSubject.send(state.changeValues(baffleOuterRadius: $0))
            }),
            floatField(title: "Width", input: state.baffleWidth, outputBlock: {
                stateSubject.send(state.changeValues(baffleWidth: $0))
            })
        ])

        self.impellerCountSection = SectionModel(title: "Impeller Count", fields: [
            integerField(title: "Count", input: state.impellerCount, outputBlock: {
                stateSubject.send(state.changeImpellerCount($0))
            })
        ])

        var array = [ImpellerSectionModel]()
        for i in 0..<state.impellerCount {
            let hubSection = SectionModel(title: "Hub", fields: [
                floatField(title: "Radius", input: state.hubRadius[i], outputBlock: {
                    var copy = state.hubRadius
                    copy[i] = $0
                    stateSubject.send(state.changeValues(hubRadius: copy))
                }),
                floatField(title: "Height", input: state.hubHeight[i], outputBlock: {
                    var copy = state.hubHeight
                    copy[i] = $0
                    stateSubject.send(state.changeValues(hubHeight: copy))
                })
            ])

            let diskSection = SectionModel(title: "Disk", fields: [
                floatField(title: "Radius", input: state.diskRadius[i], outputBlock: {
                    var copy = state.diskRadius
                    copy[i] = $0
                    stateSubject.send(state.changeValues(diskRadius: copy))
                }),
                floatField(title: "Height", input: state.diskHeight[i], outputBlock: {
                    var copy = state.diskHeight
                    copy[i] = $0
                    stateSubject.send(state.changeValues(diskHeight: copy))
                })
            ])

            let bladeSection = SectionModel(title: "Blade", fields: [
                integerField(title: "Count", input: state.bladeCount[i], outputBlock: {
                    var copy = state.bladeCount
                    copy[i] = $0
                    stateSubject.send(state.changeValues(bladeCount: copy))
                }),
                floatField(title: "Inner Radius", input: state.bladeInnerRadius[i], outputBlock: {
                    var copy = state.bladeInnerRadius
                    copy[i] = $0
                    stateSubject.send(state.changeValues(bladeInnerRadius: copy))
                }),
                floatField(title: "Outer Radius", input: state.bladeOuterRadius[i], outputBlock: {
                    var copy = state.bladeOuterRadius
                    copy[i] = $0
                    stateSubject.send(state.changeValues(bladeOuterRadius: copy))
                }),
                floatField(title: "Width", input: state.bladeWidth[i], outputBlock: {
                    var copy = state.bladeWidth
                    copy[i] = $0
                    stateSubject.send(state.changeValues(bladeWidth: copy))
                }),
                floatField(title: "Height", input: state.bladeHeight[i], outputBlock: {
                    var copy = state.bladeHeight
                    copy[i] = $0
                    stateSubject.send(state.changeValues(bladeHeight: copy))
                })
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
                outputBlock: { stateSubject.send(state.changeValues(transPanXY: $1, transEnableXY: $0)) }
            ),
            PlaneInputModel(
                title: "YZ Plane",
                minValue: Int(state.tankDiameter * -0.5),
                maxValue: Int(state.tankDiameter * 0.5),
                active: state.transEnableYZ,
                input: state.transPanYZ,
                outputBlock: { stateSubject.send(state.changeValues(transPanYZ: $1, transEnableYZ: $0)) }
            ),
            PlaneInputModel(
                title: "XZ Plane",
                minValue: Int(state.tankHeight * -0.5),
                maxValue: Int(state.tankHeight * 0.5),
                active: state.transEnableXZ,
                input: state.transPanXZ,
                outputBlock: { stateSubject.send(state.changeValues(transPanXZ: $1, transEnableXZ: $0)) }
            ),
            PlaneInputModel(
                title: "Rotate Plane",
                minValue: 0,
                maxValue: 360,
                active: state.transEnableRotate,
                input: state.transRotateAngle,
                outputBlock: { stateSubject.send(state.changeValues(transRotateAngle: $1, transEnableRotate: $0)) }
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
            get: { return self.input }
        ) { [weak self] in
            self?.outputBlock($0)
        }
    }

    private let input: String
    private let outputBlock: (String) -> Void

    init(title: String, input: String, outputBlock: @escaping (String) -> Void) {
        self.title = title
        self.input = input
        self.outputBlock = outputBlock
    }
}

private  func integerField(title: String, input: Int, outputBlock: @escaping (Int) -> Void) -> InputFieldModel {
    return InputFieldModel(title: title, input: String(input), outputBlock: {
        if let value = Int($0) {
            outputBlock(value)
        }
    })
}

private func floatField(title: String, input: Float, outputBlock: @escaping (Float) -> Void) -> InputFieldModel {
    return InputFieldModel(title: title, input: String(input), outputBlock: {
        if let value = Float($0) {
            outputBlock(value)
        }
    })
}
