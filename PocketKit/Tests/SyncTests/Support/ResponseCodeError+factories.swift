import Apollo
import Foundation


extension ResponseCodeInterceptor.ResponseCodeError {
    static func withStatusCode(_ statusCode: Int) -> Self {
        ResponseCodeInterceptor.ResponseCodeError.invalidResponseCode(
            response: HTTPURLResponse(
                url: URL(string: "http://example.com")!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            ),
            rawData: nil
        )
    }
}
