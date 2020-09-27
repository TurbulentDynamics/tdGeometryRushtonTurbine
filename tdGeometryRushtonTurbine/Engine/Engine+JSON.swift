//
//  Engine+JSON.swift
//  tdLBGeometryRushtonTurbineGUI
//
//  Created by Alex on 2020-09-26.
//  Copyright © 2020 Turbulent Dynamics. All rights reserved.
//

import Foundation
import MobileCoreServices

extension Engine {
    func loadJson() {
        actionSubject.send(.pick(["public.json"], { [weak self] url in
            do {
                self?.state = try readTurbineState(url)
            } catch {
                // TODO show error
                print(error)
            }
        }))
    }

    func saveJson() {
        actionSubject.send(.pick([kUTTypeFolder as String], { [weak self] url in
            guard let state = self?.state else {
                return
            }

            do {
                try saveTurbineState(state: state, url: url)
            } catch {
                // TODO show error
                print(error)
            }
        }))
    }
}
