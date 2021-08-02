// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum Alert {
    internal enum Action {
      /// OK
      internal static let ok = L10n.tr("Localizable", "alert.action.ok")
    }
    internal enum Error {
      /// Error
      internal static let title = L10n.tr("Localizable", "alert.error.title")
    }
  }

  internal enum Search {
    /// GitHub repositories
    internal static let title = L10n.tr("Localizable", "search.title")
    internal enum Empty {
      /// Start typing into the search bar
      internal static let message = L10n.tr("Localizable", "search.empty.message")
      /// We couldn’t find any repositories matching the given term
      internal static let noResult = L10n.tr("Localizable", "search.empty.noResult")
    }
    internal enum SearchBar {
      /// Search GitHub
      internal static let placeholder = L10n.tr("Localizable", "search.searchBar.placeholder")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
