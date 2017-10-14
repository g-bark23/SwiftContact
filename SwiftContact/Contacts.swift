//
//  Contacts.swift
//  SwiftContact
//
//  Created by Garrett Barker on 10/11/17.
//  Copyright © 2017 Garrett Barker. All rights reserved.
//

import Foundation
import RealmSwift

class Contacts : Object {
    dynamic var firstName = ""
    dynamic var lastName = ""
    dynamic var phoneNumber = ""
    dynamic var email = ""
    dynamic var picture: NSData? = nil
    dynamic var address = ""
    dynamic var category = ""
}
