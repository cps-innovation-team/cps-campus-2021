//
//  HomeViewModel.swift
//  CPS Campus (Shared)
//
//  12/28/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI

#if os(iOS)
struct HomeViewConfigure: View {
    
    @AppStorage("ForYouPage", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var arrangement: [ForYouItem] = defaultForYouPage
    @AppStorage("QuickLinks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var quickLinks: [QuickLink] = defaultQuickLinks
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(footer: Text("**The For You page intelligently curates information you might need throughout the day. On Friday, your Common Classroom details will automatically be displayed.**")) { }
                Section(header: Text("**For You Page**")) {
                    HStack {
                        Image(systemName: "rectangle.inset.filled.and.person.filled")
                            .foregroundStyle(Color("SystemContrast"))
                            .symbolRenderingMode(.hierarchical)
                            .frame(width: 35)
                        Text("Common Classroom")
                        Spacer()
                    }
                    ForEach($arrangement, id: \.self) { $item in
                        HStack {
                            if item.id == "RHF" {
                                Image(item.icon)
                                    .foregroundStyle(Color("SystemContrast"))
                                    .symbolRenderingMode(.hierarchical)
                                    .frame(width: 35)
                            } else {
                                Image(systemName: item.icon)
                                    .foregroundStyle(Color("SystemContrast"))
                                    .symbolRenderingMode(.hierarchical)
                                    .frame(width: 35)
                            }
                            Text(item.id)
                            Spacer()
                            Toggle("", isOn: $item.visible)
                                .labelsHidden()
                        }
                        .padding(.horizontal)
                        .listRowInsets(EdgeInsets())
                    }
                    .onMove(perform: move)
                }
                Section(header: Text("**QuickLinks**")) {
                    ForEach($quickLinks, id: \.self) { $item in
                        HStack {
                            Image(systemName: item.icon)
                                .foregroundStyle(Color("SystemContrast"))
                                .frame(width: 35)
                            Text(item.name)
                            Spacer()
                            Toggle("", isOn: $item.visible)
                                .labelsHidden()
                        }
                        .padding(.horizontal)
                        .listRowInsets(EdgeInsets())
                    }
                    .onMove(perform: moveQuickLink)
                }
            }
            .listStyle(.insetGrouped)
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Customize")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            arrangement = defaultForYouPage
                            quickLinks = defaultQuickLinks
                        }
                    }, label: {
                        Text("Reset")
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Done").bold()
                    })
                }
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        arrangement.move(fromOffsets: source, toOffset: destination)
    }
    
    func moveQuickLink(from source: IndexSet, to destination: Int) {
        quickLinks.move(fromOffsets: source, toOffset: destination)
    }
}

struct TopCell: View {
    let name: String
    let symbol: String
    
    var body: some View {
        HStack {
            if name == "RHF" {
                Image(symbol)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color("AccentColor"))
                    .symbolRenderingMode(.hierarchical)
            } else {
                Image(systemName: symbol)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color("AccentColor"))
                    .symbolRenderingMode(.hierarchical)
            }
            Text(name)
                .fontWeight(.semibold)
                .textCase(.uppercase)
                .foregroundStyle(Color("SystemContrast"))
                .minimumScaleFactor(0.5)
        }
        .frame(height: 25)
        .padding(12.5)
        .background(RoundedRectangle(cornerRadius: 12.5, style: .continuous).foregroundStyle(Color(.systemGray6)))
        .dynamicTypeSize(.small ... .xLarge)
    }
}
#endif

#if os(macOS)
struct HomeViewConfigure: View {
    
    @AppStorage("ForYouPage", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var arrangement: [ForYouItem] = defaultForYouPage
    @AppStorage("QuickLinks", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var quickLinks: [QuickLink] = defaultQuickLinks
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            Text("**The For You page intelligently curates information you might need throughout the day. On Friday, your Common Classroom details will automatically be displayed.**")
                .font(.caption)
                .foregroundStyle(Color("SystemContrast2"))
                .lineLimit(4)
            Section(header: Text("For You Page")) {
                HStack(spacing: 0) {
                    Image(systemName: "rectangle.inset.filled.and.person.filled")
                        .foregroundStyle(Color("SystemContrast2"))
                        .symbolRenderingMode(.hierarchical)
                        .frame(width: 35)
                    Text("Common Classroom").fontWeight(.medium).foregroundStyle(Color("SystemContrast2"))
                    Spacer()
                }.padding(.leading, -10)
                ForEach(arrangement, id: \.self) { item in
                    HStack(spacing: 0) {
                        Toggler(arrangement: $arrangement, item: item, visible: item.visible)
                        if item.id == "RHF" {
                            Image(item.icon)
                                .font(.body.weight(.bold))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(Color("SystemContrast2"))
                                .frame(width: 35)
                        } else {
                            Image(systemName: item.icon)
                                .font(.body.weight(.bold))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(Color("SystemContrast2"))
                                .frame(width: 35)
                        }
                        Text(item.id).fontWeight(.medium).foregroundStyle(Color("SystemContrast2"))
                        Spacer()
                    }
                }.onMove(perform: move)
            }
            Section(header: Text("QuickLinks")) {
                ForEach(quickLinks, id: \.self) { item in
                    HStack(spacing: 0) {
                        TogglerQuickLinks(quickLinks: $quickLinks, item: item, visible: item.visible)
                        Image(systemName: item.icon)
                            .font(.body.weight(.bold))
                            .foregroundStyle(Color("SystemContrast2"))
                            .frame(width: 35)
                        Text(item.name).fontWeight(.medium).foregroundStyle(Color("SystemContrast2"))
                        Spacer()
                    }
                }.onMove(perform: moveQuickLink)
            }
        }.listStyle(.sidebar)
            .frame(width: 275, height: 435)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        arrangement.move(fromOffsets: source, toOffset: destination)
    }
    
    func moveQuickLink(from source: IndexSet, to destination: Int) {
        quickLinks.move(fromOffsets: source, toOffset: destination)
    }
    
    struct Toggler: View {
        @Binding var arrangement: [ForYouItem]
        let item: ForYouItem
        @State var visible: Bool
        
        var body: some View {
            Toggle("", isOn: $visible)
                .labelsHidden()
                .onChange(of: visible) { _ in
                    if let index = arrangement.firstIndex(where: {$0.id == item.id}) {
                        arrangement[index] = ForYouItem(id: item.id, icon: item.icon, visible: visible)
                    }
                }
        }
    }
    
    struct TogglerQuickLinks: View {
        @Binding var quickLinks: [QuickLink]
        let item: QuickLink
        @State var visible: Bool
        
        var body: some View {
            Toggle("", isOn: $visible)
                .labelsHidden()
                .onChange(of: visible) { _ in
                    if let index = quickLinks.firstIndex(where: {$0.id == item.id}) {
                        quickLinks[index] = QuickLink(name: item.name, id: item.id, icon: item.icon, visible: visible)
                    }
                }
        }
    }
}
#endif

struct AcknowledgementsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let iteam = ["Rahim Malik '23", "Bernice Arreola '25"]
    let cps = ["Julie Fochler", "Edwin Kirimi", "Linh Tran Tsang", "Steve Chabon", "Preston Tucker"]
    
    let dependencies: [(name: String, link: URL)] = [("Firebase (10.11.0)", URL(string: "https://github.com/firebase/firebase-ios-sdk")!), ("GoogleSignIn (7.0.0)", URL(string: "https://github.com/google/GoogleSignIn-iOS")!), ("CodableFirebase (0.2.2)", URL(string: "https://github.com/alickbass/CodableFirebase")!), ("DynamicColor (5.0.0)", URL(string: "https://github.com/yannickl/DynamicColor")!), ("ColorThiefSwift (0.4.1)", URL(string: "https://github.com/yamoridon/ColorThiefSwift")!)]
    
    var body: some View {
#if os(iOS)
        NavigationView {
            List {
                Section(header: Text("**iTEAM CONTRIBUTIONS**").textCase(.none).foregroundStyle(.gray)) {
                    ForEach(iteam, id: \.self) { name in
                        Text(name)
                    }
                }.foregroundStyle(Color("SystemContrast"))
                Section(header: Text("**FACULTY CONTRIBUTIONS**").foregroundStyle(.gray)) {
                    ForEach(cps, id: \.self) { name in
                        Text(name)
                    }
                }.foregroundStyle(Color("SystemContrast"))
                Section(header: Text("**EXTERNAL CONTRIBUTIONS**")) {
                    ForEach(dependencies, id: \.name) { dependency in
                        Link(destination: dependency.link, label: {
                            Text(dependency.name).foregroundStyle(Color("AccentColor"))
                        })
                    }
                }
            }
            .navigationTitle("Acknowledgments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                }
            }
        }
#elseif os(macOS)
        List {
            Section(header: Text("iTEAM CONTRIBUTIONS").textCase(.none).foregroundStyle(.gray)) {
                ForEach(iteam, id: \.self) { name in
                    Text(name)
                }
            }.foregroundStyle(Color("SystemContrast"))
            Section(header: Text("FACULTY CONTRIBUTIONS").foregroundStyle(.gray)) {
                ForEach(cps, id: \.self) { name in
                    Text(name)
                }
            }.foregroundStyle(Color("SystemContrast"))
            Section(header: Text("EXTERNAL CONTRIBUTIONS")) {
                ForEach(dependencies, id: \.name) { dependency in
                    Link(destination: dependency.link, label: {
                        Text(dependency.name).foregroundStyle(Color("AccentColor"))
                    })
                }
            }
        }
        .listStyle(.sidebar)
#endif
    }
}
