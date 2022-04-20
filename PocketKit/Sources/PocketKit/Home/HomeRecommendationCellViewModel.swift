import Foundation
import Sync
import Combine


class HomeRecommendationCellViewModel {
    @Published
    private(set) var isSaved: Bool

    private var subscriptions: Set<AnyCancellable> = []

    let recommendation: Recommendation

    init(recommendation: Recommendation) {
        self.recommendation = recommendation
        isSaved = recommendation.item?.savedItem != nil

        recommendation.publisher(for: \.item?.savedItem)
            .removeDuplicates()
            .sink { [weak self] savedItem in
                self?.updateIsSaved(with: savedItem != nil)
            }.store(in: &subscriptions)

        recommendation.publisher(for: \.item?.savedItem?.isArchived)
            .compactMap({ $0 })
            .removeDuplicates()
            .sink { [weak self] isArchived in
                self?.updateIsSaved(with: isArchived == false)
            }.store(in: &subscriptions)
    }
}

extension HomeRecommendationCellViewModel {
    func updateIsSaved(with isSaved: Bool) {
        guard isSaved != self.isSaved else {
            return
        }

        self.isSaved = isSaved
    }
}

extension HomeRecommendationCellViewModel: Equatable {
    static func ==(lhs: HomeRecommendationCellViewModel, rhs: HomeRecommendationCellViewModel) -> Bool {
        return lhs.recommendation == rhs.recommendation
    }
}

extension HomeRecommendationCellViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(recommendation)
    }
}
