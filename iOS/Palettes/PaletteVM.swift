//
//  PaletteVM.swift
//  CPS Campus (iOS)
//
//  1/1/2023
//  Designed by Rahim Malik in California.
//

import SwiftUI
import DynamicColor

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
                    ForEach(palette.colorsHex.indices, id: \.self) { index in
                        Rectangle()
                            .foregroundStyle(Color(colorScheme == .dark ? UIColor(hexString: palette.colorsHex[index]).shaded(amount: 0.15) : UIColor(hexString: palette.colorsHex[index]).tinted(amount: 0.15)))
                            .frame(height: 50)
                    }
                    Rectangle()
                        .foregroundStyle(Color(colorScheme == .dark ? UIColor(hexString: palette.colorsHex.last ?? "").shaded(amount: 0.15) : UIColor(hexString: palette.colorsHex.last ?? "").tinted(amount: 0.15)))
                        .frame(height: 50)
                }
                HStack {
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            Text(palette.name == "" ? "Untitled" : palette.name)
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundStyle(Color("SystemContrast"))
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 8.5, style: .continuous))
                            Spacer()
                        }
                    }
                }.padding(10)
            }.frame(height: 100).clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            if palette.creator != "" && signedIn {
                HStack(spacing: 5) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color("SystemContrast2"))
                    Text(palette.creator)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color("SystemContrast2"))
                    Spacer()
                }.padding(.leading)
                    .padding(.vertical, 2.5)
            }
        }
    }
}

struct CustomPaletteSubview: View {
    
    let palette: Palette
    @Environment(\.colorScheme) var colorScheme
    
    let columns = [
        GridItem(.flexible(), spacing: 2.5),
        GridItem(.flexible(), spacing: 2.5),
        GridItem(.flexible(), spacing: 2.5),
        GridItem(.flexible(), spacing: 2.5),
        GridItem(.flexible(), spacing: 2.5)
    ]
    
    var body: some View {
        VStack {
            ZStack {
                LazyVGrid(columns: columns, spacing: 2.5) {
                    ForEach(palette.colorsHex.indices, id: \.self) { index in
                        Rectangle()
                            .foregroundStyle(Color(colorScheme == .dark ? UIColor(hexString: palette.colorsHex[index]).shaded(amount: 0.15) : UIColor(hexString: palette.colorsHex[index]).tinted(amount: 0.15)))
                            .frame(height: 50)
                    }
                    Rectangle()
                        .foregroundStyle(Color(colorScheme == .dark ? UIColor(hexString: palette.colorsHex.last ?? "").shaded(amount: 0.15) : UIColor(hexString: palette.colorsHex.last ?? "").tinted(amount: 0.15)))
                        .frame(height: 50)
                }
                HStack {
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            Text(palette.name == "" ? "Untitled" : palette.name)
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundStyle(Color("SystemContrast"))
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 8.5, style: .continuous))
                            Spacer()
                        }
                    }
                }.padding(10)
            }.frame(height: 100).clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
    }
}
