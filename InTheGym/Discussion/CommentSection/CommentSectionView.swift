//
//  CommentSectionView.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CommentSectionView: UIView {
    
    // MARK: - Properties
    var bottomViewAnchor: NSLayoutConstraint!
    var commentFieldHeightAnchor: NSLayoutConstraint!
    private let placeholder = "add a reply..."
    private let placeholderColour: UIColor = Constants.darkColour
    private let stackViewSpacing: CGFloat = 10, constraintSpaicng: CGFloat = 10
    
    // MARK: - Subviews
    
    var tableview: UITableView = {
        let view = UITableView()
        view.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.cellID)
        view.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.cellID)
        if #available(iOS 15.0, *) {view.sectionHeaderTopPadding = 0}
        view.tableFooterView = UIView()
        view.separatorInset = .zero
        view.layoutMargins = .zero
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var commentView: CommentView = {
        let view = CommentView()
        view.removeAttachedWorkout()
        view.textViewDidChange(view.commentTextField)
        view.sendButton.isEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}
// MARK: - Configure
private extension CommentSectionView {
    func setupUI() {
        backgroundColor = .systemBackground
        addSubview(tableview)
        addSubview(commentView)
        configureUI()
    }
    
    func configureUI() {
        bottomViewAnchor = commentView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            commentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            commentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            commentView.heightAnchor.constraint(equalToConstant: 60),
            bottomViewAnchor,
            
            tableview.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableview.bottomAnchor.constraint(equalTo: commentView.topAnchor)
        ])
    }
}

// MARK: - Public Functions
extension CommentSectionView {
    public func removeAttachedWorkout() {
        commentView.removeAttachedWorkout()
    }
    public func setInteraction(to allowed: Bool) {
        commentView.attachmentButton.isUserInteractionEnabled = allowed
        commentView.commentTextField.isUserInteractionEnabled = allowed
//        commentView.sendButton.isEnabled = allowed
//        commentView.sendButton.setTitleColor(allowed ? .lightColour : .lightGray, for: .normal)
    }
    public func resetView() {
        commentView.commentTextField.resignFirstResponder()
        commentView.commentTextField.text = ""
//        commentView.textViewDidChange(commentView.commentTextField)
        commentView.textViewDidEndEditing(commentView.commentTextField)
        commentView.removeAttachedWorkout()
        commentView.sendButton.isEnabled = false
//        commentView.sendButton.setTitleColor(.lightGray, for: .normal)
    }
}
    
import SwiftUI

struct CommentSectionViewUI: View {
    
    @ObservedObject var viewModel: CommentSectionViewModel
    
    var body: some View {
        VStack {
            List {
                Section {
                    PostView(post: viewModel.mainPost)
                }
                Section {
                    // comments
                }
                
            }
            .listStyle(.plain)
            
            Rectangle()
                .fill(Color.red)
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .ignoresSafeArea(.keyboard)
        }
    }
}

struct PostView: View {
    
    @StateObject var viewModel = ViewModel()
    
    @State var image: UIImage?
    
    var post: PostModel
    
    var body: some View {
        HStack(alignment: .top) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .scaledToFill()
                    .clipShape(Circle())
            } else {
                Circle()
                    .foregroundColor(.gray)
                    .frame(width: 50, height: 50)
            }
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        
                    } label: {
                        if let userModel = viewModel.userModel {
                            Text(userModel.username)
                                .font(.title3.bold())
                        } else {
                            Text(post.username)
                                .font(.title3.bold())
                        }
                    }
                    .buttonStyle(.plain)
                    if let userModel = viewModel.userModel {
                        if userModel.eliteAccount ?? false {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Color(.goldColour))
                        } else if userModel.verifiedAccount ?? false {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Color(.lightColour))
                        }
                    }
                }
                let time = Date(timeIntervalSince1970: (post.time))
                Text(time.getLongPostFormat())
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                Text(post.text)
                    .font(.body.weight(.semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .padding(.top)
            }
        }
        .onAppear {
            viewModel.getImage(for: post.posterID)
            viewModel.loadUserModel(post)
        }
    }
    

}

extension PostView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        // MARK: - Published Properties
        @Published var image: UIImage?
        @Published var userModel: Users?
        
        // MARK: - Methods
        func getImage(for uid: String) {
            let downloadModel = ProfileImageDownloadModel(id: uid)
            ImageCache.shared.load(from: downloadModel) { [weak self] result in
                guard let image = try? result.get() else {return}
                self?.image = image
            }
        }
        // MARK: - User Model
        func loadUserModel(_ post: PostModel) {
            let userSearchModel = UserSearchModel(uid: post.posterID)
            UsersLoader.shared.load(from: userSearchModel) { [weak self] result in
                guard let userModel = try? result.get() else {return}
                self?.userModel = userModel
            }
        }
    }
}
