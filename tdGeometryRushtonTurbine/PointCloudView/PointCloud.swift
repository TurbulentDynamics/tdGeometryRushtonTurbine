//
//  PointCloud.swift
//  MixedReality
//
//  Created by Evgeniy Upenik on 21.05.17.
//  Copyright © 2017 Evgeniy Upenik. All rights reserved.
//

import SceneKit
import tdLB


public enum PointCloudElementType: Int {
    case rotating = 0
    case fixed = 1
    case translating = 2
    case rotatingNonUpdating = 3
}



public struct PointCloudVertex {
    public internal(set) var i: Float, j: Float, k: Float
    public internal(set) var r: Float, g: Float, b: Float

    public init(i: Float, j: Float, k: Float, t: PointCloudElementType){
        self.i = i
        self.j = j
        self.k = k

        switch t {
        case .rotating:
            self.r = 0
            self.g = 0
            self.b = 0
        case .fixed:
            self.r = 1
            self.g = 1
            self.b = 1
        case .translating:
            self.r = 2
            self.g = 2
            self.b = 2
        case .rotatingNonUpdating:
            self.r = 3
            self.g = 3
            self.b = 3
            
        }
    }

    public init(i: Int, j: Int, k: Int, t: PointCloudElementType = .fixed){
        self.init(i:Float(i), j:Float(j), k:Float(k), t:t)
    }

    public init(i: Double, j: Double, k: Double, t: PointCloudElementType = .fixed){
        self.init(i:Float(i), j:Float(j), k:Float(k), t:t)
    }
}


public class PointCloud {
    public private(set) var n: Int
    public private(set) var vertices: [PointCloudVertex]

    public init(vertices: [PointCloudVertex] = []) {
        self.vertices = vertices
        self.n = vertices.count
    }


    public init(geomFixed: [Pos3d], geomRotating: [Pos3d], geomRotatingNonUpdating: [Pos3d]) {
        
        self.vertices = [PointCloudVertex]()
        
        self.vertices.append(contentsOf: geomFixed.map{PointCloudVertex(i: $0.i, j: $0.j, k: $0.k, t: .fixed)})

        self.vertices.append(contentsOf: geomRotating.map{PointCloudVertex(i: $0.i, j: $0.j, k: $0.k, t: .rotating)})

        self.vertices.append(contentsOf: geomRotatingNonUpdating.map{PointCloudVertex(i: $0.i, j: $0.j, k: $0.k, t: .rotatingNonUpdating)})


        self.n = vertices.count
    }
    
    
    
    public func getNode() -> SCNNode {

        let node = buildNode(points: vertices)
        NSLog(String(describing: node))
        return node
    }
    
    public func getPointCloudFromFile(fileName: String) -> (Int, Int, Int) {
        // Open file
        if let path = Bundle.main.path(forResource: fileName, ofType: "txt") {
            do {
                let dataString = try String(contentsOfFile: path, encoding: .ascii)
                return getPointCloudFromString(dataString)
            } catch {
                print(error)
            }
        }
        return (0,0,0)
    }

    public func getPointCloudFromString(_ dataString: String) -> (Int, Int, Int) {

        self.n = 0
        var i, j, k: Double
        (i, j, k) = (0, 0, 0)

        var maxI: Int = 0
        var maxJ: Int = 0
        var maxK: Int = 0

        var myStrings = dataString.components(separatedBy: "\n")

        // Read header
        while !myStrings.isEmpty {
            let line = myStrings.removeFirst()
            if line.hasPrefix("element vertex ") {
                n = Int(line.components(separatedBy: " ")[2])!
                continue
            }
            if line.hasPrefix("end_header") {
                break
            }
        }


        // Read data
        for d in 0..<self.n {
            let line = myStrings[d]
            i = Double(line.components(separatedBy: " ")[0])!
            j = Double(line.components(separatedBy: " ")[1])!
            k = Double(line.components(separatedBy: " ")[2])!

            if Int(i) > maxI {maxI = Int(i)}
            if Int(j) > maxJ {maxJ = Int(j)}
            if Int(k) > maxK {maxK = Int(k)}

            let v = PointCloudVertex(i:i, j:j, k:k, t:.fixed)
            vertices.append(v)

        }
        NSLog("Point cloud data loaded: %d points", n)

        return (maxI, maxJ, maxK)
    }




    public func buildNode(points: [PointCloudVertex]) -> SCNNode {
        let vertexData = NSData(
            bytes: points,
            length: MemoryLayout<PointCloudVertex>.size * points.count
        )
        let positionSource = SCNGeometrySource(
            data: vertexData as Data,
            semantic: SCNGeometrySource.Semantic.vertex,
            vectorCount: points.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<PointCloudVertex>.size
        )
        let colorSource = SCNGeometrySource(
            data: vertexData as Data,
            semantic: SCNGeometrySource.Semantic.color,
            vectorCount: points.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: MemoryLayout<Float>.size * 3,
            dataStride: MemoryLayout<PointCloudVertex>.size
        )
        let elements = SCNGeometryElement(
            data: nil,
            primitiveType: .point,
            primitiveCount: points.count,
            bytesPerIndex: MemoryLayout<Int>.size
        )
        let pointsGeometry = SCNGeometry(sources: [positionSource, colorSource], elements: [elements])

        return SCNNode(geometry: pointsGeometry)
    }
}
