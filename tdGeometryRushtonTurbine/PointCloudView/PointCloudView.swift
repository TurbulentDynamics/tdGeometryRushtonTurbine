import Foundation
import SwiftUI
import SceneKit

struct PointCloudView: UIViewRepresentable {
    
    var pointCloudEngine: PointCloudEngine
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PointCloudView>) {
            
    }
    
    func makeUIView(context: UIViewRepresentableContext<PointCloudView>) -> UIView {
        let view = SCNView()
        view.scene = pointCloudEngine.scene
        view.delegate = pointCloudEngine
        view.rendersContinuously = true
        view.autoenablesDefaultLighting = true
        view.allowsCameraControl = true
        //view.showsStatistics = true
        return view
    }
}
