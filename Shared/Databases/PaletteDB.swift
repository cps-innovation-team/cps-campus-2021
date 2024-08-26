//
//  PaletteDB.swift
//  CPS Campus (Shared)
//
//  1/1/2023
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseDatabase
import CodableFirebase
import PhotosUI
import DynamicColor

class PaletteFetcher: ObservableObject, Equatable {
    
    static func == (lhs: PaletteFetcher, rhs: PaletteFetcher) -> Bool {
        return lhs.palettes == rhs.palettes
    }
    
    @Published var palettes: [Palette] = []
    @Published var collections: [PaletteCollection] = []
    
    init() {
        var reference: DatabaseReference!
        reference = Database.database(url: "https://cps-campus-palettes.firebaseio.com/").reference().child("palettes")
        
        reference.observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value else { return }
            do {
                let products = try FirebaseDecoder().decode([String: Palette].self, from: value)
                self.palettes = products.values.map{$0}
                databaseLogger.log("palette data initialized")
                reference = Database.database(url: "https://cps-campus-palettes.firebaseio.com/").reference().child("paletteCollections")
                
                reference.observeSingleEvent(of: .value) { (snapshot) in
                    guard let value = snapshot.value else { return }
                    do {
                        let products = try FirebaseDecoder().decode([String: [String: Bool]].self, from: value)
                        var temporaryCollections = [PaletteCollection]()
                        for product in products {
                            temporaryCollections.append(PaletteCollection(name: product.key, palettes: self.palettes.filter { product.value.filter{$0.value == true}.map{$0.key}.contains($0.id) }))
                        }
                        self.collections = temporaryCollections
                        databaseLogger.log("palette collections initialized")
                    } catch let error {
                        databaseLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
                    }
                }
            } catch let error {
                databaseLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
            }
        }
    }
    
    func publishPalette(palette: Palette, anonymous: Bool) {
        var reference: DatabaseReference!
        reference = Database.database(url: "https://cps-campus-palettes.firebaseio.com/").reference().child("palettes")
        
        let key = String(palette.id)
        let updatedData: [String: Any] = ["id": palette.id,
                                          "name": palette.name,
                                          "creator": anonymous ? "" : palette.creator,
                                          "campusID": palette.campusID,
                                          "colorsHex": palette.colorsHex]
        reference.child(key).setValue(updatedData)
        databaseLogger.log("palette published")
        
        reference.observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value else { return }
            do {
                let products = try FirebaseDecoder().decode([String: Palette].self, from: value)
                self.palettes = products.values.map{$0}
                databaseLogger.log("palette data updated")
            } catch let error {
                databaseLogger.error("\(error.localizedDescription, privacy: .public) > \(error, privacy: .public)")
            }
        }
    }
    
    func removePalette(paletteID: String, completion: @escaping ()->()) {
        var reference: DatabaseReference!
        reference = Database.database(url: "https://cps-campus-palettes.firebaseio.com/").reference().child("palettes")
        
        reference.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(cleanFirebaseKey(input: paletteID)) {
                reference.child(cleanFirebaseKey(input: paletteID)).removeValue(completionBlock: { error, reference in
                    databaseLogger.log("palette deleted")
                    self.palettes.removeAll(where: {$0.id == paletteID})
                    completion()
                })
            } else {
                
            }
        })
    }
}

#if canImport(UIKit)
//MARK: - Helper Functions
func colorAdjustAlgorithm(color: UIColor) -> UIColor {
    var output = UIColor(hexString: "ffffff")
    output = color
    if output.luminance <= 0.05 {
        output = output.lighter(amount: (0.05-output.luminance)*3)
    } else if output.luminance >= 0.85 {
        output = output.darkened(amount: (output.luminance-0.85)*3)
    }
    return output
}

func getColorsfromCourses(courses: [Course]) -> [String] {
    var output = [String]()
    for course in courses.sorted(by: { $0.num < $1.num }) {
        if course.num <= 9 {
            output.append(course.color)
        }
    }
    return output
}

func convertColorArraytoStringArray(input: [Color]) -> [String] {
    var output = [String]()
    for color in input {
        output.append(UIColor(color).toHexString())
    }
    return output
}

func convertStringArraytoColorArray(input: [String]) -> [Color] {
    var output = [Color]()
    for color in input {
        output.append(Color(hexString: color))
    }
    return output
}

//MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}
#endif
