#import "TunnelsView.h"

#import "PreferenceController.h"
#import "TunnelController.h"

/* Tunnel Controller. */
extern TunnelController *tunnelController;

@implementation TunnelsView

- (void)loadPreferences
{
	/* Get all tunnels. */
	tunnels = [[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:tunnelsString]] retain];
	
	if(!tunnels) {
		tunnels = [[[[NSMutableArray alloc] init] autorelease] retain];
	}

	tunnelIndex = -1;

	[tunnelTable setDataSource:self];
	[remotePortForwardTable setDataSource:self];
	[localPortForwardTable setDataSource:self];
}

- (void)closePreferences
{
	[tunnelTable deselectAll:self];
	
	[self saveTunnelDetails];
	[self hideTunnelDetails];
	[self savePreferences];
}

- (void)savePreferences
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:tunnels forKey:tunnelsString];
	[prefs synchronize];
}

/* Add a tunnel. */
- (IBAction)addTunnel:(id)sender
{
	int i;
	BOOL match = NO;
	
	for(i=0; i < [tunnels count]; i++) {
		if([[[tunnels objectAtIndex:i] objectForKey:@"TunnelName"] isEqualToString:@"New Tunnel"]) {
			match = YES;
		}
	}
	
	if(!match)
	{
		NSMutableDictionary *dict = [[[[NSMutableDictionary alloc] init] autorelease] retain];
		[dict setObject:@"New Tunnel" forKey:@"TunnelName"];
		
		[tunnels addObject:dict];
		[self updateUI];
		
		[self savePreferences];
		[tunnelController sync];
	}
}

/* Delete a tunnel. */
- (IBAction)delTunnel:(id)sender
{	
	int index;

	if(tunnelIndex < 0)
	{
		return;
	}

	index = tunnelIndex;

	[self hideTunnelDetails];

	[tunnelController removeTunnelWithName:[[tunnels objectAtIndex:index] objectForKey:@"TunnelName"]];
	[tunnels removeObjectAtIndex:index];

	[tunnelTable deselectAll:self];

	[self updateUI];
}

/* Add local port forward. */
- (IBAction)addLocalPortForward:(id)sender
{
	NSMutableDictionary *dict;
	int i;
	BOOL match = NO;
	
	if(tunnelIndex < 0)
	{
		return;
	}
	
	for(i=0; i < [localPortForwards count]; i++)
	{
		if([[[localPortForwards objectAtIndex:i] objectForKey:@"LocalPort"] isEqualToString:@"0"])
		{
			match = YES;
			break;
		}
	}

	if(!match) {
		dict = [[[NSMutableDictionary alloc] init] autorelease];
	
		[dict setObject:@"0" forKey:@"LocalPort"];
		[dict setObject:@"localhost" forKey:@"RemoteHost"];
		[dict setObject:@"0" forKey:@"RemotePort"];
		
		[localPortForwards addObject:dict];

		[self updateUI];
	
		[self savePreferences];
		[tunnelController sync];
	}
}

/* Delete local port forward. */
- (IBAction)delLocalPortForward:(id)sender
{
	if((tunnelIndex < 0) || ([localPortForwardTable selectedRow] < 0))
	{
		return;
	}	
	
	[localPortForwards removeObjectAtIndex:[localPortForwardTable selectedRow]];
	
	[self updateUI];
	
	[self savePreferences];
	[tunnelController sync];
}

/* Add remote port forward. */
- (IBAction)addRemotePortForward:(id)sender
{
	NSMutableDictionary *dict;
	int i;
	BOOL match = NO;
	
	if(tunnelIndex < 0)
	{
		return;
	}

	for(i=0; i < [remotePortForwards count]; i++)
	{
		if([[[remotePortForwards objectAtIndex:i] objectForKey:@"RemotePort"] isEqualToString:@"0"])
		{
			match = YES;
			break;
		}
	}

	if(!match) {
		dict = [[[NSMutableDictionary alloc] init] autorelease];
	
		[dict setObject:@"0" forKey:@"RemotePort"];
		[dict setObject:@"localhost" forKey:@"LocalHost"];
		[dict setObject:@"0" forKey:@"LocalPort"];
	
		[remotePortForwards addObject:dict];

		[self updateUI];
	
		[self savePreferences];
		[tunnelController sync];
	}
}

/* Delete remote port forward. */
- (IBAction)delRemotePortForward:(id)sender
{
	if((tunnelIndex < 0) || ([remotePortForwardTable selectedRow] < 0))
	{
		return;
	}	
	
	[remotePortForwards removeObjectAtIndex:[remotePortForwardTable selectedRow]];
	
	[self updateUI];
	
	[self savePreferences];
	[tunnelController sync];
}

/* Show tunnel details. */
- (void)showTunnelDetails:(int)index
{
	NSSize size = [view frame].size;
	
	if(tunnelIndex > -1)
	{
		[self saveTunnelDetails];
	}

	tunnelIndex = index;

	if([[tunnels objectAtIndex:tunnelIndex] objectForKey:@"LocalPortForwards"]) 
	{
		localPortForwards = [[NSMutableArray arrayWithArray:[[tunnels objectAtIndex:tunnelIndex] objectForKey:@"LocalPortForwards"]] retain];
	} 

	else 
	{
		localPortForwards = [[[[NSMutableArray alloc] init] autorelease] retain];
	}

	if([[tunnels objectAtIndex:tunnelIndex] objectForKey:@"RemotePortForwards"]) {
		remotePortForwards = [[NSMutableArray arrayWithArray:[[tunnels objectAtIndex:tunnelIndex] objectForKey:@"RemotePortForwards"]] retain];
	} else {
		remotePortForwards = [[[[NSMutableArray alloc] init] autorelease] retain];
	}

	if([[tunnels objectAtIndex:tunnelIndex] objectForKey:@"TunnelName"]) {
		[tunnelName setStringValue:[[tunnels objectAtIndex:tunnelIndex] objectForKey:@"TunnelName"]];
	} else {
		[tunnelName setStringValue:@"Tunnel Name"];
	}
	
	if([[tunnels objectAtIndex:tunnelIndex] objectForKey:@"TunnelHostname"]) {
		[tunnelHostname setStringValue:[[tunnels objectAtIndex:tunnelIndex] objectForKey:@"TunnelHostname"]];
	} else {
		[tunnelHostname setStringValue:@"some.ssh-server.com"];
	}
	
	if([[tunnels objectAtIndex:tunnelIndex] objectForKey:@"TunnelPort"]) {
		[tunnelPort setStringValue:[[tunnels objectAtIndex:tunnelIndex] objectForKey:@"TunnelPort"]];
	} else {
		[tunnelPort setStringValue:@"22"];
	}
	
	if([[tunnels objectAtIndex:tunnelIndex] objectForKey:@"TunnelUser"]) {
		[tunnelUser setStringValue:[[tunnels objectAtIndex:tunnelIndex] objectForKey:@"TunnelUser"]];
	}

	if([[tunnels objectAtIndex:tunnelIndex] objectForKey:@"Compression"]) {
		[tunnelCompression setState:YES];
	} else {
		[tunnelCompression setState:NO];
	}
		
	if([[tunnels objectAtIndex:tunnelIndex] objectForKey:@"LaunchOnAgentFilled"]) {
		[tunnelLaunchOnAgentFilled setState:YES];
	} else {
		[tunnelLaunchOnAgentFilled setState:NO];
	}

	if([[tunnels objectAtIndex:tunnelIndex] objectForKey:@"LaunchAfterSleep"]) {
		[tunnelLaunchAfterSleep setState:YES];
	} else {
		[tunnelLaunchAfterSleep setState:NO];
	}

	size.height = (192 + [tunnelDetailsView frame].size.height);
	
	[[PreferenceController preferenceController] resizeWindowToSize:size];
	[view addSubview:tunnelDetailsView];
}

/* Hide tunnel details. */
- (void)hideTunnelDetails
{
	NSSize size = [view frame].size;
	size.height = 192;

	tunnelIndex = -1;
	
	[tunnelDetailsView removeFromSuperview];
	[[PreferenceController preferenceController] resizeWindowToSize:size];
	
	[localPortForwards release];
	[remotePortForwards release];

	localPortForwards = nil;
	remotePortForwards = nil;
}

/* Save tunnel details. */
- (void)saveTunnelDetails
{
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];

	if(tunnelIndex < 0)
	{
		return;
	}
	
	
	if([[tunnelName stringValue] isEqualToString:@""]) { [tunnelName setStringValue:@"Some Tunnel"]; }
        if([[tunnelHostname stringValue] isEqualToString:@""]) { [tunnelHostname setStringValue:@"some.ssh-server.com"]; }
        if([[tunnelPort stringValue] isEqualToString:@""]) { [tunnelPort setStringValue:@"22"]; }
        if([[tunnelUser stringValue] isEqualToString:@""]) { [tunnelUser setStringValue:@"someuser"]; }
	
        if(![[[tunnels objectAtIndex:tunnelIndex] objectForKey:@"TunnelName"] isEqualToString:[tunnelName stringValue]])
        {
                [tunnelController changeTunnelName:[[tunnels objectAtIndex:tunnelIndex] objectForKey:@"TunnelName"]
                                            toName:[tunnelName stringValue]];
        }
	
        [dict setObject:[tunnelName stringValue] forKey:@"TunnelName"];
        [dict setObject:[tunnelHostname stringValue] forKey:@"TunnelHostname"];
        [dict setObject:[tunnelPort stringValue] forKey:@"TunnelPort"];
        [dict setObject:[tunnelUser stringValue] forKey:@"TunnelUser"];

	if([tunnelCompression state]) {
                [dict setObject:@"YES" forKey:@"Compression"];
        } else {
                [dict removeObjectForKey:@"Compression"];
        }
	
        if([tunnelLaunchOnAgentFilled state]) {
                [dict setObject:@"YES" forKey:@"LaunchOnAgentFilled"];
        } else {
                [dict removeObjectForKey:@"LaunchOnAgentFilled"];
        }
	
	if([tunnelLaunchAfterSleep state]) {
                [dict setObject:@"YES" forKey:@"LaunchAfterSleep"];
        } else {
                [dict removeObjectForKey:@"LaunchAfterSleep"];
        }
	
	[dict setObject:[NSArray arrayWithArray:localPortForwards] 
						forKey:@"LocalPortForwards"];
	[dict setObject:[NSArray arrayWithArray:remotePortForwards]
						forKey:@"RemotePortForwards"];

	[tunnels replaceObjectAtIndex:tunnelIndex withObject: dict];

        [self savePreferences];
	
        [tunnelController sync];
}

/* Update the UI. */
- (void)updateUI
{
	/* If the user selected a tunnel, enable the delTunnelButton. */
	if(([tunnelTable selectedRow] != -1) && ([tunnels count] > 0))
	{
		[delTunnelButton setEnabled:YES];

		if(tunnelIndex != [tunnelTable selectedRow]) {
			[self showTunnelDetails:[tunnelTable selectedRow]];
		}
	}
	
	else
	{
		[delTunnelButton setEnabled:NO];

		if(tunnelIndex > -1) {
			[self saveTunnelDetails];
			[self hideTunnelDetails];
		}
	}
	
	/* If the user selected a local port forward, enable the delLocalPortForwardButton. */
	if(([localPortForwardTable selectedRow] != -1) && ([localPortForwards count] > 0))
	{
		[delLocalPortForwardButton setEnabled:YES];
	}
	
	else
	{
		[delLocalPortForwardButton setEnabled:NO];
	}
	
	/* If the user selected a local port forward, enable the delLocalPortForwardButton. */
	if(([remotePortForwardTable selectedRow] != -1) && ([remotePortForwards count] > 0))
	{
		[delRemotePortForwardButton setEnabled:YES];
	}
	
	else
	{
		[delRemotePortForwardButton setEnabled:NO];
	}	

	[tunnelTable reloadData];
	[localPortForwardTable reloadData];
	[remotePortForwardTable reloadData];
}

/* Delegated methods from NSTableView. */

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	[self updateUI];
}

- (int)numberOfRowsInTableView:(NSTableView *)table
{
	if(table == tunnelTable)
	{
		return [tunnels count];
	}
	
	else if((table == localPortForwardTable) && (localPortForwards))
	{
		return [localPortForwards count];
	}
	
	else if((table == remotePortForwardTable) && (remotePortForwards))
	{
		return [remotePortForwards count];
	}
	
	return 0;
}

- (id)tableView:(NSTableView *)table objectValueForTableColumn:(NSTableColumn *)column row:(int)nr
{
	if((table == tunnelTable) && (tunnels) && ([tunnels count] > nr))
	{
		return [[tunnels objectAtIndex:nr] objectForKey:@"TunnelName"];
	}
	
	else if((table == localPortForwardTable) && (localPortForwards) && ([localPortForwards count] > nr))
	{
		if([[column identifier] isEqualToString:@"lport"])
		{
			return [[localPortForwards objectAtIndex:nr] objectForKey:@"LocalPort"];
		}
		
		else if([[column identifier] isEqualToString:@"rhost"])
		{
			return [[localPortForwards objectAtIndex:nr] objectForKey:@"RemoteHost"];
		}
		
		else if([[column identifier] isEqualToString:@"rport"])
		{
			return [[localPortForwards objectAtIndex:nr] objectForKey:@"RemotePort"];
		}
	}
	
	else if((table == remotePortForwardTable) && (remotePortForwards) && ([remotePortForwards count] > nr))
	{
		if([[column identifier] isEqualToString:@"rport"])
		{
			return [[remotePortForwards objectAtIndex:nr] objectForKey:@"RemotePort"];
		}
		
		else if([[column identifier] isEqualToString:@"lhost"])
		{
			return [[remotePortForwards objectAtIndex:nr] objectForKey:@"LocalHost"];
		}
		
		else if([[column identifier] isEqualToString:@"lport"])
		{
			return [[remotePortForwards objectAtIndex:nr] objectForKey:@"LocalPort"];
		}
	}
	
	return nil;
}

- (void)tableView:(NSTableView *)table setObjectValue:(id)object forTableColumn:(NSTableColumn *)column row:(int)row
{	
	int i;
	BOOL match = NO;

	if((!object) || (!table))
	{
		return;
	}
	
	if((table == localPortForwardTable) && (localPortForwards) && ([localPortForwards count] > 0))
	{
		for(i=0; i < [localPortForwards count]; i++)
		{
			if(([[column identifier] isEqualToString:@"lport"]) && 
				([[[localPortForwards objectAtIndex:i] objectForKey:@"LocalPort"] isEqualToString:object]))
			{
				match = YES;
				break;
			}
		}

		if((!match) && ([[column identifier] isEqualToString:@"lport"]))
		{
			[[localPortForwards objectAtIndex:row] setObject:object forKey:@"LocalPort"];
		}
		
		else if((!match) && ([[column identifier] isEqualToString:@"rhost"]))
		{
			[[localPortForwards objectAtIndex:row] setObject:object forKey:@"RemoteHost"];
		}
		
		else if((!match) && ([[column identifier] isEqualToString:@"rport"]))
		{
			[[localPortForwards objectAtIndex:row] setObject:object forKey:@"RemotePort"];
		}
		
		[localPortForwardTable deselectAll:self];
	}
	
	else if((table == remotePortForwardTable) && (remotePortForwards) && ([remotePortForwards count] > 0))
	{
		for(i=0; i < [remotePortForwards count]; i++)
		{
			if(([[column identifier] isEqualToString:@"rport"]) && 
				([[[remotePortForwards objectAtIndex:i] objectForKey:@"RemotePort"] isEqualToString:object]))
			{
				match = YES;
				break;
			}
		}

		if((!match) && ([[column identifier] isEqualToString:@"rport"]))
		{
			[[remotePortForwards objectAtIndex:row] setObject:object forKey:@"RemotePort"];
		}
		
		else if((!match) && ([[column identifier] isEqualToString:@"lhost"]))
		{
			[[remotePortForwards objectAtIndex:row] setObject:object forKey:@"LocalHost"];
		}
		
		else if((!match) && ([[column identifier] isEqualToString:@"lport"]))
		{
			[[remotePortForwards objectAtIndex:row] setObject:object forKey:@"LocalPort"];
		}
		
		[remotePortForwardTable deselectAll:self];
	}
}

- (BOOL)tableView:(NSTableView *)table shouldEditTableColumn:(NSTableColumn *)column row:(int)row
{
	if(table == tunnelTable)
	{
		return NO;
	}
	
	return YES;
}

@end
