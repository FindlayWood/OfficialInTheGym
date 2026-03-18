//
//  ExerciseClipsSubView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 01/02/2026.
//

import SwiftUI

struct ExerciseClipsSubView: View {
    
    let clips: [MyDayClipModel]
    let canAdd: Bool
    
    var addAction: (() -> ())?
    var selectedClip: ((MyDayClipModel, UIImage, CGRect) -> ())?
    
    var body: some View {
        Group {
            if clips.isEmpty && canAdd {
                emptyState
            } else {
                clipList
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        Button {
            addAction?()
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(UIColor.secondarySystemBackground))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "video.badge.plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Add a clip")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    Text("Record or upload a video")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    // MARK: - Clip List
    
    private var clipList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(clips, id: \.id) { clip in
                    GeometryReader { geometry in
                        SingleClipListView(
                            clip: clip,
                            selected: { uiImage in
                                let globalFrame = geometry.frame(in: .global)
                                selectedClip?(clip, uiImage, globalFrame)
                            }
                        )
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(UIColor.separator), lineWidth: 0.5)
                        }
                    }
                    .frame(width: 80, height: 80)
                }
                
                // Add button — only shown when canAdd
                if canAdd {
                    Button {
                        addAction?()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .frame(width: 60, height: 60)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(UIColor.separator), lineWidth: 0.5)
                                }
                            
                            VStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Color.blue)
                                Text("Add")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(Color.blue)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    ExerciseClipsSubView(
        clips: [.init(
            id: UUID().uuidString,
            clipID: UUID().uuidString,
            exerciseID: UUID().uuidString,
            dateUploaded: .now,
            thumbnailURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/inthegym-2353b.appspot.com/o/TestClipThumbnails%2FfZKSEr4e6yWdYqt0P6BXbnyg1pf2%2F810FB504-DADF-4E76-9B6E-89A1FE2DC827?alt=media&token=59c6f5f7-a153-4c5b-ab16-aa8c7bf8f56a")
        ),
                .init(
                    id: UUID().uuidString,
                    clipID: UUID().uuidString,
                    exerciseID: UUID().uuidString,
                    dateUploaded: .now,
                    thumbnailURL: nil
                )],
        canAdd: true
    )
}


struct SingleClipListView: View {
    
    @State private var image: UIImage?
    
    let clip: MyDayClipModel
    
    var selected: ((UIImage) -> ())?
    
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .inset(by: 1)
                            .stroke(Color.blue, lineWidth: 2)
                    }
                    .onTapGesture {
                        selected?(image)
                    }
            } else {
                Image(uiImage: placeholderColorImage())
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .inset(by: 1)
                            .stroke(Color.blue, lineWidth: 2)
                    }
                    .onTapGesture {
                        selected?(placeholderColorImage())
                    }
            }
        }
        .onAppear {
            loadURL()
        }
    }
    
    func loadURL() {
        guard let url = clip.thumbnailURL else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                print(String(describing: error))
            } else if let data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }.resume()
    }
    
    func placeholderColorImage() -> UIImage {
        let size = CGSize(width: 50, height: 50)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.red.withAlphaComponent(0.5).setFill()
            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
    }



}

#Preview {
    SingleClipListView(
        clip: .init(
            id: UUID().uuidString,
            clipID: UUID().uuidString,
            exerciseID: UUID().uuidString,
            dateUploaded: .now - 600,
            thumbnailURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/inthegym-2353b.appspot.com/o/TestClipThumbnails%2FfZKSEr4e6yWdYqt0P6BXbnyg1pf2%2F810FB504-DADF-4E76-9B6E-89A1FE2DC827?alt=media&token=59c6f5f7-a153-4c5b-ab16-aa8c7bf8f56a")
        )
    )
}
