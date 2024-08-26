////
////  LiveActivitiesVM.swift
////  CPS Campus
////
////  Created by Rahim Malik on 1/4/23.
////
//
//import Foundation
//import ActivityKit
//import WidgetKit
//import SwiftUI
//import DynamicColor
//
//@available(iOS 16.1, *)
//struct ScheduleLiveActivityAttributes: ActivityAttributes {
//
//	public typealias ScheduleLiveActivityStatus = ContentState
//
//	public struct ContentState: Hashable {
//		var courses: [Course]
//		//		var receivedDate: Date
//	}
//}
//
////MARK: - CRUD Functions
//@available(iOS 16.1, *)
//func startScheduleLiveActivity(courses: [LocalCourse]) {
//	let scheduleLiveActivityAttributes = ScheduleLiveActivityAttributes()
//
//	let initialContentState = ScheduleLiveActivityAttributes.ScheduleLiveActivityStatus(courses: courses)
//
//	do {
//		let scheduleLiveActivity = try Activity<ScheduleLiveActivityAttributes>.request(
//			attributes: scheduleLiveActivityAttributes,
//			contentState: initialContentState,
//			pushType: nil)
//		print("Requested a Live Activity \(scheduleLiveActivity.id)")
//	} catch (let error) {
//		print("Error requesting Live Activity \(error.localizedDescription)")
//	}
//}
//
////func updateDeliveryPizza() {
////	Task {
////		let updatedDeliveryStatus = PizzaDeliveryAttributes.PizzaDeliveryStatus(driverName: "TIM 👨🏻‍🍳", estimatedDeliveryTime: Date().addingTimeInterval(60 * 60))
////
////		for activity in Activity<PizzaDeliveryAttributes>.activities{
////			await activity.update(using: updatedDeliveryStatus)
////		}
////	}
////}
////
////func stopDeliveryPizza() {
////	Task {
////		for activity in Activity<PizzaDeliveryAttributes>.activities{
////			await activity.end(dismissalPolicy: .immediate)
////		}
////	}
////}
////
////func showAllDeliveries() {
////	Task {
////		for activity in Activity<PizzaDeliveryAttributes>.activities {
////			print("Pizza delivery details: \(activity.id) -> \(activity.attributes)")
////		}
////	}
////}
//
////func converLocalCoursetoCourse(courses: [LocalCourse]) -> [Course] {
////	var output = [Course]()
////	for course in courses {
////		var course2 = Course(
////		course2.courseID = course.courseID
////		output.append(course2)
////	}
////	return output
////}
//
//@available(iOS 16.1, *)
//struct ScheduleLiveActivityWidget: Widget {
//
//	@Environment(\.colorScheme) var colorScheme
//
//	@Environment(\.managedObjectContext) private var viewContext
//	@FetchRequest(entity: Course.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Course.num, ascending: true)])
//	var courses: FetchedResults<Course>
//
//	@AppStorage("ScheduleBackups", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var scheduleBackups = [Block]()
//	@AppStorage("CommunityRole", store: UserDefaults(suiteName: "group.com.TheCollegePreparatorySchool.ScheduleApp")) var communityRole = ""
//
//	var body: some WidgetConfiguration {
//		ActivityConfiguration(for: ScheduleLiveActivityAttributes.self) { context in
//			VStack(alignment: .leading) {
//				Text(context.state.courses[0].name)
//				//				if let array = getWidgetBlockTomorrow(size: WidgetFamily.systemLarge, blocks: scheduleBackups, courses: converLocalCoursetoCourse(courses: context.state.courses), gradYear: communityRole) {
//				//					HStack {
//				//						ForEach(array, id: \.self) { block in
//				//							RoundedRectangle(cornerRadius: 10, style: .continuous)
//				//								.foregroundColor(block.freePeriod == true ? Color("SystemGray5") : Color(colorScheme == .dark ? UIColor(block.color).shaded(amount: 0.15) : UIColor(block.color).tinted(amount: 0.15)))
//				//						}
//				//					}
//				//				}
//			}
//		} dynamicIsland: { context in
//			DynamicIsland {
//				DynamicIslandExpandedRegion(.leading) {
//					Label("hi Pizzas", systemImage: "backpack.fill")
//						.font(.title2)
//				}
//				DynamicIslandExpandedRegion(.trailing) {
//					//								Label {
//					//									Text(timerInterval: context.state.estimatedDeliveryTime, countsDown: true)
//					//										.multilineTextAlignment(.trailing)
//					//										.frame(width: 50)
//					//										.monospacedDigit()
//					//										.font(.caption2)
//					//								} icon: {
//					//									Image(systemName: "timer")
//					//								}
//					//								.font(.title2)
//				}
//				DynamicIslandExpandedRegion(.center) {
//					//								Text("\(context.state.driverName) is on his way!")
//					//									.lineLimit(1)
//					//									.font(.caption)
//				}
//				DynamicIslandExpandedRegion(.bottom) {
//					//								Button {
//					//									// Deep link into the app.
//					//								} label: {
//					//									Label("Contact driver", systemImage: "phone")
//					//								}
//				}
//			} compactLeading: {
//				Label {
//					Text("Campus")
//				} icon: {
//					Image(systemName: "backpack.fill")
//				}
//				.font(.caption2)
//			} compactTrailing: {
//				//							Text(timerInterval: context.state.estimatedDeliveryTime, countsDown: true)
//				//								.multilineTextAlignment(.center)
//				//								.frame(width: 40)
//				//								.font(.caption2)
//			} minimal: {
//				//							VStack(alignment: .center) {
//				//								Image(systemName: "timer")
//				//								Text(timerInterval: context.state.estimatedDeliveryTime, countsDown: true)
//				//									.multilineTextAlignment(.center)
//				//									.monospacedDigit()
//				//									.font(.caption2)
//				//							}
//			}
//			.keylineTint(Color("AccentColor"))
//		}
//	}
//}
