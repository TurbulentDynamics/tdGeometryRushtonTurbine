//
//  ContentView.swift
//  tdGeometryRushtonTurbine
//
//  Created by  Ivan Ushakov on 24.01.2020.
//  Copyright © 2020 Lunar Key. All rights reserved.
//

import SwiftUI
import tdLBGeometryRushtonTurbineLib

struct ContentView: View {
    @State var engine: Engine
    @State var pointCloudEngine: PointCloudEngine
    @State var turbine: RushtonTurbine
    @State var rtTurbine: RushtonTurbineMidPointCPP

    #if targetEnvironment(macCatalyst)
    var body: some View {
        TabBarView(engine: engine, pointCloudEngine: pointCloudEngine, turbine: turbine, rtTurbine: rtTurbine)
    }
    #else
    var body: some View {
        TabBarView(engine: engine, pointCloudEngine: pointCloudEngine, turbine: turbine, rtTurbine: rtTurbine)
    }
    #endif
}

struct TabBarView: View {
    var engine: Engine
    var pointCloudEngine: PointCloudEngine
    var turbine: RushtonTurbine
    var rtTurbine: RushtonTurbineMidPointCPP

    enum Tab: Int {
        case render, pointCloud, control
    }

    @State var selection: Tab = .render
    
    func tabItem(text: String) -> some View {
        VStack {
            Text(text)
        }
    }

    var body: some View {

        ZStack(alignment: Alignment.top) {
            VStack {
                TabView(selection: $selection) {
                    RenderView(engine: engine).tabItem{
                        self.tabItem(text: "Render")
                    }.tag(Tab.render)
                    
                    PointCloudView(pointCloudEngine: pointCloudEngine).tabItem{
                        self.tabItem(text: "PointCloud")
                    }.tag(Tab.pointCloud)
                    .onAppear {
                        print("PointCloud activated")
                        
                        print("updateRotatingGeometry(atTheta: 1.0)")
                        rtTurbine.updateRotatingGeometry(atTheta: 1.0)

                        if
                            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                            let sceneDelegate = windowScene.delegate as? SceneDelegate {

                            sceneDelegate.updateScene(engine: engine, turbine: turbine, rtTurbine: rtTurbine)
                        }
                        
                    }

                }
                
                Spacer(minLength: 50)
            }
            
            SlideOverCard {
                VStack {
                    HStack {
                        Button("Render") { self.selection = .render }.foregroundColor(Color.secondary)
                        Button("PointCloud") { self.selection = .pointCloud }.foregroundColor(Color.secondary)
                    }
                    Spacer()
                    ControlView(state: engine.state).tabItem {
                        self.tabItem(text: "Control")
                    }
                }
            }
            
        }.edgesIgnoringSafeArea(.top)
    }
}

struct Handle : View {
    private let handleThickness = CGFloat(5.0)
    var body: some View {
        RoundedRectangle(cornerRadius: handleThickness / 2.0)
            .frame(width: 40, height: handleThickness)
            .foregroundColor(Color.secondary)
            .padding(5)
    }
}

struct SlideOverCard<Content: View> : View {
    @GestureState private var dragState = DragState.inactive
    @State var position = CardPosition.top
    @State var windowSize = CGSize()

    func setWindowSize(_ geometry: GeometryProxy) -> some View {
        
        DispatchQueue.main.async {
            self.windowSize = geometry.size
        }

      return EmptyView()
    }
    
    var content: () -> Content
    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)
        
        return GeometryReader { geometry in

            self.setWindowSize(geometry)
            
                HStack {
                    
                Group {
                    VStack {
                            Spacer()
                            Handle()
                            
                        self.content()
                    }
                }
                .padding(10)
                .frame(width: geometry.size.width, height: 0.70 * geometry.size.height)
                .background(Color.gray)
                .cornerRadius(10.0)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
                .offset(y: self.getPosition(position: position) + self.dragState.translation.height)
                .animation(self.dragState.isDragging ? nil : .interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
                .gesture(drag)
            }
        }
    }

    func getPosition(position: CardPosition) -> CGFloat {
        
        switch(position) {
        case .top:
            return 0.3 * self.windowSize.height
        case .bottom:
            return self.windowSize.height - 40
        }
        
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        let cardTopEdgeLocation = self.getPosition(position: position) + drag.translation.height
        let positionAbove: CardPosition
        let positionBelow: CardPosition
        var closestPosition: CardPosition
        
        positionAbove = .top
        positionBelow = .bottom

        if (cardTopEdgeLocation - self.getPosition(position: positionAbove)) < (self.getPosition(position: positionBelow) - cardTopEdgeLocation) {
            closestPosition = positionAbove
        } else {
            closestPosition = positionBelow
        }

        if verticalDirection > 0 {
            self.position = positionBelow
        } else if verticalDirection < 0 {
            self.position = positionAbove
        } else {
            self.position = closestPosition
        }
    }
}

enum CardPosition {
    case top
    case bottom
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
