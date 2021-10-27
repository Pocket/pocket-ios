import Foundation


extension DomainMetadata {
    func update(remote: DomainMetadataParts) {
        name = remote.name
        logo = remote.logo.flatMap(URL.init)
    }
}
