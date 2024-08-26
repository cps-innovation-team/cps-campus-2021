//
//  PaletteView.swift
//  CPS Campus (macOS)
//
//  6/28/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import DynamicColor
import WidgetKit

struct PaletteView: View {
    
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses: [Course] = defaultCourses
    
    @StateObject var paletteObject = PaletteFetcher()
    @AppStorage("CustomPalettes", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var customPalettes: [Palette] = []
    
    //MARK: Authentication
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    //MARK: Environment
    @Environment(\.colorScheme) var colorScheme
    @State var temporaryCourses: [Course] = defaultCourses
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(defaultPalettes, id: \.self) { palette in
                    Button(action: {
                        temporaryCourses = courses.sorted(by: { $0.num < $1.num })
                        for temporaryCourse in temporaryCourses.sorted(by: { $0.num < $1.num }) {
                            if temporaryCourse.num >= 8 {
                                temporaryCourses[temporaryCourse.num].color = palette.colorsHex[8]
                            } else {
                                temporaryCourses[temporaryCourse.num].color = palette.colorsHex[temporaryCourse.num]
                            }
                        }
                        courses = temporaryCourses
                        WidgetCenter.shared.reloadAllTimelines()
                    }, label: {
                        PaletteSubview(palette: palette, signedIn: true)
                    }).buttonStyle(ScaleButtonStyle())
                }
            }.padding()
            Divider().padding(.horizontal)
            LazyVGrid(columns: columns) {
                ForEach(paletteObject.palettes.sorted(by: {$0.name < $1.name}), id: \.self) { palette in
                    Button(action: {
                        temporaryCourses = courses.sorted(by: { $0.num < $1.num })
                        for temporaryCourse in temporaryCourses.sorted(by: { $0.num < $1.num }) {
                            if temporaryCourse.num >= 8 {
                                temporaryCourses[temporaryCourse.num].color = palette.colorsHex[8]
                            } else {
                                temporaryCourses[temporaryCourse.num].color = palette.colorsHex[temporaryCourse.num]
                            }
                        }
                        courses = temporaryCourses
                        WidgetCenter.shared.reloadAllTimelines()
                    }, label: {
                        PaletteSubview(palette: palette, signedIn: authViewModel.state == .signedIn)
                    }).buttonStyle(ScaleButtonStyle())
                }
            }.padding()
        }
    }
}

struct PaletteSubview: View {
    
    let palette: Palette
    @Environment(\.colorScheme) var colorScheme
    
    let columns = [
        GridItem(.flexible(), spacing: 2.5),
        GridItem(.flexible(), spacing: 2.5),
        GridItem(.flexible(), spacing: 2.5),
        GridItem(.flexible(), spacing: 2.5),
        GridItem(.flexible(), spacing: 2.5)
    ]
    
    let signedIn: Bool
    
    var body: some View {
        VStack {
            ZStack {
                LazyVGrid(columns: columns, spacing: 2.5) {
                    ForEach(palette.colorsHex, id: \.self) { colorHex in
                        Rectangle()
                            .foregroundStyle(Color(colorScheme == .dark ? NSColor(hexString: colorHex).shaded(amount: 0.15) : NSColor(hexString: colorHex).tinted(amount: 0.15)))
                            .frame(height: 50)
                    }
                    Rectangle()
                        .foregroundStyle(Color(colorScheme == .dark ? NSColor(hexString: palette.colorsHex.last ?? "").shaded(amount: 0.15) : NSColor(hexString: palette.colorsHex.last ?? "").tinted(amount: 0.15)))
                        .frame(height: 50)
                }
                HStack {
                    VStack(alignment: .leading) {
                        Spacer()
                        Text(palette.name == "" ? "Untitled" : palette.name)
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                            .foregroundStyle(Color("SystemContrast"))
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8.5, style: .continuous))
                    }
                    Spacer()
                }.padding(10)
            }.frame(height: 100).clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            if palette.creator != "" && signedIn {
                HStack(spacing: 5) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color("SystemContrast2"))
                    Text(palette.creator)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color("SystemContrast2"))
                    Spacer()
                }.padding(.leading)
                    .padding(.vertical, 2.5)
            }
            Spacer()
        }
    }
}
