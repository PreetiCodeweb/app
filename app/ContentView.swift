import SwiftUI
import Combine


struct Movie: Identifiable {
    let id = UUID()
    let title: String
    let genre: String
    let year: String
    let rating: String
    let match: Int
    let imageURL: String
    let isNew: Bool
}

let allMovies: [Movie] = [
    Movie(title: "Stranger Things", genre: "Sci-Fi • Horror", year: "2024", rating: "TV-14", match: 97, imageURL: "https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c", isNew: true),
    Movie(title: "The Batman", genre: "Action • Crime", year: "2022", rating: "PG-13", match: 92, imageURL: "https://images.unsplash.com/photo-1509347528160-9a9e33742cdb", isNew: false),
    Movie(title: "Oppenheimer", genre: "Drama • History", year: "2023", rating: "R", match: 95, imageURL: "https://images.unsplash.com/photo-1536440136628-849c177e76a1", isNew: false),
    Movie(title: "Interstellar", genre: "Sci-Fi • Adventure", year: "2014", rating: "PG-13", match: 98, imageURL: "https://images.unsplash.com/photo-1460881680858-30d872d5b530", isNew: false),
    Movie(title: "La La Land", genre: "Romance • Musical", year: "2016", rating: "PG-13", match: 88, imageURL: "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba", isNew: false),
    Movie(title: "Dune", genre: "Sci-Fi • Epic", year: "2024", rating: "PG-13", match: 94, imageURL: "https://images.unsplash.com/photo-1478720568477-152d9b164e26", isNew: true),
    Movie(title: "The Crown", genre: "Drama • History", year: "2023", rating: "TV-MA", match: 91, imageURL: "https://images.unsplash.com/photo-1535016120720-40c646be5580", isNew: true),
    Movie(title: "Avatar", genre: "Action • Fantasy", year: "2022", rating: "PG-13", match: 86, imageURL: "https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9", isNew: false),
]

class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var myList: [UUID] = []
    @Published var selectedMovie: Movie? = nil
    @Published var showDetail: Bool = false

    func isInMyList(_ movie: Movie) -> Bool {
        myList.contains(movie.id)
    }

    func toggleMyList(_ movie: Movie) {
        if isInMyList(movie) {
            myList.removeAll { $0 == movie.id }
        } else {
            myList.append(movie.id)
        }
    }
}

// MARK: - Content View

struct ContentView: View {
    @StateObject var state = AppState()

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            // Tab Pages
            Group {
                if state.selectedTab == 0 {
                    HomeView()
                } else if state.selectedTab == 1 {
                    SearchView()
                } else if state.selectedTab == 2 {
                    MyListView()
                } else if state.selectedTab == 3 {
                    DownloadsView()
                } else {
                    ProfileView()
                }
            }
            .environmentObject(state)

            // Bottom Tab Bar
            BottomTabBar(selectedTab: $state.selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $state.showDetail) {
            if let movie = state.selectedMovie {
                DetailSheet(movie: movie)
                    .environmentObject(state)
            }
        }
    }
}

// MARK: - Bottom Tab Bar

struct BottomTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)

            HStack(spacing: 0) {
                TabButton(icon: "house.fill",     label: "Home",      index: 0, selectedTab: $selectedTab)
                TabButton(icon: "magnifyingglass", label: "Search",   index: 1, selectedTab: $selectedTab)
                TabButton(icon: "plus.square",    label: "My List",   index: 2, selectedTab: $selectedTab)
                TabButton(icon: "arrow.down.circle", label: "Downloads", index: 3, selectedTab: $selectedTab)
                TabButton(icon: "person.circle",  label: "Profile",   index: 4, selectedTab: $selectedTab)
            }
            .padding(.top, 10)
            .padding(.bottom, 24)
            .background(Color.black.opacity(0.97))
        }
    }
}

struct TabButton: View {
    let icon: String
    let label: String
    let index: Int
    @Binding var selectedTab: Int

    var body: some View {
        Button {
            selectedTab = index
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(selectedTab == index ? .white : Color.gray)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject var state: AppState
    @State private var heroIndex: Int = 0

    let heroMovies = Array(allMovies.prefix(4))

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Hero Banner
                    HeroBanner(movie: heroMovies[heroIndex])
                        .onTapGesture {
                            state.selectedMovie = heroMovies[heroIndex]
                            state.showDetail = true
                        }

                    VStack(spacing: 24) {
                        // Hero page dots
                        HStack(spacing: 6) {
                            ForEach(0..<heroMovies.count, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(i == heroIndex ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: i == heroIndex ? 16 : 6, height: 4)
                            }
                        }
                        .padding(.top, 8)

                        MovieRow(title: "Trending Now", movies: allMovies)
                        MovieRow(title: "Popular on Netflix", movies: Array(allMovies.reversed()))
                        MovieRow(title: "New Releases", movies: allMovies.filter { $0.isNew })
                        MovieRow(title: "Action & Adventure", movies: Array(allMovies.prefix(5)))
                        MovieRow(title: "Continue Watching", movies: Array(allMovies.suffix(4)))

                        Spacer(minLength: 100)
                    }
                    .background(Color.black)
                }
            }

            // Top Nav
            TopNav(heroIndex: $heroIndex, heroMovies: heroMovies)
        }
        .background(Color.black)
    }
}

// MARK: - Top Nav

struct TopNav: View {
    @Binding var heroIndex: Int
    let heroMovies: [Movie]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Text("NETFLIX")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.red)
                    .kerning(-1)

                Spacer()

                Button {} label: {
                    Image(systemName: "tv")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }

                Button {} label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }

                Button {} label: {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.blue.opacity(0.8))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Text("N")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Category pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(["TV Shows", "Movies", "New & Popular", "Anime", "K-Drama"], id: \.self) { label in
                        Text(label)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .background(
            LinearGradient(
                colors: [Color.black, Color.black.opacity(0.0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
    }
}

// MARK: - Hero Banner

struct HeroBanner: View {
    let movie: Movie
    @EnvironmentObject var state: AppState

    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: movie.imageURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 600)
            .clipped()

            // Dark gradient overlay
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.5), Color.black],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 350)

            // Content
            VStack(spacing: 12) {
                if movie.isNew {
                    Text("NEW")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.red)
                        .kerning(2)
                }

                Text(movie.title.uppercased())
                    .font(.system(size: 34, weight: .black))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.8), radius: 4)

                Text(movie.genre)
                    .font(.system(size: 14))
                    .foregroundColor(Color.white.opacity(0.75))

                HStack(spacing: 12) {
                    // Play button
                    Button {} label: {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("Play")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(width: 130, height: 44)
                        .background(Color.white)
                        .cornerRadius(6)
                    }

                    // My List button
                    Button {
                        state.toggleMyList(movie)
                    } label: {
                        VStack(spacing: 3) {
                            Image(systemName: state.isInMyList(movie) ? "checkmark" : "plus")
                                .font(.system(size: 20))
                            Text(state.isInMyList(movie) ? "Added" : "My List")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(width: 60, height: 44)
                    }

                    // Info button
                    Button {
                        state.selectedMovie = movie
                        state.showDetail = true
                    } label: {
                        VStack(spacing: 3) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 20))
                            Text("Info")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(width: 60, height: 44)
                    }
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal)
        }
        .frame(height: 600)
    }
}

// MARK: - Movie Row

struct MovieRow: View {
    let title: String
    let movies: [Movie]
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(movies) { movie in
                        MovieCard(movie: movie)
                            .onTapGesture {
                                state.selectedMovie = movie
                                state.showDetail = true
                            }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Movie Card

struct MovieCard: View {
    let movie: Movie
    @EnvironmentObject var state: AppState

    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: movie.imageURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.25))
            }
            .frame(width: 130, height: 190)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.9)],
                startPoint: .center,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                if movie.isNew {
                    Text("NEW")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(.red)
                        .kerning(1)
                }
                Text(movie.title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text("\(movie.match)% Match")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(Color.green)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Plus / checkmark button top right
            Button {
                state.toggleMyList(movie)
            } label: {
                Image(systemName: state.isInMyList(movie) ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.5), radius: 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(6)
        }
        .frame(width: 130, height: 190)
    }
}

// MARK: - Detail Sheet

struct DetailSheet: View {
    let movie: Movie
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Hero image
                    ZStack(alignment: .bottom) {
                        AsyncImage(url: URL(string: movie.imageURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 280)
                        .clipped()

                        LinearGradient(
                            colors: [Color.clear, Color.black],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(height: 140)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(movie.title)
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(.white)
                            Text(movie.genre)
                                .font(.system(size: 13))
                                .foregroundColor(Color.white.opacity(0.6))
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    VStack(alignment: .leading, spacing: 18) {

                        // Meta
                        HStack(spacing: 10) {
                            Text("\(movie.match)% Match")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.green)

                            Text(movie.year)
                                .font(.system(size: 13))
                                .foregroundColor(Color.white.opacity(0.7))

                            Text(movie.rating)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.8))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )

                            if movie.isNew {
                                Text("NEW")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.white)
                                    .cornerRadius(3)
                            }
                        }

                        // Play button
                        Button {} label: {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                Text("Play")
                                    .font(.system(size: 17, weight: .bold))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.white)
                            .cornerRadius(6)
                        }

                        // Download button
                        Button {} label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.down.to.line")
                                Text("Download")
                                    .font(.system(size: 17, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(6)
                        }

                        // Description
                        Text("An unlikely group of heroes face unspeakable dangers in this critically acclaimed series packed with suspense, heart, and edge-of-your-seat drama.")
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.85))
                            .lineSpacing(4)

                        // Action row
                        HStack(spacing: 30) {
                            Button {
                                state.toggleMyList(movie)
                            } label: {
                                VStack(spacing: 5) {
                                    Image(systemName: state.isInMyList(movie) ? "checkmark" : "plus")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                    Text(state.isInMyList(movie) ? "Added" : "My List")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.white.opacity(0.6))
                                }
                            }

                            Button {} label: {
                                VStack(spacing: 5) {
                                    Image(systemName: "hand.thumbsup")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                    Text("Rate")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.white.opacity(0.6))
                                }
                            }

                            Button {} label: {
                                VStack(spacing: 5) {
                                    Image(systemName: "paperplane")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                    Text("Share")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.white.opacity(0.6))
                                }
                            }

                            Spacer()
                        }
                    }
                    .padding(16)

                    Spacer(minLength: 80)
                }
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 16)
                }
                Spacer()
            }
        }
    }
}

// MARK: - Search View

struct SearchView: View {
    @State private var searchText: String = ""

    var results: [Movie] {
        if searchText.isEmpty { return [] }
        return allMovies.filter {
            $0.title.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text("Search")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.top, 60)

                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.white.opacity(0.5))

                    TextField("", text: $searchText)
                        .foregroundColor(.white)
                        .tint(.white)
                        .overlay(
                            Text(searchText.isEmpty ? "Search titles, genres..." : "")
                                .foregroundColor(Color.white.opacity(0.35))
                                .font(.system(size: 15)),
                            alignment: .leading
                        )

                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color.white.opacity(0.5))
                        }
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 16)

                if searchText.isEmpty {
                    // Top searches grid
                    Text("Top Searches")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)

                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(allMovies) { movie in
                                SearchTile(movie: movie)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                } else if results.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "film")
                            .font(.system(size: 50))
                            .foregroundColor(Color.white.opacity(0.25))
                        Text("No results for \"\(searchText)\"")
                            .foregroundColor(Color.white.opacity(0.55))
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(results) { movie in
                                SearchTile(movie: movie)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
    }
}

struct SearchTile: View {
    let movie: Movie

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: movie.imageURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))

            Text(movie.title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(8)
        }
        .frame(height: 100)
    }
}

// MARK: - My List View

struct MyListView: View {
    @EnvironmentObject var state: AppState

    var myMovies: [Movie] {
        allMovies.filter { state.isInMyList($0) }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("My List")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.top, 60)
                    .padding(.bottom, 16)

                if myMovies.isEmpty {
                    Spacer()
                    VStack(spacing: 14) {
                        Image(systemName: "plus.square.on.square")
                            .font(.system(size: 56))
                            .foregroundColor(Color.white.opacity(0.2))

                        Text("Your list is empty")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.5))

                        Text("Tap + on any title to add it here")
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.35))
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 8
                        ) {
                            ForEach(myMovies) { movie in
                                ZStack(alignment: .topTrailing) {
                                    AsyncImage(url: URL(string: movie.imageURL)) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .frame(height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))

                                    Button {
                                        state.toggleMyList(movie)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                            .padding(4)
                                    }
                                }
                                .frame(height: 120)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
    }
}

// MARK: - Downloads View

struct DownloadsView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 68))
                    .foregroundColor(Color.white.opacity(0.2))

                Text("Downloads")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("Save your favourite shows\nand watch them offline anytime.")
                    .font(.system(size: 14))
                    .foregroundColor(Color.white.opacity(0.5))
                    .multilineTextAlignment(.center)

                Button {} label: {
                    Text("Find Something to Download")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 14)
                        .background(Color.red)
                        .clipShape(Capsule())
                }

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Profile View

struct ProfileView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 28) {
                Text("Who's Watching?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 60)

                // Profile grid
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 24
                ) {
                    ProfileAvatar(name: "Noah",   color: .blue,   icon: "person.fill")
                    ProfileAvatar(name: "Emma",   color: .purple, icon: "person.fill")
                    ProfileAvatar(name: "Kids",   color: .yellow, icon: "star.fill")
                    ProfileAvatar(name: "Add",    color: .clear,  icon: "plus")
                }
                .padding(.horizontal, 50)

                Spacer()

                // Bottom settings row
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)

                HStack(spacing: 0) {
                    ProfileSettingButton(icon: "gearshape",         label: "Settings")
                    ProfileSettingButton(icon: "questionmark.circle", label: "Help")
                    ProfileSettingButton(icon: "rectangle.portrait.and.arrow.right", label: "Sign Out")
                }
                .padding(.bottom, 90)
            }
        }
    }
}

struct ProfileAvatar: View {
    let name: String
    let color: Color
    let icon: String

    var body: some View {
        Button {} label: {
            VStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.7))
                    .frame(width: 90, height: 90)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                name == "Add" ? Color.white.opacity(0.3) : Color.clear,
                                lineWidth: 1.5
                            )
                    )
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 40, weight: name == "Add" ? .light : .regular))
                            .foregroundColor(name == "Add" ? Color.white.opacity(0.4) : Color.white.opacity(0.9))
                    )

                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(name == "Add" ? Color.white.opacity(0.45) : Color.white.opacity(0.85))
            }
        }
    }
}

struct ProfileSettingButton: View {
    let icon: String
    let label: String

    var body: some View {
        Button {} label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color.white.opacity(0.65))
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(Color.white.opacity(0.45))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
