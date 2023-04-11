//
//  PKTPremiumUpsellManager.h
//  RIL
//
//  Created by Nik Zeltzer on 11/7/16.
//
//

@import Foundation;

@class PKTUserEventStore;
@class PKTUserEventTrace;
@class PKTJSONDAO;

#pragma mark - Type Definitions

typedef void (^PKTModalPresentation)(BOOL show);

typedef PKTModalPresentation __nonnull (^PKTModalPresentationGenerator)(UIViewController *__nonnull presenter, dispatch_block_t __nullable presentationEnded);

/**
 A block, that when triggered will use the provided view controller to present a premium upsell view.
 @param presenter The UIViewController in which the event's view is to be presented.
 @param show If YES, the view is to be presented; if NO, the view is to be dismissed.
 @param presentationEnded A block that the consumer is responsible for calling when presentation has completed (i.e., when the presented view has been dismissed)
 */
typedef void (^PKTUserEventPresentation)(UIViewController *__nonnull presenter, PKTUserEventTrace *__nonnull eventTrace, BOOL show, dispatch_block_t __nonnull presentationEnded);

/**
 A block that implements the logic for an upsell event. This block is responsible for consuming the input, and vending a PKTUserEventPresentation block, if the rule is satisfied.
 */

typedef BOOL (^PKTUserEventRule)(PKTUserEventTrace *__nonnull eventTrace);

/**
 A block that triggers an event. Triggering an upsell event will evaluate the trigger's rule. If the rule is satisfied, the trigger will return PKTModalPresentationGenerator, which
 can be used to present the event's presentation.
 */

typedef PKTModalPresentationGenerator __nonnull (^PKTUserEventTrigger)(void);

typedef void (^PKTUserEventAction)(PKTUserEventTrace *__nonnull eventTrace, dispatch_block_t __nonnull actionEnded);

typedef dispatch_block_t __nullable (^PKTUserEventEvaluate)(void);

#pragma mark - PKTUserEventStore

/**
 PKTUserEventStore is an abstract manager class for creating event triggers from rules and presentation block pairs that relate to user-generated events. The class primarily operates as a function generator, and can be confusing to parse because of the multiple type definitions. Here's a summary of behavior:
 
 1. The consumer creates an event trigger by providing a name, a rule, and a presentation. Each time the trigger is invoked, the rule will be evaluated. If the rule is satisfied, the trigger will vend a presentation generator. The presentation generator, (discussed further, supra) is a block that can be used to show or hide the event's presentation.
 2. Presentation Generators are used to bind the contents of the presentation that was provided with createEvent:rule:presentation:. When a presentation generator is invoked, the event store creates – and caches – a presentation block. This block is returned immediately from the generator, and can be used to show/hide the event's view. The caching is important: at any point before the presentation calls its finished() parameter, the presentation block can also be retrieved directly from the event store by key name (see, activePresentationForEventWithName:, supra). This is important: it allows you to decouple the code that used to create a presentation from the code that controls whether the presentation is being shown or hidden.
 */

@interface PKTUserEventStore : NSObject

/**
 Current bundle's identifier.
 */

@property (nonnull, nonatomic, readonly) NSString *bundleIdentifier;

/**
 An integer representing which 'open' an event trace corresponds to.
 */

@property (nonatomic, readonly) NSInteger openIndex;

/**
 An integer representing which 'launch' an event trace corresponds to.
 @note A 'launch' occurs each time application:didFinishLaunchingWithOptions: is called.
 */

@property (nonatomic, readonly) NSInteger launchIndex;

/**
 An NSString that can be used to distinguish event trace 'sessions' from one another.
 @note The is a proxy method for PKTSessionManager's current session identifier.
 */

@property (nonnull, nonatomic, readonly) NSString *sessionIdentifier;

/**
 NSString representation of current app build number.
*/

@property (nonnull, nonatomic, readonly) NSString *buildNumber;

/**
 NSString representation of the current app version.
 */

@property (nonnull, nonatomic, readonly) NSString *buildVersion;

/**
 NSString representation of the runtime environment
 */

@property (nonnull, nonatomic, readonly) NSString *environment;

/**
 @return The Shared PKTUserEventStore object, suitable for distributed use in a production application.
 @note Individual instances of PKTUserEventStore may be instantiated for testing purposes.
 */

+ (nonnull instancetype)sharedStore;

/**
 Create an event by pairing a unique event name with a PKTUserEventRule block and a PKTUserEventAction block.
 @param eventName The unique key that identifies this event.
 @param eventRule A PKTUserEventRule block that controls when an event should resolve in a presentation.
 @param action A PKTUserEventAction block that coordinates the action that should occur when the a the eventRule is satisfied.
 @discussion Use this method to create a user event from a rule and an action. This method is equally appropriate for use from within a concrete PKTUserEventStore subclass, or any other context.
 */


- (nonnull PKTUserEventEvaluate)createEvent:(nonnull NSString *)eventName
                                       rule:(nonnull PKTUserEventRule)eventRule
                                     action:(nonnull PKTUserEventAction)action;

/**
 Create an event by pairing a unique event name with a PKTUserEventRule block and a PKTUserEventPresentation block.
 @param eventName The unique key that identifies this event.
 @param eventRule A PKTUserEventRule block that controls when an event should resolve in a presentation.
 @param eventPresentation A PKTUserEventPresentation block that coordinates the the presentation that should occur when the a the eventRule is satisfied.
 @discussion Use this method to create a user event from a rule and a presentation. This method is equally appropriate for use from within a concrete PKTUserEventStore subclass, or any other context.
 */

- (nonnull PKTUserEventTrigger)createEvent:(nonnull NSString *)eventName
                                      rule:(nonnull PKTUserEventRule)eventRule
                              presentation:(nullable PKTUserEventPresentation)eventPresentation;

/**
 Vend the event block for a given name.
 @return The PKTUserEventTrigger block for a given user event. This block can be used to trigger an event.
 @param eventName The unique event name that was provided when the event was created with createEvent:rule:presentation.
 @discussion Use this method to record an event, passing in the optional context if appropriate. If the event's underlying rule is satisfied, the block will return a PKTUserEventPresentation block, which the consumer is responsible for using to handle the presentation of the upsell view.
 */

- (nullable PKTUserEventTrigger)eventWithName:(NSString *__nonnull)eventName;

/**
 Remove the event with the provided name.
 @param eventName The unique event name that was provided when the event was created with createEvent:rule:presentation.
 */

- (void)removeEventWithName:(NSString *__nonnull)eventName;

/**
 @return The PKTModalPresentation block for an active, ongoing, presentation – if any. Otherwise, returns nil.
 @param eventName The unique event name that was provided when the event was created with createEvent:rule:presentation.
 @note Use this method to dereference the presentation block for an ongoing presentation that was created in a different context (e.g., from within a different method, or class). If the presentation exists, the returned block can be used to end that presentation early.
 */

- (nullable PKTModalPresentation)activePresentationForEventWithName:(NSString *__nonnull)eventName;

/**
 Return configuration info for a given user event.
 @param eventName The unique event name that was provided when the event was created with createEvent:rule:presentation.
 @discussion This info object may be used to store configuration parameters, or A/B test group settings.
 */

- (nullable NSDictionary<NSString*, id<NSCoding>>*)eventInfo:(NSString *__nonnull)eventName;

/**
 Set an NSDictionary of configuration info for a given event name.
 @param eventName The unique event name that was provided when the event was created with createEvent:rule:presentation.
 @param eventInfo A NSDictionary of encodable key/value pairs that should be associated witht the corresponding event.
 */

- (void)setEventInfo:(nullable NSDictionary<NSString*, id<NSCoding>>*)eventInfo forEventWithName:(nonnull NSString *)eventName;

@end

#pragma mark - PKTUserEventIncident

/**
 PKTUserEventIncident wraps data representing the occurance a specific user event. What the event represents is left to the consumer to define.
 */

@interface PKTUserEventIncident : NSObject

/**
 NSInteger representing how many times the application had been launched when the incident was recorded.
 */

@property (nonatomic, readonly, assign) NSInteger launchIndex;

/**
 NSInteger representing how many times the application had been brought into the foreground when the incident was recorded.
 */

@property (nonatomic, readonly, assign) NSInteger openIndex;

/**
 NSString representation of the active session's identifier when the incident was recorded.
*/

@property (nullable, nonatomic, readonly, strong) NSString *sessionIdentifer;

/**
 NSString representing which version of the application was installed when the incident was recorded.
*/

@property (nullable, nonatomic, readonly, strong) NSString *buildVersion;

/**
 NSString representing the build number of the application when the incident was recorded.
 */

@property (nullable, nonatomic, readonly, strong) NSString *buildNumber;

/**
 @return NSArray of NSNumber integer representions reporting which 'open' an event corresponds to.
 NSDate representing the time that the event was recorded.
 */

@property (nonnull, nonatomic, readonly, strong) NSDate *date;

/**
 NSDictionary of custom key/value pairs that were associated with the incident when it was recorded.
 */

@property (nullable, nonatomic, readonly, strong) NSDictionary <NSString*, id<NSCoding>> *userInfo;

@property (nonatomic, readwrite, assign) BOOL actualized;

/**
 @return The value associated with a given key, if any. Otherwise, returns nil.
 */

- (nullable id<NSCoding>)valueForKey:(nonnull NSString *)key;

- (id _Nullable)objectForKeyedSubscript:(NSString *_Nonnull)key;

- (void)setObject:(id _Nullable)obj forKeyedSubscript:(NSString *_Nonnull)key;

@end

#pragma mark - PKTUserEventTrace

/**
 PKTUserEventTrace provides a persistable history for PKTUserEventIncident objects. It maintains a record of 'incidents' – arbitrary occurrences that are associated with a given event – across application launches.
 */

@interface PKTUserEventTrace : NSObject <NSCoding>

/**
 @return The unique event name that was provided when the event was created with PKTUserEventStore's createEvent:rule:presentation.
*/

@property (nonnull, nonatomic, readonly, copy) NSString *eventName;

/**
 @return NSInteger of PKTUserEventIncident objects associated with this event.
 */

@property (nonatomic, readonly, assign) NSInteger eventCount;

/**
 @return The custom context associated with this event trace, if any.
 */

@property (nullable, nonatomic, readonly, strong) NSDictionary <NSString*, id<NSCoding>> *userInfo;

/**
 @return NSArray of PKTUserEventIncident objects associted with this Trace.
 */

@property (nonnull, nonatomic, readonly, strong) NSArray <PKTUserEventIncident*> *incidents;

/**
 Set an arbitrary value for a given key. This key/value pair will be persisted across application launches, until the trace is 'reset'.
 */

- (void)setValue:(nullable id<NSCoding>)value forKey:(nonnull NSString *)key;

/**
 @return The value associated with a given key, if any. Otherwise, returns nil.
 */

- (nullable id<NSCoding>)valueForKey:(nonnull NSString *)key;

/**
 Increment the event trace.
 @param userInfo NSDictionary of values that should be associated with the incident.
 @discussion This adds a new event date to the dates array, and increments the event count.
 @note Use this method to update an event's history when a condition is met – e.g., some period of time has passed.
 */

- (nonnull PKTUserEventIncident *)increment:(nullable NSDictionary <NSString*, id<NSCoding>>*)userInfo;

/**
 Return the event preceding a given event.
 @param incident The event for which the preceding event should be returned.
 @return The preceding event, if any, otherwise nil.
 */

- (nullable PKTUserEventIncident *)previous:(nonnull PKTUserEventIncident *)incident;

/**
 Return the event following a given event.
 @param incident The event for which the subsequent event should be returned.
 @return The subsequent event, if any, otherwise nil.
 */

- (nullable PKTUserEventIncident *)next:(nonnull PKTUserEventIncident *)incident;

/**
 Reset the event trace to default values.
 @discussion This will delete all event incidents, and clear all custom key/value pairs associated with the trace.
 */

- (void)reset;

/**
 @return The PKTUserEventIncident for a given index, if any. If an incident doesn't exist for a given index, returns nil.
 */

- (nullable PKTUserEventIncident *)incidentAtIndex:(NSInteger)index;

/**
 @return the underlying JSONDAO used by PKTUserEventTrace for storage.
 */

+ (PKTJSONDAO *__nonnull)eventTracesStore;

/**
 @return PKTUserEventTrace object associated with eventName, if present in the eventTracesStore; otherwise, a new, empty
 PKTUserEventTrace that will be associated with the eventName.
 */

PKTUserEventTrace *__nonnull loadEventTrace(NSString *__nonnull eventName);

/**
 Persists a PKTUserEventTrace representing the persisted state of an event.
 @discussion Event trace are used to persist the state of an event over multiple application launches.
 */

void saveEventTrace(PKTUserEventTrace *__nonnull eventTrace);

/**
 Removes the PKTUserEventTrace associated with the given event name, if any.
 @discussion Event trace are used to persist the state of an event over multiple application launches.
 */

void deleteEventTrace(NSString *__nonnull eventName);

@end
