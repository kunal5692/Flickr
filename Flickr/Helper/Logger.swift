//
//  Logger.swift
//  Flickr
//
//  Created by kunal.ch on 30/06/19.
//  Copyright © 2019 kunal.ch. All rights reserved.
//

import Foundation

final class Logger {
    static func debug(_ tag : String, _ msg: Any) {
        #if DEBUG
        debugPrint("\(tag): \(msg)")
        #endif
    }
}
