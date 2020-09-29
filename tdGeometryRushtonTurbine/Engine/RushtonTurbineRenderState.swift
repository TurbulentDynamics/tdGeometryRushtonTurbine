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
    @Published var canvasWidth: Float
    @Published var canvasHeight: Float
    
    @Published var kernelAutoRotation: Bool
    @Published var kernelRotationDir: String

    @Published var transPanXY: Int
    @Published var transPanYZ: Int
    @Published var transPanXZ: Int
    @Published var transRotateAngle: Int
    @Published var transEnableXY: Bool
    @Published var transEnableYZ: Bool
    @Published var transEnableXZ: Bool
    @Published var transEnableImpeller: Bool
    @Published var transEnableRotate: Bool
    
    
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
