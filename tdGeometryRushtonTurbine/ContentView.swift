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

    #if targetEnvironment(macCatalyst)
    var body: some View {
        TabBarView(engine: engine, pointCloudEngine: pointCloudEngine, turbine: turbine)
//        NavigationView {
//            ControlView(state: engine.state)
//                .navigationBarTitle("")
//                .navigationBarHidden(true)
//            RenderView(engine: engine)
//        }
    }
    #else
    var body: some View {
        TabBarView(engine: engine, pointCloudEngine: pointCloudEngine, turbine: turbine)
    }
    #endif
}

struct TabBarView: View {
    var engine: Engine
    var pointCloudEngine: PointCloudEngine
    var turbine: RushtonTurbine
    
    enum Tab: Int {
        case render, pointCloud, control
    }

    func tabItem(text: String) -> some View {
        VStack {
            Text(text)
        }
    }

    var body: some View {

        ZStack(alignment: Alignment.top) {
            TabView() {
                RenderView(engine: engine).tabItem{
                    self.tabItem(text: "Render")
                }.tag(Tab.render)
                
                PointCloudView(pointCloudEngine: pointCloudEngine).tabItem{
                    self.tabItem(text: "PointCloud")
                }.tag(Tab.pointCloud)

//                ControlView(state: engine.state).tabItem {
//                    self.tabItem(text: "Control")
//                }.tag(Tab.control)
            }
            
            SlideOverCard {
                VStack {
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
    
    var content: () -> Content
    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)
        
        return GeometryReader { geometry in
            
            HStack {
                Spacer(minLength: 20)
                
            Group {
                VStack {
                    Handle()
                    self.content()
                }
            }
            .padding(10)
            .frame(width: geometry.size.width-40, height: UIScreen.main.bounds.height/2)
            .background(Color.green)
            .cornerRadius(10.0)
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
            .offset(y: self.position.rawValue + self.dragState.translation.height)
            .animation(self.dragState.isDragging ? nil : .interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
            .gesture(drag)
                
            Spacer(minLength: 20)
        }
    }
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        let cardTopEdgeLocation = self.position.rawValue + drag.translation.height
        let positionAbove: CardPosition
        let positionBelow: CardPosition
        let closestPosition: CardPosition
        
        if cardTopEdgeLocation <= CardPosition.middle.rawValue {
            positionAbove = .top
            positionBelow = .middle
        } else {
            positionAbove = .middle
            positionBelow = .bottom
        }
        
        if (cardTopEdgeLocation - positionAbove.rawValue) < (positionBelow.rawValue - cardTopEdgeLocation) {
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

enum CardPosition: CGFloat {
    case top = 100
    case middle = 250
    case bottom = 500
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
