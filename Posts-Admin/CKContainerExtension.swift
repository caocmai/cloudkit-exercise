//
//  CKContainer.swift
//  Posts-Admin
//
//  Created by Cao Mai on 7/1/20.
//  Copyright © 2020 Cao. All rights reserved.
//

import Foundation
import CloudKit

extension CKContainer{
    static var shared: CKContainer{
        return CKContainer(identifier: "iCloud.com.caomai.Posts-Admin")
    }
}
