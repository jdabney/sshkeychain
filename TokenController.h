#import <Cocoa/Cocoa.h>
#import "Libs/SSHToken.h"
#import "SSHTool.h"

@interface TokenController : NSObject {
	
	NSMutableArray *tokens;
}

+ (TokenController *)sharedController;
- (NSString *)generateNewToken;
- (bool)generateNewTokenForTool:(SSHTool *)tool;
- (bool)checkToken:(NSString *)token;

@end
