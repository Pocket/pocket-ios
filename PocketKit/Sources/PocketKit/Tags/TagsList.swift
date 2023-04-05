import Sync
import Textile

class TagsList {
    func retrieveTagsList(excluding tags: [String], source: Source) -> [TagType] {
        guard allTagsCount(source: source) > 3 else { return allTags(excluding: tags, source: source) }
        let recentTags = recentTags(excluding: tags, count: 3, source: source)
        let sortedTags = sortedTags(excluding: tags + recentTags, count: 3, source: source)
        return recentTags.compactMap { TagType.recent($0) } + sortedTags.compactMap { TagType.tag($0) }
    }

    private func allTagsCount(source: Source) -> Int {
        return source.retrieveTags(excluding: [])?.count ?? 0
    }

    private func allTags(excluding tags: [String], source: Source) -> [TagType] {
        return source.retrieveTags(excluding: tags)?.compactMap { TagType.tag($0) } ?? []
    }

    private func recentTags(excluding tags: [String], count: Int, source: Source) -> [String] {
        return source.retrieveRecentTags(excluding: tags, count: count) ?? []
    }

    private func sortedTags(excluding tags: [String], count: Int, source: Source) -> [String] {
        return source.retrieveSortedTags(excluding: tags, count: count) ?? []
    }
}
