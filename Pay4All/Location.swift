//
//  Location.swift
//  Pay4All
//
//  Created by Carlos Doki on 04/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import CoreLocation


class Location {
    static var sharedInstance = Location()
    private init() {}
    
    var latitude: Double!
    var longitude: Double!
}

