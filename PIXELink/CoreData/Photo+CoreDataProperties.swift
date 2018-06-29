//
//  Photo+CoreDataProperties.swift
//  PIXELink
//
//  Created by Xavi Anderhub on 6/26/18.
//  Copyright © 2018 Xavi Anderhub. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var localIdentifier: String?
    @NSManaged public var red: Float
    @NSManaged public var green: Float
    @NSManaged public var blue: Float

}
