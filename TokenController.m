//
//  TokenController.m
//  SSHKeychain
//
//  Created by Bart Matthaei on 22-8-07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TokenController.h"

TokenController* sharedTokenController;

@implementation TokenController
- (id)init
{
	if(!(self = [super init]))
	{
		return nil;
	}
	
	tokens = [[NSMutableArray alloc] init];
	
	sharedTokenController = self;
	
	return self;
}

- (void)dealloc
{
	[tokens dealloc];
	
	[super dealloc];
}

+ (TokenController *)sharedController
{
if(!sharedTokenController) {
		return [[TokenController alloc] init];
	}
	
	return sharedTokenController;
}

- (bool)generateNewTokenForTool:(SSHTool *)tool
{
	NSString *token;
	
	if(tool == nil) return NO;
	token = [self generateNewToken];
	
	if(token == nil) return NO;

	[tool setEnvironmentVariable:@"SSHKeychainToken" withValue:token];

	return YES;
}

- (NSString *)generateNewToken
{
	SSHToken *token;
	
	token = [SSHToken randomToken];
	
	@synchronized(tokens)
	{
		if(token != nil)
		{
			[tokens addObject:token];		
			return [token getToken];
		}
	}
	return nil;
}

- (bool)checkToken:(NSString *)token
{
	SSHToken *aToken;
	BOOL check = NO;
	
	@synchronized(tokens)
	{
		for (aToken in tokens)
		{
			if ([[aToken getToken] isEqualTo:token] && [aToken isValid])
			{
				check = YES;
			
			}
		}
		[tokens removeAllObjects];	
	}
	return check;
}

@end
