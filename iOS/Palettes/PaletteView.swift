//
//  PaletteView.swift
//  CPS Campus (iOS)
//
//  6/28/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import DynamicColor
import WidgetKit
import ColorThiefSwift
import FirebaseAuth
import GoogleSignIn

struct PaletteView: View {
    
    @AppStorage("Courses", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var courses: [Course] = defaultCourses
    @State var temporaryCourses: [Course] = defaultCourses
    
    @StateObject var paletteObject = PaletteFetcher()
    @AppStorage("CustomPalettes", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var customPalettes: [Palette] = []
    
    //MARK: Authentication
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var campusID: User? = nil
    
    //MARK: Environment
    @Environment(\.openURL) var openURL
    @State var createPalette = false
    @State var alertDetails: Palette?
    @State var alertShowing = false
    let negativePadding: CGFloat
    
    @State var selected = "yours"
    @State var search = ""
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 15) {
                    if search.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Spacer().frame(width: 15)
                                Button {
                                    selected = "yours"
                                    let haptics = UIImpactFeedbackGenerator(style: .light)
                                    haptics.impactOccurred()
                                } label: {
                                    HStack {
                                        Text("Yours")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundStyle(selected == "yours" ? Color(.white) : Color("SystemContrast"))
                                    }
                                    .frame(height: 20)
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).foregroundStyle(selected == "yours" ? Color("AccentColor") : Color(.systemGray5)))
                                }
                                Button {
                                    selected = "default"
                                    let haptics = UIImpactFeedbackGenerator(style: .light)
                                    haptics.impactOccurred()
                                } label: {
                                    HStack {
                                        Text("Default")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundStyle(selected == "default" ? Color(.white) : Color("SystemContrast"))
                                    }
                                    .frame(height: 20)
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).foregroundStyle(selected == "default" ? Color("AccentColor") : Color(.systemGray5)))
                                }
                                Button {
                                    selected = "all"
                                    let haptics = UIImpactFeedbackGenerator(style: .light)
                                    haptics.impactOccurred()
                                } label: {
                                    HStack {
                                        Text("All Published")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundStyle(selected == "all" ? Color(.white) : Color("SystemContrast"))
                                    }
                                    .frame(height: 20)
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).foregroundStyle(selected == "all" ? Color("AccentColor") : Color(.systemGray5)))
                                }
                                ForEach(paletteObject.collections.sorted(by: {$0.name < $1.name}), id: \.self) { collection in
                                    Button {
                                        selected = collection.name
                                        let haptics = UIImpactFeedbackGenerator(style: .light)
                                        haptics.impactOccurred()
                                    } label: {
                                        HStack {
                                            Text(collection.name)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundStyle(selected == collection.name ? Color(.white) : Color("SystemContrast"))
                                        }
                                        .frame(height: 20)
                                        .padding(10)
                                        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).foregroundStyle(selected == collection.name ? Color("AccentColor") : Color(.systemGray5)))
                                    }
                                }
                                Spacer().frame(width: 15)
                            }
                        }
                        .padding(.horizontal, -15)
                        .padding(.top, negativePadding)
                        .padding(.bottom, 5)
                        if selected == "yours" {
                            Group {
                                Button(action: {
                                    createPalette = true
                                }, label: {
                                    HStack(spacing: 5) {
                                        Spacer()
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 17))
                                            .foregroundStyle(Color("AccentColor"))
                                        Text("Create a Palette")
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color("AccentColor"))
                                        Spacer()
                                    }.padding()
                                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color("AccentColor").opacity(0.25)))
                                }).padding(.bottom, 5)
                                ForEach(customPalettes.reversed(), id: \.self) { palette in
                                    Button(action: {
                                        let haptics = UIImpactFeedbackGenerator(style: .rigid)
                                        haptics.impactOccurred()
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
                                        CustomPaletteSubview(palette: palette)
                                    }).buttonStyle(ScaleButtonStyle())
                                    HStack {
                                        Button(action: {
                                            let haptics = UIImpactFeedbackGenerator(style: .light)
                                            haptics.impactOccurred()
                                            customPalettes = customPalettes.filter { $0.id != palette.id }
                                        }, label: {
                                            HStack(spacing: 5) {
                                                Image(systemName: "trash.fill")
                                                    .font(.system(size: 15, weight: .medium))
                                                    .foregroundStyle(.red)
                                                Text("Delete")
                                                    .font(.system(size: 15, weight: .medium))
                                                    .foregroundStyle(.red)
                                            }.padding(.leading)
                                                .padding(.bottom, 2.5)
                                        })
                                        if paletteObject.palettes.filter({ $0.id == palette.id }).isEmpty {
                                            Button(action: {
                                                if authViewModel.state == .signedIn {
                                                    alertDetails = palette
                                                    alertShowing = true
                                                } else {
                                                    openURL(URL(string: "cpscampus://settings/campusID")!)
                                                }
                                            }, label: {
                                                HStack(spacing: 5) {
                                                    Image(systemName: "icloud.and.arrow.up.fill")
                                                        .font(.system(size: 15, weight: .medium))
                                                        .foregroundStyle(Color("AccentColor"))
                                                    if authViewModel.state == .signedIn {
                                                        Text("Publish")
                                                            .font(.system(size: 15, weight: .medium))
                                                            .foregroundStyle(Color("AccentColor"))
                                                    } else {
                                                        Text("Sign in to Publish")
                                                            .font(.system(size: 15, weight: .medium))
                                                            .foregroundStyle(Color("AccentColor"))
                                                    }
                                                }.padding(.leading)
                                                    .padding(.bottom, 2.5)
                                            })
                                            .alert("Publish Palette", isPresented: $alertShowing, presenting: alertDetails, actions: { palette in
                                                Button("Publish") {
                                                    paletteObject.publishPalette(palette: palette, anonymous: false)
                                                    let haptics = UINotificationFeedbackGenerator()
                                                    haptics.notificationOccurred(.success)
                                                }
                                                Button("Publish Anonymously") {
                                                    paletteObject.publishPalette(palette: palette, anonymous: true)
                                                    let haptics = UINotificationFeedbackGenerator()
                                                    haptics.notificationOccurred(.success)
                                                }
                                                Button("Cancel", role: .cancel) {}
                                            }, message: { _ in
                                                Text("Publish this palette for anyone to use. You can choose to be credited or remain anonymous. Your name will not be visible to anyone without a CPS account.")
                                            })
                                        } else if campusID != nil && campusID!.id == paletteObject.palettes.first(where: { $0.id == palette.id })?.campusID {
                                            Button(action: {
                                                if authViewModel.state == .signedIn {
                                                    paletteObject.removePalette(paletteID: palette.id, completion: {
                                                        let haptics = UINotificationFeedbackGenerator()
                                                        haptics.notificationOccurred(.success)
                                                    })
                                                } else {
                                                    openURL(URL(string: "cpscampus://settings/campusID")!)
                                                }
                                            }, label: {
                                                HStack(spacing: 5) {
                                                    Image(systemName: "xmark.icloud.fill")
                                                        .font(.system(size: 15, weight: .medium))
                                                        .foregroundStyle(.red)
                                                    if authViewModel.state == .signedIn {
                                                        Text("Unpublish")
                                                            .font(.system(size: 15, weight: .medium))
                                                            .foregroundStyle(.red)
                                                    } else {
                                                        Text("Sign in to Unpublish")
                                                            .font(.system(size: 15, weight: .medium))
                                                            .foregroundStyle(.red)
                                                    }
                                                }.padding(.leading)
                                                    .padding(.bottom, 2.5)
                                            })
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                        else if selected == "default" {
                            Group {
                                VStack(spacing: 12.5) {
                                    ForEach(defaultPalettes, id: \.self) { palette in
                                        Button(action: {
                                            let haptics = UIImpactFeedbackGenerator(style: .rigid)
                                            haptics.impactOccurred()
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
                                }
                            }
                        }
                        else if selected == "all" {
                            Group {
                                VStack(spacing: 12.5) {
                                    ForEach(paletteObject.palettes.sorted(by: {$0.name < $1.name}), id: \.self) { palette in
                                        Button(action: {
                                            let haptics = UIImpactFeedbackGenerator(style: .rigid)
                                            haptics.impactOccurred()
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
                                }
                            }
                        }
                        else {
                            Group {
                                VStack(spacing: 12.5) {
                                    if let collection = paletteObject.collections.first(where: {$0.name == selected}) {
                                        ForEach(collection.palettes.sorted(by: {$0.name < $1.name}).sorted(by: {$0.creator > $1.creator}), id: \.self) { palette in
                                            Button(action: {
                                                let haptics = UIImpactFeedbackGenerator(style: .rigid)
                                                haptics.impactOccurred()
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
                                    }
                                }
                            }
                        }
                    } else {
                        VStack(spacing: 12.5) {
                            ForEach(customPalettes.filter{$0.name.lowercased().contains(search.lowercased())}.sorted(by: {$0.name < $1.name}), id: \.self) { palette in
                                Button(action: {
                                    let haptics = UIImpactFeedbackGenerator(style: .rigid)
                                    haptics.impactOccurred()
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
                                    CustomPaletteSubview(palette: palette)
                                }).buttonStyle(ScaleButtonStyle())
                                HStack {
                                    Button(action: {
                                        let haptics = UIImpactFeedbackGenerator(style: .light)
                                        haptics.impactOccurred()
                                        customPalettes = customPalettes.filter { $0.id != palette.id }
                                    }, label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: "trash.fill")
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundStyle(.red)
                                            Text("Delete")
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundStyle(.red)
                                        }.padding(.leading)
                                            .padding(.bottom, 2.5)
                                    })
                                    if paletteObject.palettes.filter({ $0.id == palette.id }).isEmpty {
                                        Button(action: {
                                            if authViewModel.state == .signedIn {
                                                alertDetails = palette
                                                alertShowing = true
                                            } else {
                                                openURL(URL(string: "cpscampus://settings/campusID")!)
                                            }
                                        }, label: {
                                            HStack(spacing: 5) {
                                                Image(systemName: "icloud.and.arrow.up.fill")
                                                    .font(.system(size: 15, weight: .medium))
                                                    .foregroundStyle(Color("AccentColor"))
                                                if authViewModel.state == .signedIn {
                                                    Text("Publish")
                                                        .font(.system(size: 15, weight: .medium))
                                                        .foregroundStyle(Color("AccentColor"))
                                                } else {
                                                    Text("Sign in to Publish")
                                                        .font(.system(size: 15, weight: .medium))
                                                        .foregroundStyle(Color("AccentColor"))
                                                }
                                            }.padding(.leading)
                                                .padding(.bottom, 2.5)
                                        })
                                        .alert("Publish Palette", isPresented: $alertShowing, presenting: alertDetails, actions: { palette in
                                            Button("Publish") {
                                                paletteObject.publishPalette(palette: palette, anonymous: false)
                                                let haptics = UINotificationFeedbackGenerator()
                                                haptics.notificationOccurred(.success)
                                            }
                                            Button("Publish Anonymously") {
                                                paletteObject.publishPalette(palette: palette, anonymous: true)
                                                let haptics = UINotificationFeedbackGenerator()
                                                haptics.notificationOccurred(.success)
                                            }
                                            Button("Cancel", role: .cancel) {}
                                        }, message: { _ in
                                            Text("Publish this palette for anyone to use. You can choose to be credited or remain anonymous. Your name will not be visible to anyone without a CPS account.")
                                        })
                                    } else if campusID != nil && campusID!.id == paletteObject.palettes.first(where: { $0.id == palette.id })?.campusID {
                                        Button(action: {
                                            if authViewModel.state == .signedIn {
                                                paletteObject.removePalette(paletteID: palette.id, completion: {
                                                    let haptics = UINotificationFeedbackGenerator()
                                                    haptics.notificationOccurred(.success)
                                                })
                                            } else {
                                                openURL(URL(string: "cpscampus://settings/campusID")!)
                                            }
                                        }, label: {
                                            HStack(spacing: 5) {
                                                Image(systemName: "xmark.icloud.fill")
                                                    .font(.system(size: 15, weight: .medium))
                                                    .foregroundStyle(.red)
                                                if authViewModel.state == .signedIn {
                                                    Text("Unpublish")
                                                        .font(.system(size: 15, weight: .medium))
                                                        .foregroundStyle(.red)
                                                } else {
                                                    Text("Sign in to Unpublish")
                                                        .font(.system(size: 15, weight: .medium))
                                                        .foregroundStyle(.red)
                                                }
                                            }.padding(.leading)
                                                .padding(.bottom, 2.5)
                                        })
                                    }
                                    Spacer()
                                }
                            }
                            ForEach(paletteObject.palettes.filter{$0.name.lowercased().contains(search.lowercased())}.sorted(by: {$0.name < $1.name}), id: \.self) { palette in
                                Button(action: {
                                    let haptics = UIImpactFeedbackGenerator(style: .rigid)
                                    haptics.impactOccurred()
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
                            HStack {
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }.background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Palette Studio")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for palettes")
        .onAppear {
            GIDSignIn.sharedInstance.restorePreviousSignIn { googleUser, error in
                if googleUser != nil {
                    authViewModel.signIn()
                    fetchCurrentUser(emailID: googleUser?.profile?.email ?? "NilEmail", completion: { currentUser in
                        campusID = currentUser
                    })
                }
            }
        }
        .sheet(isPresented: $createPalette) {
            AddPaletteView(palette: Palette(name: "", colorsHex: getColorsfromCourses(courses: courses), campusID: campusID?.id ?? "", creator: campusID?.name ?? ""))
        }
    }
}

struct AddPaletteView: View {
    
    @State var palette: Palette
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @State var color0 = Color.white
    @State var color1 = Color.white
    @State var color2 = Color.white
    @State var color3 = Color.white
    @State var color4 = Color.white
    @State var color5 = Color.white
    @State var color6 = Color.white
    @State var color7 = Color.white
    @State var color8 = Color.white
    
    let columns = [
        GridItem(.flexible(), spacing: 2.5),
        GridItem(.flexible(), spacing: 2.5),
        GridItem(.flexible(), spacing: 2.5),
        GridItem(.flexible(), spacing: 2.5),
        GridItem(.flexible(), spacing: 2.5)
    ]
    
    @State var showImagePicker = false
    @State var inputImage: UIImage?
    
    @AppStorage("CustomPalettes", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var customPalettes: [Palette] = []
    
    var body: some View {
        NavigationView {
            VStack {
                Text("**A palette has been curated from the current colors assigned to your courses. Individually customize colors or automatically generate a palette from a selected image below.\n\nThen, you can save the palette to your custom collection and publish it for others to use.**")
                    .font(.caption).foregroundStyle(.gray)
                    .padding(.top, 15)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 15)
                TextField("Name (Required)", text: $palette.name)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color(UIColor.secondarySystemBackground)))
                    .padding(.bottom, 5)
                Group {
                    LazyVGrid(columns: columns, spacing: 2.5) { //manually created to avoid color picker on change registration problem
                        Group {
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(Color(colorScheme == .dark ? UIColor(color0).shaded(amount: 0.15) : UIColor(color0).tinted(amount: 0.15)))
                                    .frame(height: 60)
                                ColorPicker("Color", selection: $color0, supportsOpacity: false)
                                    .buttonStyle(.plain)
                                    .labelsHidden()
                            }
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(Color(colorScheme == .dark ? UIColor(color1).shaded(amount: 0.15) : UIColor(color1).tinted(amount: 0.15)))
                                    .frame(height: 60)
                                ColorPicker("Color", selection: $color1, supportsOpacity: false)
                                    .buttonStyle(.plain)
                                    .labelsHidden()
                            }
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(Color(colorScheme == .dark ? UIColor(color2).shaded(amount: 0.15) : UIColor(color2).tinted(amount: 0.15)))
                                    .frame(height: 60)
                                ColorPicker("Color", selection: $color2, supportsOpacity: false)
                                    .buttonStyle(.plain)
                                    .labelsHidden()
                            }
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(Color(colorScheme == .dark ? UIColor(color3).shaded(amount: 0.15) : UIColor(color3).tinted(amount: 0.15)))
                                    .frame(height: 60)
                                ColorPicker("Color", selection: $color3, supportsOpacity: false)
                                    .buttonStyle(.plain)
                                    .labelsHidden()
                            }
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(Color(colorScheme == .dark ? UIColor(color4).shaded(amount: 0.15) : UIColor(color4).tinted(amount: 0.15)))
                                    .frame(height: 60)
                                ColorPicker("Color", selection: $color4, supportsOpacity: false)
                                    .buttonStyle(.plain)
                                    .labelsHidden()
                            }
                        }
                        Group {
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(Color(colorScheme == .dark ? UIColor(color5).shaded(amount: 0.15) : UIColor(color5).tinted(amount: 0.15)))
                                    .frame(height: 60)
                                ColorPicker("Color", selection: $color5, supportsOpacity: false)
                                    .buttonStyle(.plain)
                                    .labelsHidden()
                            }
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(Color(colorScheme == .dark ? UIColor(color6).shaded(amount: 0.15) : UIColor(color6).tinted(amount: 0.15)))
                                    .frame(height: 60)
                                ColorPicker("Color", selection: $color6, supportsOpacity: false)
                                    .buttonStyle(.plain)
                                    .labelsHidden()
                            }
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(Color(colorScheme == .dark ? UIColor(color7).shaded(amount: 0.15) : UIColor(color7).tinted(amount: 0.15)))
                                    .frame(height: 60)
                                ColorPicker("Color", selection: $color7, supportsOpacity: false)
                                    .buttonStyle(.plain)
                                    .labelsHidden()
                            }
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(Color(colorScheme == .dark ? UIColor(color8).shaded(amount: 0.15) : UIColor(color8).tinted(amount: 0.15)))
                                    .frame(height: 60)
                                ColorPicker("Color", selection: $color8, supportsOpacity: false)
                                    .buttonStyle(.plain)
                                    .labelsHidden()
                            }
                            Rectangle()
                                .foregroundStyle(Color(UIColor.secondarySystemBackground)).frame(height: 60)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    Button(action: {
                        showImagePicker = true
                    }, label: {
                        HStack(spacing: 5) {
                            Spacer()
                            Image(systemName: "sparkles")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color("AccentColor"))
                            Text("Generate from Image")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("AccentColor"))
                            Spacer()
                        }.padding()
                    })
                    .onChange(of: inputImage) { _ in
                        let image = getImage()
                        let colors = ColorThiefSwift.ColorThief.getPalette(from: image, colorCount: 10)
                        var colorHexArray = [String]()
                        for color in colors! {
                            colorHexArray.append(colorAdjustAlgorithm(color: color.makeUIColor()).toHexString())
                        }
                        palette.colorsHex = colorHexArray
                        color0 = Color(UIColor(hexString: palette.colorsHex[0]))
                        color1 = Color(UIColor(hexString: palette.colorsHex[1]))
                        color2 = Color(UIColor(hexString: palette.colorsHex[2]))
                        color3 = Color(UIColor(hexString: palette.colorsHex[3]))
                        color4 = Color(UIColor(hexString: palette.colorsHex[4]))
                        color5 = Color(UIColor(hexString: palette.colorsHex[5]))
                        color6 = Color(UIColor(hexString: palette.colorsHex[6]))
                        color7 = Color(UIColor(hexString: palette.colorsHex[7]))
                        color8 = Color(UIColor(hexString: palette.colorsHex[8]))
                        let haptics = UINotificationFeedbackGenerator()
                        haptics.notificationOccurred(.success)
                    }
                }
                Spacer()
                Button(action: {
                    palette.colorsHex = convertColorArraytoStringArray(input: [color0,color1,color2,color3,color4,color5,color6,color7,color8])
                    palette.id = palette.colorsHex.joined(separator: "-").replacingOccurrences(of: "#", with: "")
                    customPalettes.append(palette)
                    let haptics = UIImpactFeedbackGenerator(style: .medium)
                    haptics.impactOccurred()
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    HStack(spacing: 5) {
                        Spacer()
                        Text("Save Palette")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                        Spacer()
                    }.padding()
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).foregroundStyle(Color("AccentColor")))
                }).disabled(palette.name == "")
                    .opacity(palette.name == "" ? 0.5 : 1)
            }.padding()
                .navigationTitle("Create a Palette")
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
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $inputImage)
                }
                .onAppear {
                    color0 = Color(hexString: palette.colorsHex[0])
                    color1 = Color(hexString: palette.colorsHex[1])
                    color2 = Color(hexString: palette.colorsHex[2])
                    color3 = Color(hexString: palette.colorsHex[3])
                    color4 = Color(hexString: palette.colorsHex[4])
                    color5 = Color(hexString: palette.colorsHex[5])
                    color6 = Color(hexString: palette.colorsHex[6])
                    color7 = Color(hexString: palette.colorsHex[7])
                    color8 = Color(hexString: palette.colorsHex[8])
                }
        }
    }
    
    func getImage() -> UIImage {
        guard let inputImage = inputImage else { return UIImage() }
        return inputImage
    }
}
