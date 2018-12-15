//
//  Twitch.swift
//  NewTwitchAPIWrapper
//
//  Created by Christopher Perkins on 12/14/18.
//

import Foundation

/// `Twitch` allows access to all New Twitch API functions.
///
/// [The complete API reference is available here](https://dev.twitch.tv/docs/api/reference/)
public class Twitch {

    /// `urlSessionForInstance` is a singleton for all Twitch API calls that will be used for.
    private static var urlSessionForInstance: URLSession = {
        return URLSession(configuration: URLSessionConfiguration())
    }()

    /// `RequestHeaderTypes` specifies the different types of headers that we'll use in our web
    /// requests
    private struct RequestHeaderTypes {
        static let post = "POST"
        static let get = "GET"
    }

    /// `getIfErrorOccurred` is a quick function used by URLTask Completion Handlers for determining
    /// if an error occurred during the web request.
    ///
    /// Errors are said to occur in four situations:
    /// 1. The data is nil
    /// 1. The error is NOT nil
    /// 1. The response is nil
    /// 1. The response status code is not 200
    ///
    /// - Parameters:
    ///   - data: The data received
    ///   - response: The response received
    ///   - error: The error received
    /// - Returns: Whether or not an error occured during the web request.
    private static func getIfErrorOccurred(data: Data?, response: URLResponse?,
                                           error: Error?) -> Bool {
        guard let response = response, data == nil || error != nil else {
            return true
        }
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
            return true
        }
        return false
    }

    /// Extension Analytics provides insight into the extensions that the authenticated user uses.
    /// These reports are viewable and downloadable via a URL that is returned as a response.
    ///
    /// [More information is available here](https://dev.twitch.tv/docs/insights/)
    public struct ExtensionAnalytics {

        /// The URL that will be used for all Extension Analytics calls.
        private static let url = URL(string: "https://api.twitch.tv/helix/analytics/extensions")!

        /// `WebRequestKeys` define the web request keys for both resolving results and sending
        /// requests for the `Get Extension Analytics` call of the New Twitch API.
        private struct WebRequestKeys {
            static let after = "after"
            static let endedAt = "ended_at"
            static let extensionId = "extension_id"
            static let first = "first"
            static let pagination = "pagination"
            static let startedAt = "started_at"
            static let type = "type"
            static let url = "URL"
        }

        /// `type` defines the different types of extension analytics reports.
        /// `overviewVersion1` returns analytics for the first 90 days, and `overviewVersion2`
        /// returns analytics from January 31st, 2018 to the current day.
        ///
        /// These reports are viewable and downloadable via a URL that is returned as a response.
        ///
        /// [A complete comparison is available here](https://dev.twitch.tv/docs/insights/)
        ///
        /// - overviewVersion1: The first version of extension analytics reports
        /// - overviewVersion2: The second version of extension analytics reports.
        public enum AnalyticsType: String {
            case overviewVersion1 = "overview_v1"
            case overviewVersion2 = "overview_v2"
        }

        /// `get` will run the `Get Extension Analytics` API call of the New Twitch API.
        ///
        /// [More information about the web call is available here](
        /// https://dev.twitch.tv/docs/api/reference/#get-extension-analytics)
        ///
        /// - Parameters:
        ///   - tokenManager: The TokenManager whose token should be used. Singleton by default.
        ///   - after: The pagination token of the call. This parameter is ignored if the
        /// `extensionId` parameter is specified.
        ///   - startedAt: The date after which all analytics should start after. `endedAt` must
        /// also be specified.
        ///   - endedAt: The date before which analytics should be gathered for. `startedAt` must
        /// also be specified.
        ///   - extensionId: The extension to gather analytics for. If this is specified, only the
        /// extension with the specified ID will be analyzed.
        ///   - first: The number of objects to retrieve.
        ///   - type: The type of report to gather.
        ///
        /// [More information available here](https://dev.twitch.tv/docs/insights/)
        public static func get(tokenManager: TwitchTokenManager = TwitchTokenManager.shared,
                               after: String? = nil, startedAt: Date? = nil, endedAt: Date? = nil,
                               extensionId: String? = nil, first: Int? = nil,
                               type: AnalyticsType? = nil) {
            var request = URLRequest(url: url)
            request.setValueToJSONContentType()
            request.httpBody =
                getParamaters(after: after, startedAt: startedAt, endedAt: endedAt,
                              extensionId: extensionId, first: first, type: type).getAsData()

            urlSessionForInstance.dataTask(with: request) { (data, response, error) in
                if Twitch.getIfErrorOccurred(data: data, response: response, error: error) {
                    // TODO: Unsuccessful Completion Call
                }
                // TODO: Parsing
            }
        }

        private static func getParamaters(after: String?, startedAt: Date?, endedAt: Date?,
                                          extensionId: String?, first: Int?,
                                          type: AnalyticsType?) -> [String: Any] {
            var parametersDictionary = [String: Any]()
            // TODO: Fill In
            return parametersDictionary
        }
    }

    /// Private initializer. The entire Twitch API can be accessed through static methods
    private init() { }
}

// MARK: - URLRequest Extensions

extension URLRequest {

    /// The application JSON value.
    private static let applicationJSONValue = "application/json"

    /// The Content-Type string key.
    private static let contentTypeString = "Content-Type"

    /// Sets the Content-Type of this URLRequest to use application/json.
    internal mutating func setValueToJSONContentType() {
        setValue(URLRequest.applicationJSONValue, forHTTPHeaderField: URLRequest.contentTypeString)
    }
}

// MARK: - Dictionary Extensions

extension Dictionary where Key == String, Value == Any {

    /// Converts the dictionary to its Data representation.
    ///
    /// - Returns: The Data representation of the Dictionary.
    internal func getAsData() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
}

// MARK: - Date Extensions

extension Date {

    /// `zuluDateFormatter` is a lazily-instantiated date formatter whose time zone is set to UTC
    /// and whose format is RFC 3339.
    ///
    /// The RFC 3339 format is "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    private static var zuluDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")!

        return dateFormatter
    }()

    /// `convertZuluDateStringToLocalDate` takes in a RFC 3339 Date `String` from the UTC time zone
    /// and converts it to a `Date` appropriate for the current time zone.
    ///
    /// The RFC 3339 format is "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    ///
    /// - Parameter dateString: The date string to convert
    /// - Returns: The date that was converted to from the input `dateString`
    internal static func convertZuluDateStringToLocalDate(_ dateString: String) -> Date? {
        return zuluDateFormatter.date(from: dateString)
    }

    /// `convertDateToZuluString` takes in a Date and converts it to an RFC 3339 formatted String in
    /// the UTC TimeZone.
    ///
    /// The RFC 3339 format is "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    ///
    /// - Parameter date: The `Date` to convert to a Zulu time `String`
    /// - Returns:
    internal static func convertDateToZuluString(_ date: Date) -> String {
        return zuluDateFormatter.string(from: date)
    }
}