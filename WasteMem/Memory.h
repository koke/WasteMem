//
//  Memory.h
//  WasteMem
//
//  Created by Jorge Bernal Ordovas on 24/01/2017.
//  Copyright © 2017 Jorge Bernal. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    NSInteger used;
    NSInteger free;
    NSInteger total;
} MemoryStats;

@interface Memory : NSObject
+ (MemoryStats)stats;
+ (NSInteger)allocateBytes:(NSInteger)size;
+ (NSInteger)freeAllTheThings;
@end
