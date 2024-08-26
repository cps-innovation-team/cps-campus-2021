//
//  DirectoryView.swift
//  CPS Campus (iOS)
//
//  6/17/2023
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import GoogleSignIn

struct DirectoryView: View {
    let clubs: [Club]
    
    @State var users = [User]()
    @State var search: String = ""
    @State var gradFilter = [seniorClass, juniorClass, sophClass, freshClass].joined(separator: ",")+",Faculty"
    @State var groupBy = "first"
    
    let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W", "X","Y", "Z"]
    
    var body: some View {
        VStack {
            List {
                if search == "" {
                    Section {
                        HStack {
                            Text("Show").opacity(0.5)
                            Spacer()
                            Picker(gradFilter, selection: $gradFilter) {
                                Text("All Students and Faculty").tag([seniorClass, juniorClass, sophClass, freshClass].joined(separator: ",")+",Faculty")
                                Text("All Students").tag([seniorClass, juniorClass, sophClass, freshClass].joined(separator: ","))
                                Divider()
                                ForEach([seniorClass, juniorClass, sophClass, freshClass], id: \.self) { gradYear in
                                    Text(gradYear).tag(gradYear)
                                }
                                Text("Faculty").tag("Faculty")
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                        HStack {
                            Text("Group by").opacity(0.5)
                            Spacer()
                            Picker(groupBy, selection: $groupBy) {
                                Text("First Name").tag("first")
                                Text("Last Name").tag("last")
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                    }
                    ForEach(alphabet, id: \.self) { letter in
                        Section(header: Text(letter).bold()) {
                            ForEach(users.filter{ if $0.name.components(separatedBy: " ").count > 1 && groupBy == "last" { return $0.name.components(separatedBy: " ")[1].starts(with: letter) } else { return $0.name.starts(with: letter) }}.filter{ gradFilter.contains($0.gradYear) }.sorted(by: {if $0.name.components(separatedBy: " ").count > 1 && $1.name.components(separatedBy: " ").count > 1 { return $0.name.components(separatedBy: " ")[1] < $1.name.components(separatedBy: " ")[1]} else { return false }})) { user in
                                NavigationLink(destination: DirectorySubview(campusID: user, clubs: clubs), label: {
                                    HStack(spacing: 15) {
                                        if user.privacy?["hideProfilePicture"] ?? false == true || user.imageLink.isEmpty {
                                            Color(.systemGray3)
                                                .frame(width: 55, height: 55)
                                                .clipShape(Circle())
                                        } else {
                                            AsyncImage(url: URL(string: user.imageLink)) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(width: 55, height: 55)
                                            .clipShape(Circle())
                                        }
                                        VStack(spacing: 2) {
                                            HStack {
                                                Text(user.gradYear == "Faculty" ? user.name : user.name+" '"+user.gradYear.dropFirst(2)).bold()
                                                    .foregroundStyle(Color("SystemContrast"))
                                                Spacer()
                                            }
                                            HStack {
                                                Text(user.id+"@college-prep.org")
                                                    .foregroundStyle(Color(.gray))
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                                Spacer()
                                            }
                                        }
                                        Spacer()
                                    }.padding(.vertical, 3)
                                })
                            }
                        }
                    }
                } else {
                    ForEach(users.filter{$0.name.lowercased().starts(with: search.lowercased())}.sorted(by: {if $0.name.components(separatedBy: " ").count > 1 && $1.name.components(separatedBy: " ").count > 1 { return $0.name.components(separatedBy: " ")[1] < $1.name.components(separatedBy: " ")[1]} else { return false }})) { user in
                        NavigationLink(destination: DirectorySubview(campusID: user, clubs: clubs), label: {
                            HStack(spacing: 15) {
                                if user.privacy?["hideProfilePicture"] ?? false == true || user.imageLink.isEmpty {
                                    Color(.systemGray3)
                                        .frame(width: 55, height: 55)
                                        .clipShape(Circle())
                                } else {
                                    AsyncImage(url: URL(string: user.imageLink)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 55, height: 55)
                                    .clipShape(Circle())
                                }
                                VStack(spacing: 2) {
                                    HStack {
                                        Text(user.gradYear == "Faculty" ? user.name : user.name+" '"+user.gradYear.dropFirst(2)).bold()
                                            .foregroundStyle(Color("SystemContrast"))
                                        Spacer()
                                    }
                                    HStack {
                                        Text(user.id+"@college-prep.org")
                                            .foregroundStyle(Color(.gray))
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Spacer()
                                    }
                                }
                                Spacer()
                            }.padding(.vertical, 5)
                        })
                    }
                    ForEach(users.filter{ if $0.name.components(separatedBy: " ").count > 1 { return $0.name.components(separatedBy: " ")[1].lowercased().starts(with: search.lowercased()) } else { return false }}.sorted(by: {if $0.name.components(separatedBy: " ").count > 1 && $1.name.components(separatedBy: " ").count > 1 { return $0.name.components(separatedBy: " ")[1] < $1.name.components(separatedBy: " ")[1]} else { return false }})) { user in
                        NavigationLink(destination: DirectorySubview(campusID: user, clubs: clubs), label: {
                            HStack(spacing: 15) {
                                if user.privacy?["hideProfilePicture"] ?? false == true || user.imageLink.isEmpty {
                                    Color(.systemGray3)
                                        .frame(width: 55, height: 55)
                                        .clipShape(Circle())
                                } else {
                                    AsyncImage(url: URL(string: user.imageLink)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 55, height: 55)
                                    .clipShape(Circle())
                                }
                                VStack(spacing: 2) {
                                    HStack {
                                        Text(user.gradYear == "Faculty" ? user.name : user.name+" '"+user.gradYear.dropFirst(2)).bold()
                                            .foregroundStyle(Color("SystemContrast"))
                                        Spacer()
                                    }
                                    HStack {
                                        Text(user.id+"@college-prep.org")
                                            .foregroundStyle(Color(.gray))
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Spacer()
                                    }
                                }
                                Spacer()
                            }.padding(.vertical, 5)
                        })
                    }
                }
            }
        }
        .navigationTitle("Directory")
        .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for students and faculty")
        .disableAutocorrection(true)
        .onAppear {
            fetchAllUsers(completion: { allUsers in
                users = allUsers
            })
        }
    }
}

struct DirectoryViewiPadOS: View {
    let clubs: [Club]
    
    @State var users = [User]()
    @State var search: String = ""
    @State var gradFilter = [seniorClass, juniorClass, sophClass, freshClass].joined(separator: ",")+",Faculty"
    @State var groupBy = "first"
    
    @State var selectedUser: User?
    
    let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W", "X","Y", "Z"]
    
    var body: some View {
        VStack {
            List {
                if search == "" {
                    Section {
                        HStack {
                            Text("Show").opacity(0.5)
                            Spacer()
                            Picker(gradFilter, selection: $gradFilter) {
                                Text("All Students and Faculty").tag([seniorClass, juniorClass, sophClass, freshClass].joined(separator: ",")+",Faculty")
                                Text("All Students").tag([seniorClass, juniorClass, sophClass, freshClass].joined(separator: ","))
                                Divider()
                                ForEach([seniorClass, juniorClass, sophClass, freshClass], id: \.self) { gradYear in
                                    Text(gradYear).tag(gradYear)
                                }
                                Text("Faculty").tag("Faculty")
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                        HStack {
                            Text("Group by").opacity(0.5)
                            Spacer()
                            Picker(groupBy, selection: $groupBy) {
                                Text("First Name").tag("first")
                                Text("Last Name").tag("last")
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                    }
                    ForEach(alphabet, id: \.self) { letter in
                        Section(header: Text(letter).bold()) {
                            ForEach(users.filter{ if $0.name.components(separatedBy: " ").count > 1 && groupBy == "last" { return $0.name.components(separatedBy: " ")[1].starts(with: letter) } else { return $0.name.starts(with: letter) }}.filter{ gradFilter.contains($0.gradYear) }.sorted(by: {if $0.name.components(separatedBy: " ").count > 1 && $1.name.components(separatedBy: " ").count > 1 { return $0.name.components(separatedBy: " ")[1] < $1.name.components(separatedBy: " ")[1]} else { return false }})) { user in
                                Button(action: {
                                    selectedUser = user
                                }, label: {
                                    HStack(spacing: 15) {
                                        if user.privacy?["hideProfilePicture"] ?? false == true || user.imageLink.isEmpty {
                                            Color(.systemGray3)
                                                .frame(width: 55, height: 55)
                                                .clipShape(Circle())
                                        } else {
                                            AsyncImage(url: URL(string: user.imageLink)) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(width: 55, height: 55)
                                            .clipShape(Circle())
                                        }
                                        VStack(spacing: 2) {
                                            HStack {
                                                Text(user.gradYear == "Faculty" ? user.name : user.name+" '"+user.gradYear.dropFirst(2)).bold()
                                                    .foregroundStyle(Color("SystemContrast"))
                                                Spacer()
                                            }
                                            HStack {
                                                Text(user.id+"@college-prep.org")
                                                    .foregroundStyle(Color(.gray))
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                                Spacer()
                                            }
                                        }
                                        Spacer()
                                    }.padding(.vertical, 3)
                                })
                            }
                        }
                    }
                } else {
                    ForEach(users.filter{$0.name.lowercased().starts(with: search.lowercased())}.sorted(by: {if $0.name.components(separatedBy: " ").count > 1 && $1.name.components(separatedBy: " ").count > 1 { return $0.name.components(separatedBy: " ")[1] < $1.name.components(separatedBy: " ")[1]} else { return false }})) { user in
                        Button(action: {
                            selectedUser = user
                        }, label: {
                            HStack(spacing: 15) {
                                if user.privacy?["hideProfilePicture"] ?? false == true || user.imageLink.isEmpty {
                                    Color(.systemGray3)
                                        .frame(width: 55, height: 55)
                                        .clipShape(Circle())
                                } else {
                                    AsyncImage(url: URL(string: user.imageLink)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 55, height: 55)
                                    .clipShape(Circle())
                                }
                                VStack(spacing: 2) {
                                    HStack {
                                        Text(user.gradYear == "Faculty" ? user.name : user.name+" '"+user.gradYear.dropFirst(2)).bold()
                                            .foregroundStyle(Color("SystemContrast"))
                                        Spacer()
                                    }
                                    HStack {
                                        Text(user.id+"@college-prep.org")
                                            .foregroundStyle(Color(.gray))
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Spacer()
                                    }
                                }
                                Spacer()
                            }.padding(.vertical, 3)
                        })
                    }
                    ForEach(users.filter{ if $0.name.components(separatedBy: " ").count > 1 { return $0.name.components(separatedBy: " ")[1].lowercased().starts(with: search.lowercased()) } else { return false }}.sorted(by: {if $0.name.components(separatedBy: " ").count > 1 && $1.name.components(separatedBy: " ").count > 1 { return $0.name.components(separatedBy: " ")[1] < $1.name.components(separatedBy: " ")[1]} else { return false }})) { user in
                        Button(action: {
                            selectedUser = user
                        }, label: {
                            HStack(spacing: 15) {
                                if user.privacy?["hideProfilePicture"] ?? false == true || user.imageLink.isEmpty {
                                    Color(.systemGray3)
                                        .frame(width: 55, height: 55)
                                        .clipShape(Circle())
                                } else {
                                    AsyncImage(url: URL(string: user.imageLink)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 55, height: 55)
                                    .clipShape(Circle())
                                }
                                VStack(spacing: 2) {
                                    HStack {
                                        Text(user.gradYear == "Faculty" ? user.name : user.name+" '"+user.gradYear.dropFirst(2)).bold()
                                            .foregroundStyle(Color("SystemContrast"))
                                        Spacer()
                                    }
                                    HStack {
                                        Text(user.id+"@college-prep.org")
                                            .foregroundStyle(Color(.gray))
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Spacer()
                                    }
                                }
                                Spacer()
                            }.padding(.vertical, 3)
                        })
                    }
                }
            }
        }
        .navigationTitle("Directory")
        .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for students and faculty")
        .disableAutocorrection(true)
        .onAppear {
            fetchAllUsers(completion: { allUsers in
                users = allUsers
            })
        }
        .sheet(item: $selectedUser) { user in
            NavigationView {
                DirectorySubview(campusID: user, clubs: clubs)
                    .navigationTitle(user.name)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                selectedUser = nil
                            }, label: {
                                Text("Done").bold()
                            })
                        }
                    }
            }
        }
    }
}

struct DirectorySubview: View {
    let campusID: User
    let clubs: [Club]
    
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    
    @Environment(\.openURL) var openURL
    @State var socials = [Social]()
    @State var courses = [Course]()
    @State var showClasses = false
    @State var joinedClubs = [String]()
    @State var currentUserID = ""
    
    let columns2 = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    let columns3 = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        Form {
            if campusID.id == currentUserID {
                Section {
                    HStack {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color("AccentColor"))
                            .frame(width: 25, height: 25)
                            .padding(.trailing, 5)
                        Text("You're seeing a preview of what others see on your directory page")
                    }.padding(.vertical, 10)
                }
            }
            Section(header: Text("**Profile**")) {
                HStack(spacing: 15) {
                    if campusID.privacy?["hideProfilePicture"] ?? false == true || campusID.imageLink.isEmpty {
                        Color(.systemGray3)
                            .frame(width: 55, height: 55)
                            .clipShape(Circle())
                    } else {
                        AsyncImage(url: URL(string: campusID.imageLink)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 55, height: 55)
                        .clipShape(Circle())
                    }
                    VStack(spacing: 2) {
                        HStack {
                            Text(campusID.name).bold()
                                .font(.title3)
                                .foregroundStyle(Color("SystemContrast"))
                            Spacer()
                        }
                        HStack {
                            Text("[\(campusID.id)@college-prep.org](mailto:\(campusID.id)@college-prep.org)".markdownToAttributed())
                                .foregroundStyle(Color("AccentColor"))
                                .truncationMode(.tail)
                                .lineLimit(1)
                            Spacer()
                        }
                    }
                    Spacer()
                }.padding(.vertical, 5)
                HStack {
                    Text("Graduation Year")
                    Spacer()
                    Text(campusID.gradYear)
                }
                if let pronouns = campusID.pronouns {
                    if !pronouns.isEmpty {
                        HStack {
                            Text("Pronouns")
                            Spacer()
                            Text(pronouns)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
            }
            if !socials.isEmpty && gradYear != "Faculty" {
                Section(header: Text("**Socials**"), footer: Text("Socials are visible only to other students, never faculty.")) {
                    ForEach(socials.filter {$0.value != ""}.sorted(by: {$1.key == "Phone" ? false : $0.key == "Phone" ? true : $0.key < $1.key}), id: \.key) { social in
                        Menu {
                            if social.key == "Phone" && URL(string: "tel:\(social.value)") != nil {
                                Button(action: {
                                    openURL(URL(string: "tel:\(social.value)")!)
                                }, label: {
                                    Label("Call \u{22}\(campusID.name.components(separatedBy: " ")[0])\u{22}", systemImage: "phone")
                                })
                                Button(action: {
                                    openURL(URL(string: "sms:\(social.value)")!)
                                }, label: {
                                    Label("Text \u{22}\(campusID.name.components(separatedBy: " ")[0])\u{22}", systemImage: "message")
                                })
                            }
                            Divider()
                            Button(action: {
                                let pasteboard = UIPasteboard.general
                                pasteboard.string = social.value
                            }, label: {
                                Label("Copy", systemImage: "doc.on.doc")
                            })
                        } label: {
                            HStack {
                                Text(social.key)
                                    .foregroundStyle(Color("SystemContrast"))
                                Spacer()
                                if social.key == "Phone" {
                                    Text(format(phoneNumber: social.value) ?? social.value).foregroundStyle(Color("AccentColor"))
                                } else {
                                    Text(social.value)
                                        .foregroundStyle(Color("AccentColor"))
                                }
                            }
                        }
                    }
                }
            }
            if !courses.isEmpty && (campusID.privacy?["hideClasses"] ?? true == false) {
                if showClasses {
                    Section(header: Text("**Classes**")) {
                        LazyVGrid(columns: columns2, spacing: 10) {
                            ForEach(courses.filter{coursesGroup.contains($0.id) || ($0.id == "Compass" && [juniorClass, sophClass].contains(campusID.gradYear))}.sorted(by: {$0.num < $1.num})) { course in
                                HStack {
                                    if course.id == "Compass" {
                                        HStack(spacing: 0) {
                                            Image(systemName: "\(String(course.compassBlock.prefix(1))).square.fill".lowercased())
                                                .font(.title2)
                                                .foregroundStyle(Color(hexString: course.color))
                                            Image(systemName: "\(String(course.visibleRotations)).square.fill".lowercased())
                                                .font(.title2)
                                                .foregroundStyle(Color(hexString: course.color))
                                        }
                                        Text(course.name)
                                            .fontWeight(.medium)
                                    } else {
                                        HStack(spacing: 0) {
                                            Image(systemName: "\(String(course.id.prefix(1))).square.fill".lowercased())
                                                .font(.title2)
                                                .foregroundStyle(course.isFreePeriod ? .gray : Color(hexString: course.color))
                                            if course.visibleRotations != 0 {
                                                Image(systemName: "\(String(course.visibleRotations)).square.fill".lowercased())
                                                    .font(.title2)
                                                    .foregroundStyle(Color(hexString: course.color))
                                            }
                                        }
                                        Text(course.isFreePeriod ? "Free Period" : course.name)
                                            .fontWeight(.medium)
                                    }
                                    Spacer()
                                }
                            }
                        }.padding(.vertical, 5).padding(5)
                    }
                } else {
                    Section(header: Text("**Classes**")) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(.blue)
                                .frame(width: 25, height: 25)
                                .padding(.trailing, 5)
                            Text("You cannot see another's classes when you are currently hiding yours.")
                        }.padding(.vertical, 10)
                        Button(action: {
                            openURL(URL(string: "cpscampus://settings/campusID")!)
                        }, label: {
                            Text("Edit Privacy Settings")
                        })
                    }
                }
            }
            if !joinedClubs.isEmpty {
                Section(header: Text("**Clubs**"), footer: Text("Anonymously-followed affinity spaces are never visible above, but visible to the leaders of those clubs.").padding(.bottom)) {
                    LazyVGrid(columns: columns2, spacing: 15) {
                        ForEach(joinedClubs.sorted(by: {$0 < $1}), id: \.self) { clubName in
                            if let wrappedClub = clubs.first(where: {$0.name == clubName}) {
                                HStack(spacing: 10) {
                                    AsyncImage(url: URL(string: wrappedClub.image)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Color(hexString: wrappedClub.color)
                                            .scaledToFill()
                                    }
                                    .clipShape(Circle())
                                    .saturation(1.1)
                                    .frame(width: 55, height: 55)
                                    Text(wrappedClub.nickname != "" ? wrappedClub.nickname : wrappedClub.name)
                                        .fontWeight(.medium)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                            }
                        }
                    }.padding(.vertical, 5).padding(5)
                }
            }
        }
        .navigationTitle(campusID.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            socials = campusID.socials?.map { key, value in return(Social(key: key, value: value))} ?? [Social]()
            joinedClubs = campusID.clubs?.filter{$0.value == true}.keys.map{$0} ?? [String]()
            fetchCourses(emailID: campusID.id, completion: { courseData in
                courses = courseData?.values.map({$0}).sorted(by: {$0.num < $1.num}) ?? courses.sorted(by: {$0.num < $1.num})
            })
            //checks whether current user hides classes or not before showing others' classes
            if let googleUser = GIDSignIn.sharedInstance.currentUser {
                currentUserID = cleanFirebaseKey(input: googleUser.profile?.email ?? "NilEmail")
                fetchCurrentUser(emailID: googleUser.profile?.email ?? "NilEmail", completion: { currentUser in
                    if let currentUserWrapped = currentUser {
                        showClasses = !(currentUserWrapped.privacy?["hideClasses"] ?? true)
                    }
                })
            }
        }
    }
}
