//
//  ClubsViewModel.swift
//  CPS Campus (iOS)
//
//  6/9/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import DynamicColor

struct ClubMeetingRow: View {
    @FetchRequest(entity: Following.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Following.type, ascending: true)], predicate: NSPredicate(format: "type == %@", "club"))
    var following: FetchedResults<Following>
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    let meeting: ClubMeeting
    let club: Club
    @Binding var filter: String
    @Binding var clubMeetingDetails: [ClubMeeting]
    let meetings: [ClubMeeting]
    
    @Binding var selection: String?
    
    #if os(iOS)
    @Environment(\.verticalSizeClass) var vSizeClass
    @Environment(\.horizontalSizeClass) var hSizeClass
    #endif
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    selection = club.name
                }, label: {
                    if meeting.title.lowercased().contains("bake sale") {
                        WebImage(url: URL(string: "https://i.postimg.cc/Nfy7cBcV/Bake-Sale.png"))
                            .resizable()
                            .placeholder(content: {
                                Circle().foregroundColor(Color(hexString: club.color))
                            })
                            .scaledToFit()
                            .clipShape(Circle())
                            .saturation(1.1)
                            .frame(width: 55, height: 55, alignment: .center)
                    } else {
                        WebImage(url: URL(string: club.image))
                            .resizable()
                            .placeholder(content: {
                                Circle().foregroundColor(Color(hexString: club.color))
                            })
                            .scaledToFit()
                            .clipShape(Circle())
                            .saturation(1.1)
                            .frame(width: 55, height: 55, alignment: .center)
                    }
                })
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(club.name == "")
                VStack(alignment: .leading, spacing: 3.5) {
                    Text(meeting.title)
                        .foregroundColor(Color("SystemContrast"))
                        .fontWeight(.semibold)
                        .dynamicTypeSize(.small ... .large)
                        .multilineTextAlignment(.leading)
                    if "\(convertDatetoString(date: meeting.startDate, format: "h:mm")) - \(convertDatetoString(date: meeting.endDate, format: "h:mm"))" == "12:00 - 12:00" {
                        Text("all-day")
                            .foregroundColor(Color("SystemContrast"))
                            .dynamicTypeSize(.small ... .large)
                    } else {
                        Text("\(convertDatetoString(date: meeting.startDate, format: "h:mm")) - \(convertDatetoString(date: meeting.endDate, format: "h:mm"))")
                            .foregroundColor(Color("SystemContrast"))
                            .dynamicTypeSize(.small ... .large)
                    }
                }
                Spacer()
                HStack {
                    if clubMeetingDetails.contains(meeting) == false {
                        if meeting.location != "" && !meeting.title.lowercased().contains("bake sale") {
                            Button(action: {
                                withAnimation(Animation.easeInOut(duration: 0.25)) {
                                    if clubMeetingDetails.contains(meeting) {
                                        clubMeetingDetails.removeAll(where: {$0 == meeting})
                                    } else {
                                        clubMeetingDetails.append(meeting)
                                    }
                                }
                                let impactMed = UIImpactFeedbackGenerator(style: .light)
                                impactMed.impactOccurred()
                            }, label: {
                                Image(systemName: "building.2")
                                    .foregroundColor(Color("SystemContrast2"))
                                    .font(.title2)
                                    .dynamicTypeSize(.small ... .large)
                            })
                            .buttonStyle(.plain)
                        }
                    }
                    if !meeting.title.lowercased().contains("bake sale") {
                        Button(action: {
                            withAnimation(Animation.easeInOut(duration: 0.25)) {
                                if clubMeetingDetails.contains(meeting) {
                                    clubMeetingDetails.removeAll(where: {$0 == meeting})
                                } else {
                                    clubMeetingDetails.append(meeting)
                                }
                            }
#if os(iOS)
                            let impactMed = UIImpactFeedbackGenerator(style: .light)
                            impactMed.impactOccurred()
#endif
                        }, label: {
                            if meeting.title.lowercased().contains("bake sale") {
                                if clubMeetingDetails.contains(meeting) {
                                    Image(systemName: "chevron.down.circle")
                                        .font(.title2)
                                        .dynamicTypeSize(.small ... .large)
                                        .foregroundColor(Color("AccentColor"))
                                } else {
                                    Image(systemName: "chevron.right.circle")
                                        .font(.title2)
                                        .dynamicTypeSize(.small ... .large)
                                        .foregroundColor(Color("AccentColor"))
                                }
                            } else {
                                if clubMeetingDetails.contains(meeting) {
                                    Image(systemName: "chevron.down.circle")
                                        .font(.title2)
                                        .dynamicTypeSize(.small ... .large)
                                        .foregroundColor(colorScheme == .light && UIColor(hexString: club.color).luminance > 0.5 ? Color(UIColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                                } else {
                                    Image(systemName: "chevron.right.circle")
                                        .font(.title2)
                                        .dynamicTypeSize(.small ... .large)
                                        .foregroundColor(colorScheme == .light && UIColor(hexString: club.color).luminance > 0.5 ? Color(UIColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                                }
                            }
                        })
                        .buttonStyle(.plain)
                    }
                }
            }
            if clubMeetingDetails.contains(meeting) {
                HStack {
                    if meeting.details != "" {
                        Text(cleanDescription(input: meeting.details).trimmingCharacters(in: .whitespacesAndNewlines))
                            .dynamicTypeSize(.small ... .large)
                    }
                    Spacer()
                }.padding(.bottom, 5)
                HStack {
                    if meeting.location != "" && !meeting.title.lowercased().contains("bake sale") {
                        Tag(color: Color(hexString: club.color), name: meeting.location, highlight: false, color2: Color(hexString: club.color).opacity(0.25))
                    }
                    if !meeting.title.lowercased().contains("bake sale") {
                        Button(action: {
                            if filter == "" {
                                filter = club.category
                            } else {
                                filter = ""
                            }
#if os(iOS)
                            let impactMed = UIImpactFeedbackGenerator(style: .light)
                            impactMed.impactOccurred()
#endif
                        }, label: {
                            if filter != "" {
                                Tag(color: Color(hexString: club.color), name: "#\(club.category)", highlight: true, color2: Color(hexString: club.color).opacity(0.25))
                            } else {
                                Tag(color: Color(hexString: club.color), name: "#\(club.category)", highlight: false, color2: Color(hexString: club.color).opacity(0.25))
                            }
                        })
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundColor(Color("SystemGray6")))
        .contextMenu(ContextMenu(menuItems: {
            if meeting.location != "" && !meeting.title.lowercased().contains("bake sale") {
                Label(meeting.location, systemImage: "building.2")
            }
            if extractURLS(input: meeting.details).removingDuplicates() != [] {
                ForEach(extractURLS(input: meeting.details).removingDuplicates(), id: \.self) { url in
                    Link(destination: url) {
                        Label(url.host ?? "Link", systemImage: "link")
                    }
                }
            }
            Divider()
            if club.name != "" {
                Button(action: {
                    withAnimation {
                        selection = club.name
                    }
                }, label: {
                    Label("Club Info", systemImage: "info.circle")
                })
                Button(action: {
                    withAnimation {
                        if following.filter({ $0.id == club.name}).isEmpty == false {
                            viewContext.deleteFollowing(following.filter({ $0.id == club.name}))
                            selection = ""
                        } else {
                            Following.create(type: "club", id: club.name, context: viewContext)
                            selection = club.name
                        }
                    }
                }, label: {
                    if following.first(where: {$0.id == club.name}) != nil {
                        Label("Unfollow Club", systemImage: "star.slash")
                    } else {
                        Label("Follow Club", systemImage: "star")
                    }
                })
            }
        }))
    }
}

struct ClubMeetingRowPage: View {
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    let meeting: ClubMeeting
    let club: Club
    @State var showMore = false
    
    var body: some View {
        VStack {
            HStack {
                if meeting.title.lowercased().contains("bake sale") {
                    WebImage(url: URL(string: "https://i.postimg.cc/Nfy7cBcV/Bake-Sale.png"))
                        .resizable()
                        .placeholder(content: {
                            Circle().foregroundColor(Color(hexString: club.color))
                        })
                        .scaledToFit()
                        .clipShape(Circle())
                        .saturation(1.1)
                        .frame(width: 55, height: 55, alignment: .center)
                } else {
                    WebImage(url: URL(string: club.image))
                        .resizable()
                        .placeholder(content: {
                            Circle().foregroundColor(Color(hexString: club.color))
                        })
                        .scaledToFit()
                        .clipShape(Circle())
                        .saturation(1.1)
                        .frame(width: 55, height: 55, alignment: .center)
                }
                VStack(alignment: .leading, spacing: 3.5) {
                    Text(meeting.title)
                        .foregroundColor(Color("SystemContrast"))
                        .fontWeight(.semibold)
                        .dynamicTypeSize(.small ... .large)
                        .multilineTextAlignment(.leading)
                    if "\(convertDatetoString(date: meeting.startDate, format: "h:mm")) - \(convertDatetoString(date: meeting.endDate, format: "h:mm"))" == "12:00 - 12:00" {
                        Text("\(convertDatetoString(date: meeting.startDate, format: "M/d")) all-day")
                            .foregroundColor(Color("SystemContrast"))
                            .dynamicTypeSize(.small ... .large)
                    } else {
                        Text("\(convertDatetoString(date: meeting.startDate, format: "M/d")) \(convertDatetoString(date: meeting.startDate, format: "h:mm")) - \(convertDatetoString(date: meeting.endDate, format: "h:mm"))")
                            .foregroundColor(Color("SystemContrast"))
                            .dynamicTypeSize(.small ... .large)
                    }
                }
                Spacer()
                if meeting.location != "" || meeting.details != "" {
                    HStack {
                        if showMore == false {
                            if meeting.location != "" && !meeting.title.lowercased().contains("bake sale") {
                                Button(action: {
                                    withAnimation(Animation.easeInOut(duration: 0.25)) {
                                        showMore.toggle()
                                    }
                                    let impactMed = UIImpactFeedbackGenerator(style: .light)
                                    impactMed.impactOccurred()
                                }, label: {
                                    Image(systemName: "building.2")
                                        .foregroundColor(Color("SystemContrast2"))
                                        .font(.title2)
                                        .dynamicTypeSize(.small ... .large)
                                })
                                .buttonStyle(.plain)
                            }
                        }
                        Button(action: {
                            withAnimation(Animation.easeInOut(duration: 0.25)) {
                                showMore.toggle()
                            }
                            let impactMed = UIImpactFeedbackGenerator(style: .light)
                            impactMed.impactOccurred()
                        }, label: {
                            if meeting.title.lowercased().contains("bake sale") {
                                if showMore {
                                    Image(systemName: "chevron.down.circle")
                                        .font(.title2)
                                        .dynamicTypeSize(.small ... .large)
                                        .foregroundColor(Color("AccentColor"))
                                } else {
                                    Image(systemName: "chevron.right.circle")
                                        .font(.title2)
                                        .dynamicTypeSize(.small ... .large)
                                        .foregroundColor(Color("AccentColor"))
                                }
                            } else {
                                if showMore {
                                    Image(systemName: "chevron.down.circle")
                                        .font(.title2)
                                        .dynamicTypeSize(.small ... .large)
                                        .foregroundColor(colorScheme == .light && UIColor(hexString: club.color).luminance > 0.5 ? Color(UIColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                                } else {
                                    Image(systemName: "chevron.right.circle")
                                        .font(.title2)
                                        .dynamicTypeSize(.small ... .large)
                                        .foregroundColor(colorScheme == .light && UIColor(hexString: club.color).luminance > 0.5 ? Color(UIColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                                }
                            }
                        })
                        .buttonStyle(.plain)
                    }
                }
            }
            if showMore {
                if meeting.details != "" {
                    HStack {
                        if meeting.details != "" {
                            Text(cleanDescription(input: meeting.details).trimmingCharacters(in: .whitespacesAndNewlines))
//                                .foregroundColor(.gray)
                                .dynamicTypeSize(.small ... .large)
                        }
                        Spacer()
                    }.padding(.bottom, 5)
                }
                if meeting.location != "" && !meeting.title.lowercased().contains("bake sale") {
                    HStack {
                        if meeting.location != "" {
                            Tag(color: Color(hexString: club.color), name: meeting.location, highlight: false, color2: Color(hexString: club.color).opacity(0.25))
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundColor(Color("SystemGray6")))
        .contextMenu(ContextMenu(menuItems: {
            if meeting.location != "" && !meeting.title.lowercased().contains("bake sale") {
                Label(meeting.location, systemImage: "building.2")
            }
            if extractURLS(input: meeting.details).removingDuplicates() != [] {
                ForEach(extractURLS(input: meeting.details).removingDuplicates(), id: \.self) { url in
                    Link(destination: url) {
                        Label(url.host ?? "Link", systemImage: "link")
                    }
                }
            }
        }))
    }
}

struct ClubMeetingRowHome: View {
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    let meeting: ClubMeeting
    let club: Club
    @State var showMore = false
    
    var body: some View {
        VStack {
            HStack {
                if meeting.title.lowercased().contains("bake sale") {
                    WebImage(url: URL(string: "https://i.postimg.cc/Nfy7cBcV/Bake-Sale.png"))
                        .resizable()
                        .placeholder(content: {
                            Circle().foregroundColor(Color(hexString: club.color))
                        })
                        .scaledToFit()
                        .clipShape(Circle())
                        .saturation(1.1)
                        .frame(width: 55, height: 55, alignment: .center)
                } else {
                    WebImage(url: URL(string: club.image))
                        .resizable()
                        .placeholder(content: {
                            Circle().foregroundColor(Color(hexString: club.color))
                        })
                        .scaledToFit()
                        .clipShape(Circle())
                        .saturation(1.1)
                        .frame(width: 55, height: 55, alignment: .center)
                }
                VStack(alignment: .leading, spacing: 3.5) {
                    Text(meeting.title)
                        .foregroundColor(Color("SystemContrast"))
                        .fontWeight(.semibold)
                        .dynamicTypeSize(.small ... .large)
                        .multilineTextAlignment(.leading)
                    if "\(convertDatetoString(date: meeting.startDate, format: "h:mm")) - \(convertDatetoString(date: meeting.endDate, format: "h:mm"))" == "12:00 - 12:00" {
                        Text("\(convertDatetoString(date: meeting.startDate, format: "M/d")) all-day")
                            .foregroundColor(Color("SystemContrast"))
                            .dynamicTypeSize(.small ... .large)
                    } else {
                        Text("\(convertDatetoString(date: meeting.startDate, format: "M/d")) \(convertDatetoString(date: meeting.startDate, format: "h:mm")) - \(convertDatetoString(date: meeting.endDate, format: "h:mm"))")
                            .foregroundColor(Color("SystemContrast"))
                            .dynamicTypeSize(.small ... .large)
                    }
                }
                Spacer()
                if meeting.location != "" || meeting.details != "" {
                    HStack {
                        if showMore == false {
                            if meeting.location != "" && !meeting.title.lowercased().contains("bake sale") {
                                Button(action: {
                                    withAnimation(Animation.easeInOut(duration: 0.25)) {
                                        showMore.toggle()
                                    }
                                    let impactMed = UIImpactFeedbackGenerator(style: .light)
                                    impactMed.impactOccurred()
                                }, label: {
                                    Image(systemName: "building.2")
                                        .foregroundColor(Color("SystemContrast2"))
                                        .font(.title2)
                                        .dynamicTypeSize(.small ... .large)
                                })
                                .buttonStyle(.plain)
                            }
                        }
                        Button(action: {
                            withAnimation(Animation.easeInOut(duration: 0.25)) {
                                showMore.toggle()
                            }
                            let impactMed = UIImpactFeedbackGenerator(style: .light)
                            impactMed.impactOccurred()
                        }, label: {
                            if meeting.title.lowercased().contains("bake sale") {
                                if showMore {
                                    Image(systemName: "chevron.down.circle")
                                        .font(.title2)
                                        .dynamicTypeSize(.small ... .large)
                                        .foregroundColor(Color("AccentColor"))
                                } else {
                                    Image(systemName: "chevron.right.circle")
                                        .font(.title2)
                                        .dynamicTypeSize(.small ... .large)
                                        .foregroundColor(Color("AccentColor"))
                                }
                            } else {
                                if showMore {
                                    Image(systemName: "chevron.down.circle")
                                        .font(.title2)
                                        .dynamicTypeSize(.small ... .large)
                                        .foregroundColor(colorScheme == .light && UIColor(hexString: club.color).luminance > 0.5 ? Color(UIColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                                } else {
                                    Image(systemName: "chevron.right.circle")
                                        .font(.title2)
                                        .dynamicTypeSize(.small ... .large)
                                        .foregroundColor(colorScheme == .light && UIColor(hexString: club.color).luminance > 0.5 ? Color(UIColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                                }
                            }
                        })
                            .buttonStyle(.plain)
                    }
                }
            }
            if showMore {
                if meeting.details != "" {
                    HStack {
                        if meeting.details != "" {
                            Text(cleanDescription(input: meeting.details).trimmingCharacters(in: .whitespacesAndNewlines))
                                .dynamicTypeSize(.small ... .large)
                        }
                        Spacer()
                    }.padding(.bottom, 5)
                }
                if meeting.location != "" && !meeting.title.lowercased().contains("bake sale") {
                    HStack {
                        if meeting.location != "" {
                            Tag(color: Color(hexString: club.color), name: meeting.location, highlight: false, color2: Color(hexString: club.color).opacity(0.25))
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundColor(Color("SystemGray6")))
        .contextMenu(ContextMenu(menuItems: {
            if meeting.location != "" && !meeting.title.lowercased().contains("bake sale") {
                Label(meeting.location, systemImage: "building.2")
            }
            if extractURLS(input: meeting.details).removingDuplicates() != [] {
                ForEach(extractURLS(input: meeting.details).removingDuplicates(), id: \.self) { url in
                    Link(destination: url) {
                        Label(url.host ?? "Link", systemImage: "link")
                    }
                }
            }
        }))
    }
}

struct FollowedClubIcon: View {
    
    @FetchRequest(entity: Following.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Following.type, ascending: true)], predicate: NSPredicate(format: "type == %@", "club"))
    var following: FetchedResults<Following>
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    let club: Club
    let meetings: [ClubMeeting]
    
    @Binding var selection: String?
    let followed: Bool
    @Binding var search: String
    
    var body: some View {
        Button(action: {
            search = ""
            if selection == club.name {
                selection = ""
            } else {
                selection = club.name
            }
        }, label: {
            VStack(alignment: .center) {
                WebImage(url: URL(string: "\(club.image.replacingOccurrences(of: "file/d/", with: "uc?id=").replacingOccurrences(of: "/view?usp=sharing", with: ""))"))
                    .resizable()
                    .placeholder(content: {
                        Circle().foregroundColor(Color(hexString: club.color))
                    })
                    .scaledToFit()
                    .clipShape(Circle())
                    .saturation(1.1)
                    .frame(width: 80, height: 80, alignment: .center)
                    .padding(3)
                    .overlay(selection == club.name ?
                             Circle().stroke(colorScheme == .light && UIColor(hexString: club.color).luminance > 0.5 ? Color(UIColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color), lineWidth: 3)
                             : Circle().stroke(.clear, lineWidth: 3)
                    )
                VStack {
                    Text(club.nickname != "" ? club.nickname : club.name)
                        .fontWeight(.medium)
                        .font(.system(size: 13))
                        .foregroundColor(selection == club.name ? Color("SystemContrast") : Color("SystemContrast2"))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(1)
                    Spacer()
                }.frame(width: 80)
            }
            .padding(5)
        }).buttonStyle(ScaleButtonStyle())
    }
}

struct AddClubButton: View {
    
    @Binding var selection: String?
    
    var body: some View {
        Button(action: {
            if selection == "Add Club" {
                selection = ""
            } else {
                selection = "Add Club"
            }
        }, label: {
            VStack {
                Image(systemName: "plus")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 37.5, weight: .semibold))
                    .background(Circle().foregroundColor(.accentColor.opacity(0.25)).frame(width: 80, height: 80, alignment: .center))
                    .frame(width: 80, height: 80, alignment: .center)
                    .padding(3)
                    .overlay(selection == "Add Club" ?
                             Circle().stroke(Color("AccentColor"), lineWidth: 3)
                             : Circle().stroke(.clear, lineWidth: 3)
                    )
                VStack {
                    Text("Add Club")
                        .fontWeight(.medium)
                        .font(.system(size: 13))
                        .foregroundColor(Color("AccentColor"))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(1)
                    Spacer()
                }.frame(width: 80)
            }
            .padding(5)
        })
        .buttonStyle(ScaleButtonStyle())
    }
}

struct AddClubRow: View {
    
    @FetchRequest(entity: Following.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Following.type, ascending: true)], predicate: NSPredicate(format: "type == %@", "club"))
    var following: FetchedResults<Following>
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    let club: Club
    
    @Binding var selection: String?
    @Binding var search: String
    
    var body: some View {
        Button(action: {
            search = ""
            selection = club.name
        }, label: {
            VStack {
                HStack {
                    WebImage(url: URL(string: "\(club.image.replacingOccurrences(of: "file/d/", with: "uc?id=").replacingOccurrences(of: "/view?usp=sharing", with: ""))"))
                        .resizable()
                        .placeholder(content: {
                            Circle().foregroundColor(Color(hexString: club.color))
                        })
                        .scaledToFit()
                        .clipShape(Circle())
                        .saturation(1.1)
                        .frame(width: 55, height: 55, alignment: .center)
                    VStack(alignment: .leading) {
                        Text(club.name)
                            .fontWeight(.semibold)
                            .dynamicTypeSize(.small ... .large)
                            .foregroundColor(Color("SystemContrast"))
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Button(action: {
                        search = ""
                        if following.filter({ $0.id == club.name}).isEmpty == false {
                            viewContext.deleteFollowing(following.filter({ $0.id == club.name}))
                            selection = ""
                        } else {
                            Following.create(type: "club", id: club.name, context: viewContext)
                            selection = club.name
                        }
                        let impactMed = UIImpactFeedbackGenerator(style: .light)
                        impactMed.impactOccurred()
                    }, label: {
                        if following.first(where: {$0.id == club.name}) != nil {
                            Image(systemName: "star.fill")
                                .font(.title2)
                                .dynamicTypeSize(.small ... .large)
                                .foregroundColor(colorScheme == .light && UIColor(hexString: club.color).luminance > 0.5 ? Color(UIColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                        } else {
                            Image(systemName: "star")
                                .font(.title2)
                                .dynamicTypeSize(.small ... .large)
                                .foregroundColor(colorScheme == .light && UIColor(hexString: club.color).luminance > 0.5 ? Color(UIColor(hexString: club.color).shaded(amount: 0.15).saturated(amount: 0.15)) : Color(hexString: club.color))
                        }
                    })
                        .buttonStyle(.plain)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundColor(Color("SystemGray6")))
        })
    }
}

struct Tag: View {
    let color: Color
    let name: String
    let highlight: Bool
    let color2: Color
    
    var body: some View {
        HStack {
            Text(name)
                .fontWeight(.semibold)
                .foregroundColor(highlight ? Color(.white) : Color("SystemContrast"))
                .font(.system(size: 13))
                .lineLimit(1)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).foregroundColor(highlight ? color : color2))
    }
}
