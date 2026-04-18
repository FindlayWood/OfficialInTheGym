//
//  MyDayKitRootview.swift
//  MyDayKit
//
//  Created by Findlay Wood on 11/08/2025.
//

import SwiftUI

public struct MyDayKitRootview: View {
    
    @ObservedObject var router: MyDayKitRouter
    
    public init(router: MyDayKitRouter) {
        self.router = router
    }
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            router.view(for: .root)
                .navigationDestination(for: MyDayRoutes.self) { link in
                    router.view(for: link)
                }
                .sheet(item: $router.presentedSheet, onDismiss: {
                    router.presentedSheet = nil
                }) { sheet in
                    router.sheet(for: sheet)
                }
                .fullScreenCover(item: $router.fullScreenCover) { cover in
                    router.fullScreenCover(for: cover)
                }
        }
    }
}

#Preview {
    MyDayKitRootview(
        router: MyDayKitRouter(
            exerciseManager: ExerciseManager(loader: PreviewExerciseLoader()),
            dayManager: MyDayManager(
                saver: PreviewSaver(),
                clipSaver: PreviewMyDaySaver(),
                deleteSaver: PreviewMyDaySaver(),
                loader: PreviewLoader(),
                deleter: PreviewMyDayDeleter(),
                wellnessSaver: PreviewMyDaySaver(),
                rpeSaver: PreviewMyDaySaver()
            ),
            videoConverter: VideoConverter(
                userID: "user123",
                thumbnailGenerator: MockThumbnailGenerator()
            ),
            uploadManager: UploadManager(clipUploader: MockClipUploader())
        )
    )
}
