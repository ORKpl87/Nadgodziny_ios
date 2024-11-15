import SwiftUI
import CoreLocation

struct OvertimeListView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingAddSheet = false
    @State private var newOvertime = Overtime(userId: UUID())
    
    private var userOvertimes: [Overtime] {
        guard let currentUser = viewModel.currentUser else { return [] }
        return viewModel.overtimes
            .filter { $0.userId == currentUser.id }
            .sorted(by: { $0.date > $1.date })
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Karta podsumowania
                        VStack(spacing: 8) {
                            Text("Dzisiaj")
                                .font(Theme.Typography.headline)
                            
                            HStack(spacing: 20) {
                                StatCard(
                                    title: "Nadgodziny",
                                    value: String(format: "%.1f h", todaysHours),
                                    icon: "clock.fill"
                                )
                                
                                StatCard(
                                    title: "Ten miesiąc",
                                    value: String(format: "%.1f h", monthlyHours),
                                    icon: "calendar"
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Lista nadgodzin
                        LazyVStack(spacing: 12) {
                            ForEach(groupedOvertimes.keys.sorted().reversed(), id: \.self) { date in
                                Section(header: DateHeader(date: date)) {
                                    ForEach(groupedOvertimes[date] ?? []) { overtime in
                                        OvertimeRow(overtime: overtime)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Nadgodziny")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if let userId = viewModel.currentUser?.id {
                            newOvertime = Overtime(userId: userId)
                            showingAddSheet = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Theme.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddOvertimeView(overtime: $newOvertime, isPresented: $showingAddSheet)
            }
        }
    }
    
    private var todaysHours: Double {
        let calendar = Calendar.current
        return userOvertimes
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.hours }
    }
    
    private var monthlyHours: Double {
        let calendar = Calendar.current
        return userOvertimes
            .filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
            .reduce(0) { $0 + $1.hours }
    }
    
    private var groupedOvertimes: [Date: [Overtime]] {
        Dictionary(grouping: userOvertimes) { overtime in
            Calendar.current.startOfDay(for: overtime.date)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Theme.primaryColor)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(Theme.Typography.title)
                    .foregroundColor(Theme.primaryColor)
                
                Text(title)
                    .font(Theme.Typography.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .glassmorphic()
    }
}

struct DateHeader: View {
    let date: Date
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        Text(date, formatter: Self.dateFormatter)
            .font(Theme.Typography.headline)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 8)
    }
}

struct OvertimeRow: View {
    let overtime: Overtime
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 16) {
            // Znacznik czasu
            VStack(spacing: 4) {
                Text(overtime.date, formatter: Self.timeFormatter)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.primaryColor)
                
                Text("\(String(format: "%.1f", overtime.hours))h")
                    .font(Theme.Typography.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 60)
            
            // Szczegóły
            VStack(alignment: .leading, spacing: 4) {
                if !overtime.city.isEmpty {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(Theme.secondaryColor)
                        Text(overtime.city)
                            .font(Theme.Typography.body)
                    }
                }
                
                if !overtime.description.isEmpty {
                    Text(overtime.description)
                        .font(Theme.Typography.body)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .modernCard()
    }
}

struct AddOvertimeView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var overtime: Overtime
    @Binding var isPresented: Bool
    @StateObject private var locationManager = LocationManager()
    @State private var isLoadingLocation = false
    
    // Tymczasowe stany do przechowywania wartości
    @State private var date: Date
    @State private var hours: Double
    @State private var description: String
    @State private var city: String
    
    init(overtime: Binding<Overtime>, isPresented: Binding<Bool>) {
        _overtime = overtime
        _isPresented = isPresented
        _date = State(initialValue: overtime.wrappedValue.date)
        _hours = State(initialValue: overtime.wrappedValue.hours)
        _description = State(initialValue: overtime.wrappedValue.description)
        _city = State(initialValue: overtime.wrappedValue.city)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Data", selection: $date)
                        .tint(Theme.primaryColor)
                        .onChange(of: date) { updateOvertime() }
                        .environment(\.locale, Locale(identifier: "pl_PL"))
                }
                
                Section {
                    HStack {
                        Text("Liczba godzin")
                        Spacer()
                        TextField("0.0", value: $hours, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .onChange(of: hours) { updateOvertime() }
                    }
                }
                
                Section {
                    HStack {
                        TextField("Miasto", text: $city)
                            .onChange(of: city) { updateOvertime() }
                        Button(action: {
                            isLoadingLocation = true
                            locationManager.requestLocation()
                        }) {
                            if isLoadingLocation {
                                ProgressView()
                                    .tint(Theme.primaryColor)
                            } else {
                                Image(systemName: "location.fill")
                                    .foregroundColor(Theme.primaryColor)
                            }
                        }
                    }
                }
                
                Section {
                    TextField("Opis (opcjonalnie)", text: $description)
                        .onChange(of: description) { updateOvertime() }
                }
            }
            .navigationTitle("Dodaj nadgodziny")
            .navigationBarItems(
                leading: Button("Anuluj") {
                    isPresented = false
                }
                .foregroundColor(Theme.secondaryColor),
                trailing: Button("Zapisz") {
                    viewModel.saveOvertime(overtime)
                    isPresented = false
                }
                .foregroundColor(Theme.primaryColor)
            )
            .onChange(of: locationManager.location) { location in
                guard let location = location else { return }
                
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(location) { placemarks, error in
                    isLoadingLocation = false
                    if let city = placemarks?.first?.locality {
                        self.city = city
                        updateOvertime(coordinates: location.coordinate)
                    }
                }
            }
        }
    }
    
    private func updateOvertime(coordinates: CLLocationCoordinate2D? = nil) {
        overtime = Overtime(
            id: overtime.id,
            userId: overtime.userId,
            date: date,
            hours: hours,
            description: description,
            city: city,
            coordinates: coordinates ?? overtime.coordinates
        )
    }
}

// Menedżer lokalizacji
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Błąd lokalizacji: \(error.localizedDescription)")
    }
} 