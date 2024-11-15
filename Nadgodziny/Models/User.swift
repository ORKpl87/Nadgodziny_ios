import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var email: String
    var name: String
    var department: String
    var supervisorEmail: String
    var notificationTime: Date
    var isActive: Bool
    
    init(id: UUID = UUID(), email: String = "", name: String = "", 
         department: String = "", supervisorEmail: String = "", 
         notificationTime: Date = Date(), isActive: Bool = true) {
        self.id = id
        self.email = email
        self.name = name
        self.department = department
        self.supervisorEmail = supervisorEmail
        self.notificationTime = notificationTime
        self.isActive = isActive
    }
} 