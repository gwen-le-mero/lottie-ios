#import "LATestConcurrencyCrashController.h"
#import <Lottie/Lottie.h>

@interface LATestConcurrencyCrashController () {
	bool testRunning;
	int successCount;
}

@property (nonatomic, strong) NSMutableArray* testAnimations;

@end

static const int LOT_ANIM_COUNT = 10;
static const NSTimeInterval TEST_DELAY = 0.300;
static const int TEST_PASS_COUNT = 100000;

@implementation LATestConcurrencyCrashController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	testRunning = NO;
	self.testAnimations = [NSMutableArray array];
	
	CGFloat offsetY = 100;
	for (int i = 0; i < LOT_ANIM_COUNT; i++) {
		LOTAnimationView* anim  = [self prepareAnimView:offsetY];
		[self.testAnimations addObject:anim];
		offsetY += anim.bounds.size.height + 4 ;
	}
	
	self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
	
	[self createCloseButtonOnView:self.view];
	[self createStartTestButtonOnView:self.view];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self toggleAnimations];
}

- (LOTAnimationView*) prepareAnimView:(CGFloat) offsetY {
	LOTAnimationView* anim = [LOTAnimationView animationNamed:@"list_placeholder_anim"];
	anim.loopAnimation = true;
	
	[self.view addSubview:anim];
	anim.bounds = CGRectMake(0, 0, self.view.bounds.size.width -20 , 48);
	anim.center = CGPointMake(CGRectGetMidX(self.view.bounds), offsetY + 24);
	return anim;
}

- (void)createCloseButtonOnView:(UIView*)view {
	UIButton *closeButton_ = [UIButton buttonWithType:UIButtonTypeSystem];
	[closeButton_ setTitle:@"Close" forState:UIControlStateNormal];
	[closeButton_ addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:closeButton_];
	CGSize buttonSize = [closeButton_ sizeThatFits:view.bounds.size];
	closeButton_.frame = CGRectMake(10, 30, buttonSize.width, 50);
}

- (void)createStartTestButtonOnView:(UIView*)view {
	UIButton *startTestButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[startTestButton setTitle:@"Start Test" forState:UIControlStateNormal];
	[startTestButton addTarget:self action:@selector(startTest) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:startTestButton];
	CGSize buttonSize = [startTestButton sizeThatFits:view.bounds.size];
	CGFloat buttonX = view.bounds.size.width - (buttonSize.width + 10);
	startTestButton.frame = CGRectMake(buttonX, 30, buttonSize.width, 50);
}

- (void) startTest {
	//[self toggleAnimations];
	
	testRunning = !testRunning;
	
	if (testRunning) {
		successCount = 0;
		[NSThread detachNewThreadWithBlock:^{
			while (testRunning && (successCount < TEST_PASS_COUNT)) {
				[self toggleAnimationInDedicatedThread];
				NSLog(@"Test success %.3f%%", (100.0 * successCount / TEST_PASS_COUNT));
				
				[NSThread sleepForTimeInterval:TEST_DELAY];
			}
			testRunning = NO;
			if (TEST_PASS_COUNT == successCount) {
				NSLog(@"!!! Test PASSED !!!");
			}
	 }];
	 }
	/*
	LOTAnimationView* first = self.testAnimations[0];
	if (first.isAnimationPlaying) {
		[NSThread detachNewThreadWithBlock:^{
			for (int i =0; i < LOT_ANIM_COUNT; i++) {
				[self.testAnimations[i] pause];
			}
			
		}];
	} else {
		[NSThread detachNewThreadWithBlock:^{
			for (int i =0; i < LOT_ANIM_COUNT; i++) {
				[self.testAnimations[i] play];
			}
		}];
	}
 */
}

- (void) toggleAnimationInDedicatedThread {
	[NSThread detachNewThreadWithBlock:^{ [self toggleAnimations]; }];
}

- (void) toggleAnimations {
	for (int i = 0; i < LOT_ANIM_COUNT; i++) {
		LOTAnimationView* anim  = self.testAnimations[i];
		if (anim.isAnimationPlaying) {
			[anim pause];
		} else {
			[anim play];
		}
		successCount++;
	}
}

- (void)close {
	testRunning = NO;
	[self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
