import Foundation
import UserNotifications
import SwiftUI

@MainActor
class AppViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var overtimes: [Overtime] = []
    @Published var selectedDate: Date = Date()
    
    private let userDefaults = UserDefaults.standard
    private let overtimeKey = "savedOvertimes"
    private let userKey = "currentUser"
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    init() {
        loadUser()
        loadOvertimes()
        setupNotifications()
    }
    
    func loadUser() {
        if let userData = userDefaults.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        }
    }
    
    func saveUser(_ user: User) {
        currentUser = user
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: userKey)
        }
        setupNotifications()
    }
    
    private func loadOvertimes() {
        if let data = userDefaults.data(forKey: overtimeKey),
           let decoded = try? JSONDecoder().decode([Overtime].self, from: data) {
            overtimes = decoded
        }
    }
    
    func saveOvertime(_ overtime: Overtime) {
        guard let currentUser = currentUser else { return }
        
        let newOvertime = Overtime(
            id: overtime.id,
            userId: currentUser.id,
            date: overtime.date,
            hours: overtime.hours,
            description: overtime.description,
            city: overtime.city,
            coordinates: overtime.coordinates
        )
        
        overtimes.append(newOvertime)
        saveOvertimes()
    }
    
    func deleteOvertime(at offsets: IndexSet) {
        overtimes.remove(atOffsets: offsets)
        saveOvertimes()
    }
    
    private func saveOvertimes() {
        if let encoded = try? JSONEncoder().encode(overtimes) {
            userDefaults.set(encoded, forKey: overtimeKey)
        }
    }
    
    private func setupNotifications() {
        guard let user = currentUser else { return }
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [weak self] granted, _ in
            if granted {
                self?.scheduleNotification(at: user.notificationTime)
            }
        }
    }
    
    private func scheduleNotification(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Nadgodziny"
        content.body = "Czy pracowałeś dzisiaj po godzinach? Dodaj swoje nadgodziny!"
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "pl_PL")
        
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "overtimeReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
} 