import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var editedUser: User
    @State private var showingTimePicker = false
    @State private var showingSaveConfirmation = false
    
    init() {
        _editedUser = State(initialValue: User())
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Avatar section
                        Circle()
                            .fill(Theme.primaryColor.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Theme.primaryColor)
                            )
                            .padding(.top)
                        
                        // Personal data section
                        VStack(alignment: .leading, spacing: 20) {
                            sectionHeader("Dane osobowe", icon: "person.fill")
                            
                            VStack(spacing: 16) {
                                customTextField(
                                    icon: "person",
                                    placeholder: "Imię i nazwisko",
                                    text: $editedUser.name
                                )
                                
                                customTextField(
                                    icon: "building.2",
                                    placeholder: "Dział",
                                    text: $editedUser.department
                                )
                                
                                customTextField(
                                    icon: "envelope",
                                    placeholder: "Email",
                                    text: $editedUser.email,
                                    keyboardType: .emailAddress
                                )
                            }
                        }
                        .padding()
                        .modernCard()
                        .padding(.horizontal)
                        
                        // Supervisor section
                        VStack(alignment: .leading, spacing: 20) {
                            sectionHeader("Kierownik", icon: "person.2.fill")
                            
                            customTextField(
                                icon: "envelope",
                                placeholder: "Email kierownika",
                                text: $editedUser.supervisorEmail,
                                keyboardType: .emailAddress
                            )
                        }
                        .padding()
                        .modernCard()
                        .padding(.horizontal)
                        
                        // Notifications section
                        VStack(alignment: .leading, spacing: 20) {
                            sectionHeader("Powiadomienia", icon: "bell.fill")
                            
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(Theme.primaryColor)
                                    .frame(width: 24)
                                
                                DatePicker(
                                    "Godzina przypomnienia",
                                    selection: $editedUser.notificationTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .environment(\.locale, Locale(identifier: "pl_PL"))
                            }
                        }
                        .padding()
                        .modernCard()
                        .padding(.horizontal)
                        
                        // Save button
                        Button(action: {
                            viewModel.saveUser(editedUser)
                            showingSaveConfirmation = true
                        }) {
                            Text("Zapisz zmiany")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.primaryColor)
                                .foregroundColor(.white)
                                .cornerRadius(Theme.cornerRadius)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                }
            }
            .navigationTitle("Profil")
            .onAppear {
                if let currentUser = viewModel.currentUser {
                    editedUser = currentUser
                }
            }
            .alert("Zapisano zmiany", isPresented: $showingSaveConfirmation) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Theme.primaryColor)
            Text(title)
                .font(Theme.Typography.headline)
        }
    }
    
    private func customTextField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Theme.primaryColor)
                .frame(width: 24)
            
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textContentType(keyboardType == .emailAddress ? .emailAddress : nil)
        }
        .padding()
        .background(Theme.backgroundColor)
        .cornerRadius(10)
    }
} 