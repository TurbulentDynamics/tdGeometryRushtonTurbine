//
//  TurbineState.swift
//  tdGeometryRushtonTurbine
//
//  Created by  Ivan Ushakov on 01.02.2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

struct TurbineState: Equatable {
    var canvasWidth: Float
    var canvasHeight: Float
    var tankDiameter: Float
    var tankHeight: Float
    var shaftRadius: Float
    var kernelAutoRotation: Bool
    var kernelRotationDir: String
    var baffleCount: Int
    var baffleInnerRadius: Float
    var baffleOuterRadius: Float
    var baffleWidth: Float

    var impellerCount: Int
    var hubRadius: [Float]
    var hubHeight: [Float]
    var diskRadius: [Float]
    var diskHeight: [Float]
    var bladeCount: [Int]
    var bladeInnerRadius: [Float]
    var bladeOuterRadius: [Float]
    var bladeWidth: [Float]
    var bladeHeight: [Float]

    var transPanXY: Int
    var transPanYZ: Int
    var transPanXZ: Int
    var transRotateAngle: Int
    var transEnableXY: Bool
    var transEnableYZ: Bool
    var transEnableXZ: Bool
    var transEnableImpeller: Bool
    var transEnableRotate: Bool
    
    func changeValues(
        tankDiameter: Float? = nil,
        tankHeight: Float? = nil,
        shaftRadius: Float? = nil,
        impellerCount: Int? = nil,
        transPanXY: Int? = nil,
        transPanYZ: Int? = nil,
        transPanXZ: Int? = nil,
        transRotateAngle: Int? = nil,
        transEnableXY: Bool? = nil,
        transEnableYZ: Bool? = nil,
        transEnableXZ: Bool? = nil,
        transEnableRotate: Bool? = nil
    ) -> TurbineState {
        return TurbineState(
            canvasWidth: self.canvasWidth,
            canvasHeight: self.canvasHeight,
            tankDiameter: tankDiameter ?? self.tankDiameter,
            tankHeight: tankHeight ?? self.tankHeight,
            shaftRadius: shaftRadius ?? self.shaftRadius,
            kernelAutoRotation: self.kernelAutoRotation,
            kernelRotationDir: self.kernelRotationDir,
            baffleCount: self.baffleCount,
            baffleInnerRadius: self.baffleInnerRadius,
            baffleOuterRadius: self.baffleOuterRadius,
            baffleWidth: self.baffleWidth,
            impellerCount: impellerCount ?? self.impellerCount,
            hubRadius: update(newCount: impellerCount, array: self.hubRadius),
            hubHeight: update(newCount: impellerCount, array: self.hubHeight),
            diskRadius: update(newCount: impellerCount, array: self.diskRadius),
            diskHeight: update(newCount: impellerCount, array: self.diskHeight),
            bladeCount: update(newCount: impellerCount, array: self.bladeCount),
            bladeInnerRadius: update(newCount: impellerCount, array: self.bladeInnerRadius),
            bladeOuterRadius: update(newCount: impellerCount, array: self.bladeOuterRadius),
            bladeWidth: update(newCount: impellerCount, array: self.bladeWidth),
            bladeHeight: update(newCount: impellerCount, array: self.bladeHeight),
            transPanXY: transPanXY ?? self.transPanXY,
            transPanYZ: transPanYZ ?? self.transPanYZ,
            transPanXZ: transPanXZ ?? self.transPanXZ,
            transRotateAngle: transRotateAngle ?? self.transRotateAngle,
            transEnableXY: transEnableXY ?? self.transEnableXY,
            transEnableYZ: transEnableYZ ?? self.transEnableYZ,
            transEnableXZ: transEnableXZ ?? self.transEnableXZ,
            transEnableImpeller: false,
            transEnableRotate: transEnableRotate ?? self.transEnableRotate
        )
    }
}

private func update<T>(newCount: Int?, array: [T]) -> [T] {
    if let value = newCount {
        if value < array.count {
            return Array<T>(array.prefix(value))
        } else if value > array.count {
            return array + Array<T>(repeating: array[0], count: value - array.count)
        }

        return array
    } else {
        return array
    }
}
