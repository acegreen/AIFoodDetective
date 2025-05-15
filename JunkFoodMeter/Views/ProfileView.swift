import SwiftUI
//import Inject

struct ProfileView: View {
//    @ObserveInjection var inject

    // MARK: - State
    @State private var selectedActivity: ActivityType = .viewed
    @State private var selectedTime: TimeFilter = .week

    // MARK: - Enums
    enum ActivityType: String, CaseIterable {
        case viewed = "Viewed"
        case scanned = "Scanned"
        case liked = "Liked"
        case reviewed = "Reviewed"
    }
    enum TimeFilter: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Top Section: Username, Avatar, Settings
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                ProfileAvatarView()
                                VStack(alignment: .leading) {
                                    Text("Ace Thinker")
                                        .font(.title2.bold())
                                        .foregroundColor(.white)
                                    Button("Edit profile") {
                                        // Edit action
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    // Stats Row
                    HStack(spacing: 32) {
                        ProfileStatView(title: "LIKES", value: "1")
                        ProfileStatView(title: "LISTS", value: "3")
                        ProfileStatView(title: "ING. PREF.", value: "0")
                    }
                    .padding(.horizontal)

                    // Activity Stats
                    HStack(spacing: 32) {
                        ProfileStatView(title: "YOUR VIEWS", value: "3")
                        ProfileStatView(title: "YOUR BADGES", value: "0", icon: "star.fill", iconColor: .white)
                        ProfileStatView(title: "YOUR REVIEWS", value: "0", icon: "text.bubble.fill", iconColor: .white)
                        ProfileStatView(title: "REVIEW LIKES", value: "0", icon: "hand.thumbsup.fill", iconColor: .white)
                    }
                    .padding(.horizontal)

                    // Activities Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Activities")
                                .font(.headline)
                                .foregroundColor(.white)
                            Image(systemName: "info.circle")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        // Activity Tabs
                        HStack(spacing: 12) {
                            ForEach(ActivityType.allCases, id: \.self) { type in
                                Button {
                                    selectedActivity = type
                                } label: {
                                    Text(type.rawValue)
                                        .font(.subheadline.bold())
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 16)
                                        .border(.white)
                                        .background(selectedActivity == type ? Color.white.opacity(0.3): Color.clear)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }

                        VStack(alignment: .center) {
                            
                        // Time Filter
                        HStack(spacing: 12) {
                            ForEach(TimeFilter.allCases, id: \.self) { filter in
                                Button {
                                    selectedTime = filter
                                } label: {
                                    Text(filter.rawValue)
                                        .font(.subheadline)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 12)
                                        .background(selectedTime == filter ? Color.white.opacity(0.3) : Color.clear)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        // Date Range
                        Text("May 9, 2025 - May 15, 2025")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.top, 4)
                        }
                        // Bar Chart Placeholder
                        ProfileBarChartView()
                            .frame(maxWidth: .infinity, maxHeight: 120)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.systemBackground)
            .navigationTitle("@DirtyThinker-5842869")
            .navigationBarTitleDisplayMode(.inline)
            .whiteNavigationTitle()
            .navigationBarItems(trailing: settingsButton)
        }
    }

    private var settingsButton: some View {
        Button {
            // Settings action
        } label: {
            Image(systemName: "gearshape")
                .font(.title2)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Subviews

struct ProfileAvatarView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.green)
                .frame(width: 64, height: 64)
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .foregroundColor(.white)
            // Add overlay heart if needed
        }
    }
}

struct ProfileStatView: View {
    let title: String
    let value: String
    var icon: String? = nil
    var iconColor: Color = .white

    var body: some View {
        VStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

struct ProfileBarChartView: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(0..<7) { i in
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 4)
                        .fill(i == 0 ? Color.white : Color.white.opacity(0.2))
                        .frame(width: 18, height: i == 0 ? 60 : 10)
                    Text(["Fri", "Sat", "Sun", "Mon", "Tue", "Wed", "Thu"][i])
                        .font(.caption2)
                        .foregroundColor(.white)
                }
            }
        }
    }
}
