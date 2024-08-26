//
//  DirectoryView.swift
//  CPS Campus (macOS)
//
//  6/17/2023
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import GoogleSignIn
import AppKit

struct DirectoryViewmacOS: View {
    let clubs: [Club]
    
    //MARK: Environment
    @State var users = [User]()
    @State var search: String = ""
    @State var gradFilter = [seniorClass, juniorClass, sophClass, freshClass].joined(separator: ",")+",Faculty"
    @State var groupBy = "first"
    
    let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W", "X","Y", "Z"]
    
    var body: some View {
        VStack {
            List {
                if search == "" {
                    VStack {
                        HStack {
                            Text("Show").font(.system(size: 15))
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
                            .frame(maxWidth: 200)
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                        HStack {
                            Text("Group by").font(.system(size: 15))
                            Spacer()
                            Picker(groupBy, selection: $groupBy) {
                                Text("First Name").tag("first")
                                Text("Last Name").tag("last")
                            }
                            .frame(maxWidth: 200)
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                    }.borderedCellStyle()
                    ForEach(alphabet, id: \.self) { letter in
                        Section(header: Text(letter).bold()) {
                            ForEach(users.filter{ if $0.name.components(separatedBy: " ").count > 1 && groupBy == "last" { return $0.name.components(separatedBy: " ")[1].starts(with: letter) } else { return $0.name.starts(with: letter) }}.filter{ gradFilter.contains($0.gradYear) }.sorted(by: {if $0.name.components(separatedBy: " ").count > 1 && $1.name.components(separatedBy: " ").count > 1 { return $0.name.components(separatedBy: " ")[1] < $1.name.components(separatedBy: " ")[1]} else { return false }})) { user in
                                Button(action: {
                                    DirectorySubview(campusID: user, clubs: clubs).openInWindow(title: user.name, isClear: false, sender: self)
                                }, label: {
                                    HStack(spacing: 15) {
                                        if user.privacy?["hideProfilePicture"] ?? false == true || user.imageLink.isEmpty {
                                            Color("SystemGray3")
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
                                    }.borderedCellStyle()
                                }).buttonStyle(ScaleButtonStyle())
                            }
                        }
                    }
                } else {
                    ForEach(users.filter{$0.name.lowercased().starts(with: search.lowercased())}.sorted(by: {if $0.name.components(separatedBy: " ").count > 1 && $1.name.components(separatedBy: " ").count > 1 { return $0.name.components(separatedBy: " ")[1] < $1.name.components(separatedBy: " ")[1]} else { return false }})) { user in
                        Button(action: {
                            DirectorySubview(campusID: user, clubs: clubs).openInWindow(title: user.name, isClear: false, sender: self)
                        }, label: {
                            HStack(spacing: 15) {
                                if user.privacy?["hideProfilePicture"] ?? false == true || user.imageLink.isEmpty {
                                    Color("SystemGray3")
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
                            }.borderedCellStyle()
                        }).buttonStyle(ScaleButtonStyle())
                    }
                    ForEach(users.filter{ if $0.name.components(separatedBy: " ").count > 1 { return $0.name.components(separatedBy: " ")[1].lowercased().starts(with: search.lowercased()) } else { return false }}.sorted(by: {if $0.name.components(separatedBy: " ").count > 1 && $1.name.components(separatedBy: " ").count > 1 { return $0.name.components(separatedBy: " ")[1] < $1.name.components(separatedBy: " ")[1]} else { return false }})) { user in
                        Button(action: {
                            DirectorySubview(campusID: user, clubs: clubs).openInWindow(title: user.name, isClear: false, sender: self)
                        }, label: {
                            HStack(spacing: 15) {
                                if user.privacy?["hideProfilePicture"] ?? false == true || user.imageLink.isEmpty {
                                    Color("SystemGray3")
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
                            }.borderedCellStyle()
                        }).buttonStyle(ScaleButtonStyle())
                    }
                }
            }
        }
        .navigationTitle("Directory")
        .searchable(text: $search, prompt: "Search for students and faculty")
        .disableAutocorrection(true)
        .onAppear {
            fetchAllUsers(completion: { allUsers in
                users = allUsers
            })
        }
    }
}

struct DirectorySubview: View {
    let campusID: User
    let clubs: [Club]
    
    @AppStorage("GraduationYear", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var gradYear = ""
    
    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) var presentationMode
    
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
        ScrollView(showsIndicators: false) {
            VStack {
                if campusID.id == currentUserID {
                    HStack {
                        Image(systemName: "eye.fill")
                            .foregroundStyle(Color("AccentColor"))
                            .font(.system(size: 20))
                            .frame(width: 25, height: 25)
                            .padding(.trailing, 5)
                        Text("You're seeing a preview of what others see on your directory page")
                            .font(.system(size: 15))
                        Spacer()
                    }.tintedCellStyle(color: .accentColor)
                        .padding(.bottom)
                }
                VStack {
                    HStack {
                        Text("PROFILE").fontWeight(.medium).foregroundStyle(.gray)
                        Spacer()
                    }.padding(.leading)
                    VStack(spacing: 0) {
                        HStack(spacing: 15) {
                            if campusID.privacy?["hideProfilePicture"] ?? false == true || campusID.imageLink.isEmpty {
                                Color("SystemGray3")
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
                                        .foregroundStyle(Color("SystemContrast"))
                                        .font(.system(size: 18))
                                    Spacer()
                                }
                                HStack {
                                    Text("[\(campusID.id)@college-prep.org](mailto:\(campusID.id)@college-prep.org)".markdownToAttributed())
                                        .tint(.accentColor)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .font(.system(size: 15))
                                    Spacer()
                                }
                            }
                        }
                        .padding(.bottom)
                        Divider()
                        HStack {
                            Text("Graduation Year")
                                .font(.system(size: 15))
                            Spacer()
                            Text(campusID.gradYear)
                                .font(.system(size: 15))
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(.vertical)
                        Divider()
                        if let pronouns = campusID.pronouns {
                            if !pronouns.isEmpty {
                                HStack {
                                    Text("Pronouns")
                                        .font(.system(size: 15))
                                    Spacer()
                                    Text(pronouns)
                                        .font(.system(size: 15))
                                        .multilineTextAlignment(.trailing)
                                }.padding(.top)
                            }
                        }
                    }.borderedCellStyle()
                        .padding(.bottom)
                }
                if !socials.isEmpty && gradYear != "Faculty" {
                    VStack {
                        HStack {
                            Text("SOCIALS").fontWeight(.medium).foregroundStyle(.gray)
                            Spacer()
                        }.padding(.leading)
                        VStack(spacing: 0) {
                            ForEach(socials.filter {$0.value != ""}.sorted(by: {$1.key == "Phone" ? false : $0.key == "Phone" ? true : $0.key < $1.key}), id: \.key) { social in
                                HStack {
                                    Text(social.key)
                                        .font(.system(size: 15))
                                    Spacer()
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
                                            let pasteboard = NSPasteboard.general
                                            pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
                                            pasteboard.setString(social.value, forType: NSPasteboard.PasteboardType.string)
                                        }, label: {
                                            Label("Copy", systemImage: "doc.on.doc")
                                        })
                                    } label: {
                                        if social.key == "Phone" {
                                            Text(format(phoneNumber: social.value) ?? social.value)
                                                .foregroundStyle(Color("AccentColor"))
                                                .multilineTextAlignment(.trailing)
                                        } else {
                                            Text(social.value)
                                                .foregroundStyle(Color("AccentColor"))
                                                .multilineTextAlignment(.trailing)
                                        }
                                    }
                                    .frame(maxWidth: 200)
                                }
                            }
                        }.borderedCellStyle()
                        HStack {
                            Text("Socials are visible only to other students, never faculty.").foregroundStyle(.gray)
                            Spacer()
                        }.padding([.leading, .bottom])
                    }
                }
                if !courses.isEmpty && (campusID.privacy?["hideClasses"] ?? true == false) {
                    VStack {
                        HStack {
                            Text("CLASSES").fontWeight(.medium).foregroundStyle(.gray)
                            Spacer()
                        }.padding(.leading)
                        if showClasses {
                            LazyVGrid(columns: columns2, spacing: 10) {
                                ForEach(courses.filter{coursesGroup.contains($0.id) || ($0.id == "Compass" && [juniorClass, sophClass].contains(campusID.gradYear))}.sorted(by: {$0.num < $1.num})) { course in
                                    HStack {
                                        if course.id == "Compass" {
                                            HStack(spacing: 0) {
                                                Image(systemName: "\(String(course.compassBlock.prefix(1))).square.fill".lowercased())
                                                    .font(.system(size: 20))
                                                    .foregroundStyle(Color(hexString: course.color))
                                                Image(systemName: "\(String(course.visibleRotations)).square.fill".lowercased())
                                                    .font(.system(size: 20))
                                                    .foregroundStyle(Color(hexString: course.color))
                                            }
                                            Text(course.name)
                                                .font(.system(size: 15))
                                                .fontWeight(.medium)
                                        } else {
                                            HStack(spacing: 0) {
                                                Image(systemName: "\(String(course.id.prefix(1))).square.fill".lowercased())
                                                    .font(.system(size: 20))
                                                    .foregroundStyle(course.isFreePeriod ? .gray : Color(hexString: course.color))
                                                if course.visibleRotations != 0 {
                                                    Image(systemName: "\(String(course.visibleRotations)).square.fill".lowercased())
                                                        .font(.system(size: 20))
                                                        .foregroundStyle(Color(hexString: course.color))
                                                }
                                            }
                                            Text(course.isFreePeriod ? "Free Period" : course.name)
                                                .font(.system(size: 15))
                                                .fontWeight(.medium)
                                        }
                                        Spacer()
                                    }
                                }
                            }.borderedCellStyle()
                                .padding(.bottom)
                        } else {
                            HStack {
                                Image(systemName: "hand.raised.fill")
                                    .foregroundStyle(.blue)
                                    .font(.system(size: 20))
                                    .frame(width: 25, height: 25)
                                    .padding(.trailing, 5)
                                Text("You cannot see another's classes when you are currently hiding yours.")
                                    .font(.system(size: 15))
                                Spacer()
                                Button(action: {
                                    openURL(URL(string: "cpscampus://settings/campusID")!)
                                }, label: {
                                    Text("Edit Privacy Settings")
                                })
                            }.tintedCellStyle(color: .blue)
                                .padding(.bottom)
                        }
                    }
                }
                if !joinedClubs.isEmpty {
                    VStack {
                        HStack {
                            Text("CLUBS").fontWeight(.medium).foregroundStyle(.gray)
                            Spacer()
                        }.padding(.leading)
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
                                            .font(.system(size: 15))
                                            .fontWeight(.medium)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                }
                            }
                        }.borderedCellStyle()
                        HStack {
                            Text("Anonymously-followed affinity spaces are never visible above, but visible to the leaders of those clubs.").foregroundStyle(.gray)
                            Spacer()
                        }.padding([.leading, .bottom])
                    }
                }
            }
            .padding()
        }
        .navigationTitle(campusID.name)
        .background(Color("SystemWindow"))
        .frame(minWidth: 500, minHeight: 600)
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
