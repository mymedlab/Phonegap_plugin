//
//  TCPlugin.h
//  Twilio Client plugin for PhoneGap
// 
//  Copyright 2012 Stevie Graham.
//

#import "TCPlugin.h"

@interface TCPlugin() {
    TCDevice     *_device;
    TCConnection *_connection;
    NSMutableArray *_nameArray;
    NSString     *_callback;
    UITableView *userListTbl;
    
}

@property(nonatomic, strong) TCDevice     *device;
@property(nonatomic, strong) NSString     *callback;
@property(nonatomic, strong) NSMutableArray     *nameArray;
@property(nonatomic, strong) UITableView *userListTbl;
@property(atomic, strong)    TCConnection *connection;

-(void)javascriptCallback:(NSString *)event;
-(void)javascriptCallback:(NSString *)event withArguments:(NSDictionary *)arguments;
-(void)javascriptErrorback:(NSError *)error;


@end

@implementation TCPlugin

@synthesize device     = _device;
@synthesize callback   = _callback;
@synthesize connection = _connection;
@synthesize nameArray = _nameArray;
@synthesize userListTbl= _userListTbl;


# pragma mark device delegate method

-(void)device:(TCDevice *)device didStopListeningForIncomingConnections:(NSError *)error {
    
    [self javascriptErrorback:error];
}



-(void)device:(TCDevice *)device didReceiveIncomingConnection:(TCConnection *)connection {
    
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Incoming Call" message:nil delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
    
    
   NSLog(@"didReceiveIncomingConnection%@",[connection parameters]);    
    _connection = [connection retain];
    [_connection accept];    
    [self javascriptCallback:@"onincoming"];
}

-(void)device:(TCDevice *)device didReceivePresenceUpdate:(TCPresenceEvent *)presenceEvent {
    NSString *available = [NSString stringWithFormat:@"%d", presenceEvent.isAvailable];
    NSDictionary *object = [NSDictionary dictionaryWithObjectsAndKeys:presenceEvent.name, @"from", available, @"available", nil];
    self.userListTbl=[[UITableView alloc]initWithFrame:CGRectMake(30, 280, 200, 200)];
    self.userListTbl.dataSource=self;
    self.userListTbl.delegate=self;   
    [self.userListTbl setAllowsSelection:YES];   
   
    [self.viewController.view addSubview:self.userListTbl];
     [self.nameArray addObject:[object objectForKey:@"from"]];
    NSLog(@"presence user%@",self.nameArray);
    
    [self javascriptCallback:@"onpresence" withArguments:object];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"count%d",[self.nameArray count]);
    return [self.nameArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
   
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
       
    }
    
        cell.textLabel.text=[self.nameArray objectAtIndex:indexPath.row];  
  
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[self.nameArray objectAtIndex:indexPath.row],@"client", nil];
   
    NSLog(@"Name Selected%@",dict);

    [self connect:nil withDict:dict];
}

-(void)deviceDidStartListeningForIncomingConnections:(TCDevice *)device
{
    
    // What to do here? The JS library doesn't have an event for this.
    
    // Disable sounds. was getting EXC_BAD_ACCESS
                
    self.device.incomingSoundEnabled   = YES;
    self.device.outgoingSoundEnabled   = YES;
    self.device.disconnectSoundEnabled = YES;
    
    NSLog(@"Start Listening");
}

# pragma mark connection delegate methods

-(void)connection:(TCConnection*)connection didFailWithError:(NSError*)error {
    [self javascriptErrorback:error];
}

-(void)connectionDidStartConnecting:(TCConnection*)connection {
    self.connection = connection;    
    
    NSLog(@"Connection Started");
    
}

-(void)connectionDidConnect:(TCConnection*)connection {
    NSLog(@"TCPlugin connection method");
    self.connection = connection;
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"You Are Connected" message:nil delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
    [self javascriptCallback:@"onconnect"];
    if([connection isIncoming]) [self javascriptCallback:@"onaccept"];
}

-(void)connectionDidDisconnect:(TCConnection*)connection {
    
    NSLog(@"Connection Disconnected");
    
    self.connection = connection;    
    
    [self javascriptCallback:@"ondevicedisconnect"];
 
    
    [self javascriptCallback:@"onconnectiondisconnect"];
}

# pragma mark javascript device mapper methods
//A method for taking capability token and response to js for ready status....

-(void)deviceSetup:(NSMutableArray *)arguments withDict:(NSMutableDictionary*)options
{
    self.callback = [arguments pop];
    self.device = [[TCDevice alloc] initWithCapabilityToken:[arguments pop] delegate:self];
    
    // Disable sounds. was getting EXC_BAD_ACCESS
    self.device.incomingSoundEnabled   = YES;
    self.device.outgoingSoundEnabled   = YES;
    self.device.disconnectSoundEnabled = YES;
    
    
    self.nameArray=[[NSMutableArray alloc]init];
    NSLog(@"devicesetup options%@%@%@",options,arguments,self.device.description);
    NSLog(@"callback value%@",self.callback);
    NSLog(@"Hello, this is a native function called from PhoneGap/Cordova!");    
    NSLog(@"It Kriti Konungo...");           
    [self javascriptCallback:@"onready"];
}

-(void)connect:(NSArray *)arguments withDict:(NSMutableDictionary *)options {
    
    NSLog(@"options dict%@%@",options,arguments);
    
    [self.device connect:options delegate:self];
}

-(void)disconnectAll:(NSArray *)arguments withDict:(NSMutableDictionary *)options {
    NSLog(@"disconnectAll");
    [self.device disconnectAll];
}

-(void)deviceStatus:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString *state;
    
    NSLog(@"device status%u",[self.device state]);
    
    //UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Device Status" message:[] delegate:<#(id)#> cancelButtonTitle:<#(NSString *)#> otherButtonTitles:<#(NSString *), ...#>, nil]
    switch ([self.device state])
    {
        case TCDeviceStateBusy:
            state = @"busy";
           
            break;
            
        case TCDeviceStateReady:
            state = @"ready";
            break;
            
        case TCDeviceStateOffline:
            state = @"offline";
            break;
            
        default:
            break;        
    }
     UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Device Status" message:state delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:state];    
 
    [self performSelectorOnMainThread:@selector(writeJavascript:) withObject:[result toSuccessCallbackString:[arguments pop]] waitUntilDone:NO];
}


# pragma mark javascript connection mapper methods
-(void)acceptConnection:(NSArray *)arguments withDict:(NSMutableDictionary *)options {
    NSLog(@"conection accept");
    [self.connection accept];
}

-(void)disconnectConnection:(NSArray *)arguments withDict:(NSMutableDictionary *)options {
    NSLog(@"disconnectConnection");
    [self.connection disconnect];
}

-(void)muteConnection:(NSArray *)arguments withDict:(NSMutableDictionary *)options {
    if(self.connection.isMuted) {
        self.connection.muted = NO;
    } else {
        self.connection.muted = YES;
    }
}

-(void)sendDigits:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    [self.connection sendDigits:[arguments pop]];
}

-(void)connectionStatus:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString *state;
    NSLog(@"Connection status%u",[self.connection state]);
    switch ([self.connection state]) {
        case TCConnectionStateConnected:
            state = @"open";
            break;            
        case TCConnectionStateConnecting:
            state = @"connecting";
            break;            
        case TCConnectionStatePending:
            state = @"Connection Pending";
            break;            
        case TCConnectionStateDisconnected:
            state = @"closed";        
        default:
            break;        
    }
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Device Status" message:state delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:state];
    [self performSelectorOnMainThread:@selector(writeJavascript:) withObject:[result toSuccessCallbackString:[arguments pop]] waitUntilDone:NO];
}

# pragma mark private methods

-(void)javascriptCallback:(NSString *)event withArguments:(NSDictionary *)arguments
{
    NSDictionary *options   = [NSDictionary dictionaryWithObjectsAndKeys:event, @"callback", arguments, @"arguments", nil];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:options];
    result.keepCallback     = [NSNumber numberWithBool:YES];
    
    NSLog(@"Options Dictionary%@",options);
    
    [self performSelectorOnMainThread:@selector(writeJavascript:) withObject:[result toSuccessCallbackString:self.callback] waitUntilDone:NO];      
    
}
-(void)javascriptCallback:(NSString *)event
{
        [self javascriptCallback:event withArguments:nil];
}




-(void)javascriptErrorback:(NSError *)error
{
    NSDictionary *object    = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription], @"message", nil];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:object];
    result.keepCallback     = [NSNumber numberWithBool:YES];
    
    [self performSelectorOnMainThread:@selector(writeJavascript:) withObject:[result toErrorCallbackString:self.callback] waitUntilDone:NO];   
}

@end