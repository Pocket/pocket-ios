import CoreData
import PocketGraph

extension Annotations {
    typealias RemoteAnnotations = AnnotationParts.Annotations

    convenience init?(fragment: AnnotationParts, context: NSManagedObjectContext) {
        guard let remote = fragment.annotations else {
            return nil
        }

        self.init(context: context)
        update(remote: remote)
    }

    func update(remote: RemoteAnnotations) {
        guard let context = managedObjectContext else {
            return
        }

        highlights = remote.highlights.flatMap {
            $0.compactMap {
                $0.flatMap {
                    let highlight = Highlight(context: context)
                    highlight.update(remote: $0)
                    return highlight
                }
            }
        }.flatMap(NSOrderedSet.init)
    }
}
