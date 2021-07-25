//
//  ApplicationAssembly.swift
//  OctoSearch
//
//  Created by Malnas Peter  on 2020. 06. 10..
//  Copyright © 2020. E-Educatio Zrt. All rights reserved.
//

import Foundation
import Swinject
import EventKit
import RxSwift
import CoreLocation
import AVFoundation

class ApplicationAssembly: Assembly {

    // swiftlint:disable:next function_body_length
    func assemble(container: Container) {
        container.register(Theme.self) { _ in
            return AppTheme()
        }.inObjectScope(.container)

        container.register(UserRepositoryProtocol.self) { _ in
            return UserRepository()
        }
        .inObjectScope(.container)
        .initCompleted({ (resolver, _) in
            _ = resolver.get(MetadataStoreProtocol.self)
        })

        container.register(LogoutHandlerProtocol.self) { _ in
            return LogoutHandler()
        }.inObjectScope(.container)
        
        container.register(MetadataStoreProtocol.self) { _ in
            return MetadataStore()
        }.inObjectScope(.container)
        
        container.register(NowProtocol.self) { _ in
            Now()
        }.inObjectScope(.container)

        container.register(CalendarServiceProtocol.self) { _ in
            return CalendarService()
        }.inObjectScope(.container)

        container.register(EventStoreProtocol.self) { _ in
            return EKEventStore()
        }.inObjectScope(.container)

        container.register(SettingsStoreProtocol.self) { _ in
            return SettingsStore()
        }.inObjectScope(.container)

        container.register(URLOpenerProtocol.self) { _ in
            return UIApplication.shared
        }.inObjectScope(.container)

        container.register(SchedulerType.self) { _ in
            return MainScheduler.instance
        }.inObjectScope(.container)
        
        container.register(CLLocationManagerProtocol.self) { _ in
            return CLLocationManager()
        }.inObjectScope(.container)

        container.register(LocationManagerProtocol.self) { _ in
            return LocationManager()
        }.inObjectScope(.container)

        container.register(UNUserNotificationCenterProtocol.self) { _ in
            return UNUserNotificationCenter.current()
        }.inObjectScope(.container)

        container.register(LocalNotificationRepositoryProtocol.self) { _ in
            return LocalNotificationRepository()
        }.inObjectScope(.container)

        container.register(URLHandlerProtocol.self) { _ in
            return URLHandler()
        }.inObjectScope(.container)

        container.register(AppointmentRepositoryProtocol.self) { _ in
            return AppointmentRepository()
        }.inObjectScope(.container)

        container.register(DialerPresenterProtocol.self) { _ in
            return DialerPresenter()
        }.inObjectScope(.container)
        container.register(MailComposerFactoryProtocol.self) { _ in
            return MailComposerFactory()
        }.inObjectScope(.container)

        container.register(ComposerPresenterProtocol.self) { _ in
            return ComposerPresenter()
        }.inObjectScope(.container)

        container.register(ContactStudentHandlerProtocol.self) { _ in
            return ContactStudentHandler()
        }.inObjectScope(.container)

        container.register(MailComposeViewControllerProtocol.self) { _ in
            return MailComposeViewController()
        }.inObjectScope(.container)

        container.register(TimetableMapperProtocol.self) { _ in
            return TimetableMapper()
        }.inObjectScope(.container)

        container.register(ToastPresenterProtocol.self) { _ in
            return ToastPresenter()
        }.inObjectScope(.transient)

        container.register(FirebaseAnalyticsProtocol.self) { _ in
            return FirebaseAnalytics()
        }.inObjectScope(.container)

        container.register(FirebaseCrashlyticsProtocol.self) { _ in
            return FirebaseCrashlytics()
        }.inObjectScope(.container)

        container.register(AnalyticsServiceProtocol.self) { _ in
            return AnalyticsService()
        }.inObjectScope(.container)

        container.register(AppointmentReminderManagerProtocol.self) { _ in
            return AppointmentReminderManager()
        }.inObjectScope(.container)

        container.register(VatCalculatorProtocol.self) { _ in
            return VatCalculator()
        }.inObjectScope(.container)

        container.register(RecordingManagerProtocol.self) { _ in
            return RecordingManager()
        }.inObjectScope(.transient)

        container.register(AVAudioRecorderProtocol.self) { _ in
            let recorderSettings = RecordingManager.recorderSettings
            do {
                let fileUrl = RecordingManager.getRecordingFileUrl()
                return try AVAudioRecorder(url: fileUrl, settings: recorderSettings)
            } catch {
                preconditionFailure("""
                    Error initializing Audio Recorder:
                    \(error)
                    with settings: \(recorderSettings)
                    """)
            }
        }.inObjectScope(.transient)

        container.register(AudioPlayerBuilderProtocol.self) { _ in
            return AudioPlayerBuilder()
        }.inObjectScope(.container)

        container.register(AVAudioSessionProtocol.self) { _ in
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default)
            } catch {
                preconditionFailure("Error setting up Audio Session: \(error)")
            }
            return session
        }.inObjectScope(.container)

        container.register(FileManagerProtocol.self) { _ in
            return FileManager.default
        }.inObjectScope(.container)
    }
}
