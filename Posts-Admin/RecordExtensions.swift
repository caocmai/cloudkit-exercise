//
//  RecordExtensions.swift
//  Posts-Admin
//
//  Created by Cao Mai on 7/1/20.
//  Copyright © 2020 Cao. All rights reserved.
//

import Foundation

extension Category {
    enum RecordKey: String {
        case title
        case order
    }
}

extension Post {
    enum RecordKey: String {
        case title
        case url
        case date
    }
}
