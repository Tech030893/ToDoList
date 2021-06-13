import Foundation
import CoreData

extension ToDoListItem
{
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoListItem>
    {
        return NSFetchRequest<ToDoListItem>(entityName: "ToDoListItem")
    }
    
    @NSManaged public var name: String?
}

extension ToDoListItem : Identifiable
{
    
}
