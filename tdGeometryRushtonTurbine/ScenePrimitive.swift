//
//  ScenePrimitive.swift
//  tdGeometryRushtonTurbine
//
//  Created by  Ivan Ushakov on 01.02.2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

import SceneKit

func createGrid(size: Int, divisions: Int, color1: Int, color2: Int) -> SCNGeometry {
    let center = divisions / 2
    let step = Float(size / divisions)
    let halfSize = Float(size / 2)

    var vertices = [simd_float3]()
    var colors = [simd_float4]()
    var indices = [simd_int1]()

    var j: simd_int1 = 0
    var k = -halfSize
    for i in 0..<divisions {
        vertices.append(simd_float3(-halfSize, 0, k))
        vertices.append(simd_float3(halfSize, 0, k))

        vertices.append(simd_float3(k, 0, -halfSize))
        vertices.append(simd_float3(k, 0, halfSize))

        indices.append(j)
        j += 1

        indices.append(j)
        j += 1

        indices.append(j)
        j += 1

        indices.append(j)
        j += 1

        for _ in 0..<4 {
            colors.append(createColor(i == center ? color1 : color2))
        }

        k += step
    }

    let vertexSource = SCNGeometrySource(
        data: Data(bytes: vertices, count: MemoryLayout<simd_float3>.size * vertices.count),
        semantic: .vertex,
        vectorCount: vertices.count,
        usesFloatComponents: true,
        componentsPerVector: 3,
        bytesPerComponent: MemoryLayout<simd_float1>.size,
        dataOffset: 0,
        dataStride: MemoryLayout<simd_float3>.size
    )

    let colorSource = SCNGeometrySource(
        data: Data(bytes: colors, count: MemoryLayout<simd_float4>.size * colors.count),
        semantic: .color,
        vectorCount: vertices.count,
        usesFloatComponents: true,
        componentsPerVector: 4,
        bytesPerComponent: MemoryLayout<simd_float1>.size,
        dataOffset: 0,
        dataStride: MemoryLayout<simd_float4>.size
    )

    let element = SCNGeometryElement(
        data: Data(bytes: indices, count: MemoryLayout<simd_int1>.size * indices.count),
        primitiveType: .line,
        primitiveCount: indices.count / 2,
        bytesPerIndex: MemoryLayout<simd_int1>.size
    )

    return SCNGeometry(sources: [vertexSource, colorSource], elements: [element])
}

private func createColor(_ value: Int) -> simd_float4 {
    return simd_float4(
        Float((value >> 16) & 0xFF),
        Float((value >> 8) & 0xFF),
        Float(value & 0xFF),
        1.0
    )
}
