#import "GoogleAnalyticsBuilder.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAILogger.h"
#import "GAITrackedViewController.h"
#import "GAITracker.h"

NSString *GACustomKey(GACustom input) {
    NSArray *arr = @[
      @"dimension1", @"dimension2", @"dimension3", @"dimension4", @"dimension5",
      @"dimension6", @"dimension7", @"dimension8", @"dimension9", @"dimension10",
      @"dimension11", @"dimension12", @"dimension13", @"dimension14", @"dimension15",
      @"dimension16", @"dimension17", @"dimension18", @"dimension19", @"dimension20",
      @"dimension21", @"dimension22", @"dimension23", @"dimension24", @"dimension25",
      @"dimension26", @"dimension27", @"dimension28", @"dimension29", @"dimension30",
      @"dimension31", @"dimension32", @"dimension33", @"dimension34", @"dimension35",
      @"dimension36", @"dimension37", @"dimension38", @"dimension39", @"dimension40",
      @"dimension41", @"dimension42", @"dimension43", @"dimension44", @"dimension45",
      @"dimension46", @"dimension47", @"dimension48", @"dimension49", @"dimension50",
      @"dimension51", @"dimension52", @"dimension53", @"dimension54", @"dimension55",
      @"dimension56", @"dimension57", @"dimension58", @"dimension59", @"dimension60",
      @"dimension61", @"dimension62", @"dimension63", @"dimension64", @"dimension65",
      @"dimension66", @"dimension67", @"dimension68", @"dimension69", @"dimension70",
      @"dimension71", @"dimension72", @"dimension73", @"dimension74", @"dimension75",
      @"dimension76", @"dimension77", @"dimension78", @"dimension79", @"dimension80",
      @"dimension81", @"dimension82", @"dimension83", @"dimension84", @"dimension85",
      @"dimension86", @"dimension87", @"dimension88", @"dimension89", @"dimension90",
      @"dimension91", @"dimension92", @"dimension93", @"dimension94", @"dimension95",
      @"dimension96", @"dimension97", @"dimension98", @"dimension99", @"dimension100",
      @"dimension101", @"dimension102", @"dimension103", @"dimension104", @"dimension105",
      @"dimension106", @"dimension107", @"dimension108", @"dimension109", @"dimension110",
      @"dimension111", @"dimension112", @"dimension113", @"dimension114", @"dimension115",
      @"dimension116", @"dimension117", @"dimension118", @"dimension119", @"dimension120",
      @"dimension121", @"dimension122", @"dimension123", @"dimension124", @"dimension125",
      @"dimension126", @"dimension127", @"dimension128", @"dimension129", @"dimension130",
      @"dimension131", @"dimension132", @"dimension133", @"dimension134", @"dimension135",
      @"dimension136", @"dimension137", @"dimension138", @"dimension139", @"dimension140",
      @"dimension141", @"dimension142", @"dimension143", @"dimension144", @"dimension145",
      @"dimension146", @"dimension147", @"dimension148", @"dimension149", @"dimension150",
      @"dimension151", @"dimension152", @"dimension153", @"dimension154", @"dimension155",
      @"dimension156", @"dimension157", @"dimension158", @"dimension159", @"dimension160",
      @"dimension161", @"dimension162", @"dimension163", @"dimension164", @"dimension165",
      @"dimension166", @"dimension167", @"dimension168", @"dimension169", @"dimension170",
      @"dimension171", @"dimension172", @"dimension173", @"dimension174", @"dimension175",
      @"dimension176", @"dimension177", @"dimension178", @"dimension179", @"dimension180",
      @"dimension181", @"dimension182", @"dimension183", @"dimension184", @"dimension185",
      @"dimension186", @"dimension187", @"dimension188", @"dimension189", @"dimension190",
      @"dimension191", @"dimension192", @"dimension193", @"dimension194", @"dimension195",
      @"dimension196", @"dimension197", @"dimension198", @"dimension199", @"dimension200",

      @"metric1", @"metric2", @"metric3", @"metric4", @"metric5",
      @"metric6", @"metric7", @"metric8", @"metric9", @"metric10",
      @"metric11", @"metric12", @"metric13", @"metric14", @"metric15",
      @"metric16", @"metric17", @"metric18", @"metric19", @"metric20",
      @"metric21", @"metric22", @"metric23", @"metric24", @"metric25",
      @"metric26", @"metric27", @"metric28", @"metric29", @"metric30",
      @"metric31", @"metric32", @"metric33", @"metric34", @"metric35",
      @"metric36", @"metric37", @"metric38", @"metric39", @"metric40",
      @"metric41", @"metric42", @"metric43", @"metric44", @"metric45",
      @"metric46", @"metric47", @"metric48", @"metric49", @"metric50",
      @"metric51", @"metric52", @"metric53", @"metric54", @"metric55",
      @"metric56", @"metric57", @"metric58", @"metric59", @"metric60",
      @"metric61", @"metric62", @"metric63", @"metric64", @"metric65",
      @"metric66", @"metric67", @"metric68", @"metric69", @"metric70",
      @"metric71", @"metric72", @"metric73", @"metric74", @"metric75",
      @"metric76", @"metric77", @"metric78", @"metric79", @"metric80",
      @"metric81", @"metric82", @"metric83", @"metric84", @"metric85",
      @"metric86", @"metric87", @"metric88", @"metric89", @"metric90",
      @"metric91", @"metric92", @"metric93", @"metric94", @"metric95",
      @"metric96", @"metric97", @"metric98", @"metric99", @"metric100",
      @"metric101", @"metric102", @"metric103", @"metric104", @"metric105",
      @"metric106", @"metric107", @"metric108", @"metric109", @"metric110",
      @"metric111", @"metric112", @"metric113", @"metric114", @"metric115",
      @"metric116", @"metric117", @"metric118", @"metric119", @"metric120",
      @"metric121", @"metric122", @"metric123", @"metric124", @"metric125",
      @"metric126", @"metric127", @"metric128", @"metric129", @"metric130",
      @"metric131", @"metric132", @"metric133", @"metric134", @"metric135",
      @"metric136", @"metric137", @"metric138", @"metric139", @"metric140",
      @"metric141", @"metric142", @"metric143", @"metric144", @"metric145",
      @"metric146", @"metric147", @"metric148", @"metric149", @"metric150",
      @"metric151", @"metric152", @"metric153", @"metric154", @"metric155",
      @"metric156", @"metric157", @"metric158", @"metric159", @"metric160",
      @"metric161", @"metric162", @"metric163", @"metric164", @"metric165",
      @"metric166", @"metric167", @"metric168", @"metric169", @"metric170",
      @"metric171", @"metric172", @"metric173", @"metric174", @"metric175",
      @"metric176", @"metric177", @"metric178", @"metric179", @"metric180",
      @"metric181", @"metric182", @"metric183", @"metric184", @"metric185",
      @"metric186", @"metric187", @"metric188", @"metric189", @"metric190",
      @"metric191", @"metric192", @"metric193", @"metric194", @"metric195",
      @"metric196", @"metric197", @"metric198", @"metric199", @"metric200"

    ];
    return (NSString *)[arr objectAtIndex:input];
}

NSString *GAHitKey(GAHit input) {
    NSArray *arr = @[
      @"uid",
      @"camp_url",
      @"title",
      @"category",
      @"action",
      @"label",
      @"value",
      @"ni"
    ];
    return (NSString *)[arr objectAtIndex:input];
}

void GAData_Nilset(NSDictionary *dict){
    @try {
        id<GAITracker> mTracker = [[GAI sharedInstance] defaultTracker];
        NSError* error;
        for(NSString *key in dict){
            if([key containsString:@"dimension"]){
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]" options:NSRegularExpressionCaseInsensitive  error:&error];
                NSString *idx = [regex stringByReplacingMatchesInString:key options:0 range:NSMakeRange(0, [key length]) withTemplate:@""];
                [mTracker set:[GAIFields customDimensionForIndex:[idx integerValue]] value:nil];
            }
            if([key containsString:@"metric"]){
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]" options:NSRegularExpressionCaseInsensitive  error:&error];
                NSString *idx = [regex stringByReplacingMatchesInString:key options:0 range:NSMakeRange(0, [key length]) withTemplate:@""];
                [mTracker set:[GAIFields customMetricForIndex:[idx integerValue]] value:nil];
            }
        }
        [mTracker set:kGAIScreenName value:nil];
        [mTracker set:kGAIUserId value:nil];
    }
    @catch (NSException *e) {
        NSLog(@"Exception: %@", e);
    }
}

void GADataSend_Screen(NSDictionary *GAInfo){
    NSError* error;
    id<GAITracker> mTracker = [[GAI sharedInstance] defaultTracker];
    [mTracker set:kGAIHitType value:@"screenview"];
    GAIDictionaryBuilder *eventBuilder = [[GAIDictionaryBuilder alloc]init];
    for(NSString *key in GAInfo){
        NSString *value = [GAInfo valueForKey:key];
        if(value != nil && [value length] > 0){
            if([key.lowercaseString containsString:@"dimension"]){
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]" options:NSRegularExpressionCaseInsensitive  error:&error];
                NSString *idx = [regex stringByReplacingMatchesInString:key options:0 range:NSMakeRange(0, [key length]) withTemplate:@""];
                [mTracker set:[GAIFields customDimensionForIndex:[idx integerValue]] value:value];
            }
            if([key.lowercaseString containsString:@"metric"]){
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]" options:NSRegularExpressionCaseInsensitive  error:&error];
                NSString *idx = [regex stringByReplacingMatchesInString:key options:0 range:NSMakeRange(0, [key length]) withTemplate:@""];
                [mTracker set:[GAIFields customMetricForIndex:[idx integerValue]] value:value];
            }
            if([key.lowercaseString isEqual:@"uid"]){ [mTracker set:kGAIUserId  value:value]; }
            if([key.lowercaseString isEqual:@"title"]){ [mTracker set:kGAIScreenName value:value]; }
            if([key.lowercaseString isEqual:@"camp_url"]){ [eventBuilder setCampaignParametersFromUrl:value]; }
            if([key.lowercaseString isEqual:@"ni"] && [[GAInfo valueForKey:key]  isEqual:@"1"]){ [eventBuilder set:value forKey:kGAINonInteraction]; }
        }
    }
    NSDictionary *hitParamsDict = [eventBuilder build];
    [mTracker send:[[[GAIDictionaryBuilder createScreenView] setAll:hitParamsDict] build]];
    GAData_Nilset(GAInfo);
}

void GADataSend_Event(NSDictionary *GAInfo){
    NSError* error;
    NSString *category;//생략
    NSString *action;//버튼
    NSString *label;//화면이름
    NSString *event_value;
    id<GAITracker> mTracker = [[GAI sharedInstance] defaultTracker];
    [mTracker set:kGAIHitType value:@"event"];
    GAIDictionaryBuilder *eventBuilder = [[GAIDictionaryBuilder alloc] init];
    for(NSString *key in GAInfo){
        NSString *value = [GAInfo valueForKey:key];
        if(value != nil && [value length] > 0){
            if([key.lowercaseString containsString:@"dimension"]){
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]" options:NSRegularExpressionCaseInsensitive  error:&error];
                NSString *idx = [regex stringByReplacingMatchesInString:key options:0 range:NSMakeRange(0, [key length]) withTemplate:@""];
                [mTracker set:[GAIFields customDimensionForIndex:[idx integerValue]] value:value];
            }
            if([key.lowercaseString containsString:@"metric"]){
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]" options:NSRegularExpressionCaseInsensitive  error:&error];
                NSString *idx = [regex stringByReplacingMatchesInString:key options:0 range:NSMakeRange(0, [key length]) withTemplate:@""];
                [mTracker set:[GAIFields customMetricForIndex:[idx integerValue]] value:value];
            }
            if([key.lowercaseString isEqual:@"uid"]){ [mTracker set:kGAIUserId  value:value]; }
            if([key.lowercaseString isEqual:@"title"]){ [mTracker set:kGAIScreenName value:value]; }
            if([key.lowercaseString isEqual:@"camp_url"]){ [eventBuilder setCampaignParametersFromUrl:value]; }
            if([key.lowercaseString isEqual:@"category"]){ category = value; }
            if([key.lowercaseString isEqual:@"action"]){ action = value; }
            if([key.lowercaseString isEqual:@"label"]){ label = value; }
            if([key.lowercaseString isEqual:@"value"]){ event_value = value;}
            if([key.lowercaseString isEqual:@"ni"] && [[GAInfo valueForKey:key]  isEqual:@"1"]){ [eventBuilder set:@"1" forKey:kGAINonInteraction]; }
        }
    }
    NSDictionary *hitParams = [eventBuilder build];
    [mTracker send:[[[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:event_value != nil ?@([event_value integerValue]): nil ] setAll:hitParams] build] ];
    GAData_Nilset(GAInfo);
}
