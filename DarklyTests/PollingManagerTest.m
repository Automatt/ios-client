//
//  Copyright © 2015 Catamorphic Co. All rights reserved.
//

#import "DarklyXCTestCase.h"
#import "PollingManager.h"
#import "DataManager.h"
#import "RequestManager.h"
#import <OCMock.h>

@interface PollingManagerTest : DarklyXCTestCase
@property (nonatomic) id requestManagerMock;
@end

@implementation PollingManagerTest
@synthesize dataManagerMock;
@synthesize requestManagerMock;

- (void)setUp {
    [super setUp];
    
    RequestManager *requestManager = [RequestManager sharedInstance];
    requestManagerMock = OCMPartialMock(requestManager);
    OCMStub([requestManagerMock performFeatureFlagRequest:[OCMArg isKindOfClass:[NSString class]]]);

    id requestManagerClassMock = OCMClassMock([RequestManager class]);
    OCMStub(ClassMethod([requestManagerClassMock sharedInstance])).andReturn(requestManagerClassMock);
 }

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [dataManagerMock stopMocking];
    [requestManagerMock stopMocking];
    [super tearDown];
}


- (void)testConfigPollingStates {
    // create the expectation with a nice descriptive message
    PollingManager *dnu =  [PollingManager sharedInstance];
    dnu.configurationTimerPollingInterval = 5; // for the purposes of the unit tests set it to 5 secs.
    [dnu startConfigPolling];
    
    NSInteger expectedValue = POLL_RUNNING;
    NSInteger actualValue = [dnu configPollingState];
    
    XCTAssertTrue(actualValue == expectedValue);

    [dnu pauseConfigPolling];
    
     expectedValue = POLL_PAUSED;
     actualValue = [dnu configPollingState];
    
    XCTAssertTrue(actualValue == expectedValue);

    [dnu stopConfigPolling];
    
     expectedValue = POLL_STOPPED;
     actualValue = [dnu configPollingState];
    
     XCTAssertTrue(actualValue == expectedValue);
}


- (void)testEventPollingStates {
    // create the expectation with a nice descriptive message
    PollingManager *dnu =  [PollingManager sharedInstance];
    dnu.eventTimerPollingInterval = 5; // for the purposes of the unit tests set it to 5 secs.
    [dnu startEventPolling];
    
    NSInteger expectedValue = POLL_RUNNING;
    NSInteger actualValue = [dnu eventPollingState];
    
    XCTAssertTrue(actualValue == expectedValue);
    
    [dnu pauseEventPolling];
    
    expectedValue = POLL_PAUSED;
    actualValue = [dnu eventPollingState];
    
    XCTAssertTrue(actualValue == expectedValue);
    
    [dnu stopEventPolling];
    
    expectedValue = POLL_STOPPED;
    actualValue = [dnu eventPollingState];
    
    XCTAssertTrue(actualValue == expectedValue);
}


// this unit tests the polling mechanism with the variable polling interval to be set....
- (void)testPolling {
    // create the expectation with a nice descriptive message
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for polling to start"];
    
    PollingManager *dnu =  [PollingManager sharedInstance];
    dnu.configurationTimerPollingInterval = 1; // for the purposes of the unit tests set it to 1 secs.
    [dnu startConfigPolling];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [dnu stopConfigPolling];
        NSInteger expectedValue = 5;
        NSInteger actualValue = [PollingManager configPollingCount];
        
        XCTAssertTrue(actualValue >= expectedValue, @"The returned value doesn't match the expected value.");
        [expectation fulfill];
        
    });
    
  
    // wait for the expectations to be called and timeout after some
    // predefined max time limit, failing the test automatically
    NSTimeInterval somePredefinedTimeout = 31;
    [self waitForExpectationsWithTimeout:somePredefinedTimeout handler:nil];
}

/*
- (void)waitForTimeInterval:(NSTimeInterval)delay
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:delay + 1 handler:nil];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
 */

@end
