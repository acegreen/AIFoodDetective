import SwiftUI
//import Inject

struct ProfileSignedInView: View {
    //    @ObserveInjection var inject
    @Environment(ProductListManager.self) var productListManager

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
        VStack(alignment: .leading, spacing: 24) {
            // Top Section: Username, Avatar, Settings
            HStack {
                ProfileAvatarView()
                VStack(alignment: .leading) {
                    Text("Ace Thinker")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    Button("Edit profile") {
                        // Edit action
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                }
            }

            // Activity Stats
            HStack(spacing: 24) {
                let scanned = productListManager.systemLists.first?.products.count ?? 0
                ProfileStatView(title: "SCANS", value: "\(scanned)", icon: "plus.viewfinder", iconColor: .primary)
                ProfileStatView(title: "LIKES", value: "0", icon: "hand.thumbsup.fill", iconColor: .primary)
                ProfileStatView(title: "COMMENTS", value: "0", icon: "text.bubble.fill", iconColor: .primary)
                ProfileStatView(title: "SHARES", value: "0", icon: "square.and.arrow.up.fill", iconColor: .primary)
            }
            .padding(.horizontal)
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
                .foregroundColor(.primary)
            // Add overlay heart if needed
        }
    }
}

struct ProfileStatView: View {
    let title: String
    let value: String
    var icon: String? = nil
    var iconColor: Color = .primary

    var body: some View {
        VStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.primary)
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
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
                        .fill(i == 0 ? Color.primary : Color.primary.opacity(0.2))
                        .frame(width: 18, height: i == 0 ? 60 : 10)
                    Text(["Fri", "Sat", "Sun", "Mon", "Tue", "Wed", "Thu"][i])
                        .font(.caption2)
                        .foregroundColor(.primary)
                }
            }
        }
    }
}
