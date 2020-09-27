//
//  TurbineState.swift
//  tdGeometryRushtonTurbine
//
//  Created by  Ivan Ushakov on 01.02.2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//
import Foundation
import tdLBGeometryRushtonTurbineLib

public class RushtonTurbineRenderState: ObservableObject {
    @Published var turbine: RushtonTurbine
     
    var canvasWidth: Float
    var canvasHeight: Float
    
    var kernelAutoRotation: Bool
    var kernelRotationDir: String

    var transPanXY: Int
    var transPanYZ: Int
    var transPanXZ: Int
    var transRotateAngle: Int
    var transEnableXY: Bool
    var transEnableYZ: Bool
    var transEnableXZ: Bool
    var transEnableImpeller: Bool
    var transEnableRotate: Bool
    
    
    init(turbine: RushtonTurbine, canvasWidth: Float, canvasHeight: Float, kernelAutoRotation: Bool, kernelRotationDir: String, transPanXY: Int, transPanYZ: Int, transPanXZ: Int, transRotateAngle: Int, transEnableXY: Bool, transEnableYZ: Bool, transEnableXZ: Bool, transEnableImpeller: Bool, transEnableRotate: Bool) {
        self.turbine = turbine
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.kernelAutoRotation = kernelAutoRotation
        self.kernelRotationDir = kernelRotationDir
        self.transPanXY = transPanXY
        self.transPanYZ = transPanYZ
        self.transPanXZ = transPanXZ
        self.transRotateAngle = transRotateAngle
        self.transEnableXY = transEnableXY
        self.transEnableYZ = transEnableYZ
        self.transEnableXZ = transEnableXZ
        self.transEnableImpeller = transEnableImpeller
        self.transEnableRotate = transEnableRotate
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
