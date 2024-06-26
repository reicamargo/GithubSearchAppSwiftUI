//
//  GithubUserProfileView.swift
//  GithubSearchSwiftUI
//
//  Created by Reinaldo Camargo on 07/05/24.
//

import SwiftUI

struct GithubUserProfileView: View {
    @ObservedObject var viewModel: GithubUserProfileViewModel
    
    var body: some View {
            ZStack {
                if viewModel.isLoading {
                    LoadingView()
                }
                
                VStack {
                    SearchView(searchText: $viewModel.searchFollower, textPlaceholder: "Search a follower")
                    
                    ScrollView {
                        LazyVGrid(columns: viewModel.columns, spacing: 20, content: {
                            
                            ForEach(viewModel.filteredFollowers) { follower in
                                FollowerGridCellView(follower: follower)
                                    .onTapGesture {
                                        viewModel.selectedUserLogin = follower.login
                                        viewModel.showGithubUserDetailView = true
                                    }
                            }
                        })
                    }
                    .sheet(isPresented: $viewModel.showGithubUserDetailView) {
                        GithubUserDetailView(login: viewModel.selectedUserLogin)
                            .environmentObject(viewModel)
                    }
                    .toolbar {
                        Button {
                            viewModel.isFavorite.toggle()
                        } label: {
                            FavoriteButton(isFavorite: viewModel.isFavorite)
                                .padding(.trailing, 20)
                        }
                        
                    }
                }
                .task {
                    await viewModel.loadFollowers()
                }
                .alert(viewModel.alertItem.title,
                       isPresented: $viewModel.alertItem.showAlert,
                       presenting: viewModel.alertItem,
                       actions: { alertItem in alertItem.actionButton },
                       message: { alertItem in alertItem.message })
                
                if viewModel.filteredFollowers.isEmpty && !viewModel.isLoading {
                    EmptyStateView(title: "This user has no followers", imageResource: .emptyStateLogo, description: "That's so sad 😔")
                }
            }
            .navigationTitle(viewModel.username)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.searchFollower = ""
            }
    }
    
    init(username: String) {
        viewModel = GithubUserProfileViewModel(username: username)
    }
}

#Preview {
    GithubUserProfileView(username: "leopug")
}
