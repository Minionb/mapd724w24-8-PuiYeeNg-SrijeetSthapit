//
//  ImagePicker.swift
//  Module8
//
//  Created by Cenk Bilgen on 2024-03-08.
//

import SwiftUI
import PhotosUI

class PhotosState: ObservableObject {

    @Published var photoItem: PhotosPickerItem? {
        didSet {
            print("Photo Selected \(photoItem.debugDescription)")
            photoItem?.loadTransferable(type: Image.self) { result in
                switch result {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .success(let image):
                    self.images.append(image!)
                }
            }
            print(images.last ?? "No images")
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
           
                PhotoView(state: state, isShowingHistory: $isShowingHistory)
             
                
            
                
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

struct PhotoView : View{
    @ObservedObject var state = PhotosState()
    @Binding var isShowingHistory : Bool
    
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            if (state.images.count > 0 ) {
                GeometryReader { geometry in
                    state.images.last?
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: .infinity)
                        .clipped()
                        .edgesIgnoringSafeArea(.all)
                }
                if (state.images.count > 1 ){
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
                Color.green
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .sheet(isPresented: $isShowingHistory) {
                    PhotoHistoryView(images: state.images)
                }
    }
}

struct PhotoHistoryView: View {
    var images: [Image]

    var body: some View {
        Color
            .green
            .overlay(
                HStack {
                       ForEach(images.indices, id: \.self) { index in
                           images[index]
                               .resizable()
                               .aspectRatio(contentMode: .fit)
                        }
                    }
            )
    }
}

#Preview {
    ImagePicker()
}
