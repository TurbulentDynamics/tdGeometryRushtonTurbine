//
//  JsonModel.swift
//  tdGeometryRushtonTurbine
//
//  Created by  Ivan Ushakov on 04.02.2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

import Foundation
import tdLBGeometryRushtonTurbineLib

enum GeneralError: Error {
    case security
}

func readTurbineState(_ url: URL) throws -> RushtonTurbineRenderState {
    guard url.startAccessingSecurityScopedResource() else {
        throw GeneralError.security
    }

    defer {
        url.stopAccessingSecurityScopedResource()
    }

    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    let object = try decoder.decode(JData.self, from: data)
    return JData.create(object)
}

func saveTurbineState(state: RushtonTurbineRenderState, url: URL) throws {
    guard url.startAccessingSecurityScopedResource() else {
        throw GeneralError.security
    }

    defer {
        url.stopAccessingSecurityScopedResource()
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let date = formatter.string(from: Date())
    let fileURL = url.appendingPathComponent("tdGeometryRushtonTurbine-\(date).json")

    let encoder = JSONEncoder()
    let data = try encoder.encode(JData.create(state))
    try data.write(to: fileURL, options: .atomic)
}

extension JData {

    static func create(_ state: RushtonTurbineRenderState) -> JData {
        let impellers: [(Int, JImpeller)] = state.turbine.impellers.enumerated().map { (index, impeller) -> (Int, JImpeller) in
            let blade = JBlade(
                innerRadius: Float(impeller.value.blades.innerRadius),
                outerRadius: Float(impeller.value.blades.outerRadius),
                bottom: 71.4000015,
                top: Float(impeller.value.blades.height),
                bladeThickness: Float(impeller.value.blades.thickness)
            )

            let disk = JDisk(radius: Float(impeller.value.disk.radius), bottom: 68.6800003, top: Float(impeller.value.disk.height))
            let hub = JHub(radius: Float(impeller.value.hub.radius), bottom: 71.4000015, top: Float(impeller.value.hub.height))

            let impeller = JImpeller(
                numBlades: impeller.value.numBlades,
                firstBladeOffset: 0,
                uav: 0.100000001,
                blade_tip_angular_vel_w0: 0.00588235306,
                impeller_position: Int(state.turbine.tankDiameter) / (state.turbine.impellers.count + 1) * (index + 1),
                blades: blade,
                disk: disk,
                hub: hub
            )
            return (index, impeller)
        }

        let baffle = JBaffle(
            numBaffles: state.turbine.baffles.numBaffles,
            firstBaffleOffset: 0.785398185,
            innerRadius: Float(state.turbine.baffles.innerRadius),
            outerRadius: Float(state.turbine.baffles.outerRadius),
            thickness: Float(state.turbine.baffles.thickness)
        )

        let shaft = JShaft(radius: Float(state.turbine.shaft.radius))

        return JData(
            name: "GeometryConfig",
            gridx: Float(state.turbine.tankHeight),
            resolution: 0.699999988,
            tankDiameter: Float(state.turbine.tankDiameter),
            starting_step: 0,
            impeller_start_angle: 0,
            impeller_startup_steps_until_normal_speed: 0,
            baffles: baffle,
            shaft: shaft,
            impeller: Dictionary(uniqueKeysWithValues: impellers)
        )
    }

    static func create(_ data: JData) -> RushtonTurbineRenderState {
        var hubRadius = Array<Float>(repeating: 0, count: data.impeller.count)
        var hubHeight = Array<Float>(repeating: 0, count: data.impeller.count)
        var diskRadius = Array<Float>(repeating: 0, count: data.impeller.count)
        var diskHeight = Array<Float>(repeating: 0, count: data.impeller.count)

        var bladeCount = Array<Int>(repeating: 0, count: data.impeller.count)
        var bladeInnerRadius = Array<Float>(repeating: 0, count: data.impeller.count)
        var bladeOuterRadius = Array<Float>(repeating: 0, count: data.impeller.count)
        var bladeWidth = Array<Float>(repeating: 0, count: data.impeller.count)
        var bladeHeight = Array<Float>(repeating: 0, count: data.impeller.count)

        data.impeller.forEach {
            if let key = Int?($0) {
                hubRadius[key] = $1.hub.radius
                hubHeight[key] = $1.hub.top
                diskRadius[key] = $1.disk.radius
                diskHeight[key] = $1.disk.top
                bladeCount[key] = $1.numBlades
                bladeInnerRadius[key] = $1.blades.innerRadius
                bladeOuterRadius[key] = $1.blades.outerRadius
                bladeWidth[key] = $1.blades.bladeThickness
                bladeHeight[key] = $1.blades.top
            }
        }

        return RushtonTurbineRenderState(
            turbine: RushtonTurbineReference(gridX: 300),
            canvasWidth: 0,
            canvasHeight: 0,
            kernelAutoRotation: false,
            kernelRotationDir: "clockwise",
            transPanXY: 0,
            transPanYZ: 0,
            transPanXZ: 0,
            transRotateAngle: 0,
            transEnableXY: false,
            transEnableYZ: false,
            transEnableXZ: false,
            transEnableImpeller: false,
            transEnableRotate: false
        )
    }
}

private struct JData: Codable {
    var name: String
    var gridx: Float
    var resolution: Float
    var tankDiameter: Float
    var starting_step: Int
    var impeller_start_angle: Float
    var impeller_startup_steps_until_normal_speed: Int
    var baffles: JBaffle
    var shaft: JShaft
    var impeller: [Int : JImpeller]
}

private struct JBaffle: Codable {
    var numBaffles: Int
    var firstBaffleOffset: Float
    var innerRadius: Float
    var outerRadius: Float
    var thickness: Float
}

private struct JShaft: Codable {
    var radius: Float
}

private struct JImpeller: Codable {
    var numBlades: Int
    var firstBladeOffset: Int
    var uav: Float
    var blade_tip_angular_vel_w0: Float
    var impeller_position: Int
    var blades: JBlade
    var disk: JDisk
    var hub: JHub
}

private struct JBlade: Codable {
    var innerRadius: Float
    var outerRadius: Float
    var bottom: Float
    var top: Float
    var bladeThickness: Float
}

private struct JDisk: Codable {
    var radius: Float
    var bottom: Float
    var top: Float
}

private struct JHub: Codable {
    var radius: Float
    var bottom: Float
    var top: Float
}
