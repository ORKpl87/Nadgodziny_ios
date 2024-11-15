import SwiftUI
import MessageUI

struct MonthlyReportView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedMonth = Date()
    @State private var showingMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    @State private var showingMailError = false
    
    var monthlyOvertimes: [Overtime] {
        let calendar = Calendar.current
        return viewModel.overtimes.filter { overtime in
            calendar.isDate(overtime.date, equalTo: selectedMonth, toGranularity: .month)
        }
    }
    
    var totalHours: Double {
        monthlyOvertimes.reduce(0) { $0 + $1.hours }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    DatePicker("Miesiąc", selection: $selectedMonth, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .environment(\.locale, Locale(identifier: "pl_PL"))
                        .onChange(of: selectedMonth) { _ in
                            // Aktualizacja raportu po zmianie miesiąca
                        }
                }
                
                Section("Podsumowanie") {
                    HStack {
                        Text("Łączna liczba godzin")
                        Spacer()
                        Text(String(format: "%.1f h", totalHours))
                            .bold()
                            .foregroundColor(.blue)
                    }
                }
                
                Section("Szczegóły") {
                    ForEach(monthlyOvertimes.sorted(by: { $0.date > $1.date })) { overtime in
                        OvertimeRow(overtime: overtime)
                    }
                }
            }
            .navigationTitle("Raport miesięczny")
            .toolbar {
                Button {
                    if MFMailComposeViewController.canSendMail() {
                        showingMailView = true
                    } else {
                        showingMailError = true
                    }
                } label: {
                    Image(systemName: "envelope")
                }
            }
            .sheet(isPresented: $showingMailView) {
                MailView(result: $mailResult) { composer in
                    configureMailComposer(composer)
                }
            }
            .alert("Nie można wysłać maila", isPresented: $showingMailError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Sprawdź czy masz skonfigurowane konto email na urządzeniu.")
            }
        }
    }
    
    private func configureMailComposer(_ composer: MFMailComposeViewController) {
        guard let user = viewModel.currentUser else { return }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "MMMM yyyy"
        let monthStr = formatter.string(from: selectedMonth)
        
        composer.setToRecipients([user.supervisorEmail])
        composer.setSubject("Raport nadgodzin za \(monthStr)")
        
        var emailBody = """
        Raport nadgodzin za \(monthStr)
        Pracownik: \(user.name)
        Dział: \(user.department)
        
        Łączna liczba nadgodzin: \(String(format: "%.1f", totalHours))
        
        Szczegółowe zestawienie:
        
        """
        
        for overtime in monthlyOvertimes.sorted(by: { $0.date < $1.date }) {
            let dateStr = overtime.date.formatted(date: .long, time: .shortened)
            emailBody += "\(dateStr): \(String(format: "%.1f", overtime.hours)) godzin"
            if !overtime.description.isEmpty {
                emailBody += " - \(overtime.description)"
            }
            emailBody += "\n"
        }
        
        composer.setMessageBody(emailBody, isHTML: false)
    }
}

struct MailView: UIViewControllerRepresentable {
    @Binding var result: Result<MFMailComposeResult, Error>?
    let configure: (MFMailComposeViewController) -> Void
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        configure(composer)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                 didFinishWith result: MFMailComposeResult,
                                 error: Error?) {
            if let error = error {
                parent.result = .failure(error)
            } else {
                parent.result = .success(result)
            }
            controller.dismiss(animated: true)
        }
    }
} 