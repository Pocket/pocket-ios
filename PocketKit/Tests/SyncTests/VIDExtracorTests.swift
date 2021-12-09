import XCTest
@testable import Sync


class VIDExtractorTests: XCTestCase {
    func test_youtubeVideoComponent_withVID_returnsExistingVID() {
        let vid = "1a2b3c4d5e6f7g"
        
        let component = VideoComponent(
            id: 1,
            type: .youtube,
            source: URL(string: "https://youtube.com/watch?v=\(vid)")!,
            vid: vid,
            width: nil,
            height: nil,
            length: nil
        )
        
        let extractedVID = VIDExtractor(component).vid
        XCTAssertEqual(extractedVID, vid)
    }
    
    func test_youtubeVideoComponent_withNoVID_andInvalidHost_returnsNil() {
        let component = VideoComponent(
            id: 1,
            type: .youtube,
            source: URL(string: "https://example.com/watch?v=1a2b3c4d5e6f7g")!,
            vid: nil,
            width: nil,
            height: nil,
            length: nil
        )
        
        let extractedVID = VIDExtractor(component).vid
        XCTAssertNil(extractedVID)
    }
    
    func test_youtubeVideoComponent_withNoVID_andValidSource_returnsVID() {
        let vid = "1a2b3c4d5e6f7g"
        let sources = [
            "https://youtube.com/watch?v=\(vid)",
            "https://youtube-nocookies.com/watch?v=\(vid)",
            "https://de.youtube.com/watch?v=\(vid)",
            
            "https://youtube.com/watch?vi=\(vid)",
            
            "https://youtube.com/embed/\(vid)",
            "https://youtube-nocookies.com/embed/\(vid)",
            
            "https://youtube.com/v/\(vid)",
            "https://youtube-nocookies.com/v/\(vid)",
            
            "https://m.youtube.com/\(vid)"
        ]
        
        for source in sources {
            let component = VideoComponent(
                id: 1,
                type: .youtube,
                source: URL(string: source)!,
                vid: nil,
                width: nil,
                height: nil,
                length: nil
            )
            
            let extractedVID = VIDExtractor(component).vid
            XCTAssertEqual(extractedVID, vid, "Source: \(component.source)")
        }
    }
}
