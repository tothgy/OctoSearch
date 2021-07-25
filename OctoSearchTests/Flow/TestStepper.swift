//
//  TestStepper.swift
//  InstructorTests
//

@testable import OctoSearch
import Foundation
import RxFlow
import RxCocoa

class TestStepper: Stepper {
    internal var steps = PublishRelay<Step>()
    
    var initialStep: Step = RxFlowStep.home
    
    func triggerStep(_ step: Step) {
        steps.accept(step)
    }
}
