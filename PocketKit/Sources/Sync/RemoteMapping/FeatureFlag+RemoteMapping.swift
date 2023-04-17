import CoreData
import PocketGraph

extension FeatureFlag {

    func update(from remote: RemoteFeatureFlagAssignment) {
        name = remote.name
        assigned = remote.assigned
        variant = remote.variant
        payloadValue = remote.payload
    }
}
