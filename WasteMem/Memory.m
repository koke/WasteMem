//
//  Memory.m
//  WasteMem
//
//  Created by Jorge Bernal Ordovas on 24/01/2017.
//  Copyright © 2017 Jorge Bernal. All rights reserved.
//

#import "Memory.h"
#import <mach/mach.h>
#import <mach/mach_host.h>

typedef struct node {
    void *val;
    NSInteger size;
    struct node * next;
} node_t;

static node_t *stuff = NULL;


@implementation Memory
+ (MemoryStats)stats {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    host_page_size(host_port, &pagesize);

    vm_statistics_data_t vm_stat;

    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        NSLog(@"Failed to fetch vm statistics");
    }

    /* Stats in bytes */
    NSInteger mem_used = (vm_stat.active_count + vm_stat.wire_count) * pagesize;
    NSInteger mem_free = (vm_stat.free_count + vm_stat.inactive_count) * pagesize;
    NSInteger mem_total = mem_used + mem_free;
    MemoryStats stats = { mem_used, mem_free, mem_total };
    return stats;
}

+ (NSInteger)allocateBytes:(NSInteger)size {
    node_t *node;
    if (stuff == NULL) {
        stuff = calloc(1, sizeof(node_t));
        node = stuff;
    } else {
        node = stuff;
        // `O(n)`o! 😬
        while (node->next != NULL) {
            node = node->next;
        }
        node->next = calloc(1, sizeof(node_t));
        node = node->next;
    }
    node->val = calloc(1, size);
    while (size > 1024 && node->val == NULL) {
        size /= 2;
        node->val = malloc(size);
    }
    node->size = size;
    return size;
}

+ (NSInteger)freeAllTheThings {
    size_t freed = 0;
    node_t *node = stuff;
    if (node == NULL) {
        return freed;
    }
    while (node) {
        node_t *next = node->next;
        freed += node->size;
        free(node->val);
        free(node);
        node = next;
    }
    return freed;
}

@end
