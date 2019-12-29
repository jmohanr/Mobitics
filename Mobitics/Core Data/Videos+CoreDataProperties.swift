//
//  Videos+CoreDataProperties.swift
//  
//
//  Created by Vaayoo on 28/12/19.
//
//

import Foundation
import CoreData


extension Videos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Videos> {
        return NSFetchRequest<Videos>(entityName: "Videos")
    }

    @NSManaged public var id: String?
    @NSManaged public var thumb: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var videoDescription: String?

}
