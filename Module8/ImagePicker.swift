    ////
    ////  ImagePicker.swift
    ////  Module8
    ////
    ////  Created by Cenk Bilgen on 2024-03-08.
    ////

import SwiftUI
import PhotosUI

class PhotosState: ObservableObject {
    @Published var photoItem: PhotosPickerItem? {
        didSet {
            print("Photo Selected \(photoItem.debugDescription)")
            photoItem?.loadTransferable(type: Image.self) { result in
                DispatchQueue.main.async {
                    switch result {
                        case .failure(let error):
                            print(error.localizedDescription)
                        case .success(let image):
                            if let image = image {
                                self.images.append(image)
                            }
                    }
                }
            }
        }
    }
    
    @Published var images: [Image] = []
    
    @Published var fileURL: URL?
}
struct ImagePicker: View {
    @StateObject var state = PhotosState()
    @State var presentPhotos = false
    @State var presentFiles = false
    @State private var isShowingHistory = false
    
    var body: some View {
        VStack(spacing: 0) {
            PhotoView(state: state, isShowingHistory: $isShowingHistory) // Pass isSheetLarge as a binding parameter
            HStack(spacing: 0) {
                Button {
                    presentPhotos = true
                } label: {
                    Color.red
                        .overlay(Text("Get Photo"))
                }
                Button {
                    presentFiles = true
                } label: {
                    Color.yellow
                        .overlay(Text("Get File"))
                }
            }
            .foregroundColor(.primary)
        }
        .photosPicker(isPresented: $presentPhotos, selection: $state.photoItem, matching: .images, preferredItemEncoding: .compatible)
        .fileImporter(isPresented: $presentFiles, allowedContentTypes: [.image]) { result in
            switch result {
                case .success(let url):
                    state.fileURL = url
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
}

struct PhotoView : View {
    @ObservedObject var state: PhotosState
    @Binding var isShowingHistory: Bool
    @State var currentDetent: PresentationDetent = .height(UIScreen.main.bounds.height * 0.3)
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if state.images.count > 0 {
                state.images[state.images.count-1]
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .ignoresSafeArea()
                if state.images.count > 1 {
                    Button(action: {
                        isShowingHistory.toggle()
                    }) {
                        Text("History")
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .opacity(0.8)
                    }
                    .padding(16)
                }
            } else {
                Color.white
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .sheet(isPresented: $isShowingHistory) {
            PhotoHistoryView(images: $state.images, currentDetent: $currentDetent)
                .presentationDetents([.height(UIScreen.main.bounds.height * 0.3), .large],selection: $currentDetent)
                .ignoresSafeArea()
        }
    }
}

struct PhotoHistoryView: View {
    @Binding var images: [Image]
    @Binding var currentDetent: PresentationDetent
    
    var body: some View {
        Color.green.overlay(
            contentOverlay
        )
    }
    
    @ViewBuilder
    private var contentOverlay: some View {
        if currentDetent == .large {
            ScrollView {
                VStack(alignment: .center, spacing: 5) {
                    ForEach(images.indices, id: \.self) { index in
                        images[index]
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 150)
                                .clipped()
                            .overlay(deleteButton(for: index))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(images.indices, id: \.self) { index in
                        images[index]
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                    }.padding(5)
                }
            }
        }
    }
    
    private func deleteButton(for index: Int) -> some View {
        Button(action: {
            images.remove(at: index)
        }) {
            Image(systemName: "trash.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.blue)
                .frame(width: 60, height: 60)
                .padding(15)
                .clipShape(Circle())
        }
    }
}
#Preview {
    ImagePicker()
}




