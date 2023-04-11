//
//  PKTJSONPathTypes.h
//  RIL
//
//  Created by Nicholas Zeltzer on 4/25/17.
//
//

@import Foundation;

#ifndef PKTJSONPathTypes_h
#define PKTJSONPathTypes_h

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PKTJSONNodeType) {
    ROOT,
    MEMBER,
    ELEMENT,
    RECURSIVE_DESCENT,
    WILDCARD_MEMBER,
    WILDCARD_ELEMENT,
    ELEMENT_SET,
    ELEMENT_SLICE,
    MEMBER_SET
} ;

typedef NS_ENUM(NSInteger, PKTJSONObjectType) {
    PKTJSONObjectTypeUndefined,
    PKTJSONObjectTypeDictionary,
    PKTJSONObjectTypeArray,
    PKTJSONObjectTypeObject,
};

typedef struct _PKTJSONPathNode PKTJSONPathNode;

struct _PKTJSONPathNode {
    PKTJSONNodeType node_type;
    union {
        NSInteger element_index;
        char *_Nullable member_name;
        struct { NSInteger n_indices; NSInteger *_Nullable indices; } set;
        struct { NSInteger n_names; const char *_Nullable* _Nullable names; } members;
        struct { NSInteger start, end, step; } slice;
    } data;
};

typedef struct _PKTLList PKTLList;

struct _PKTLList {
    void * data;
    PKTLList *_Nullable next;
    PKTLList *_Nullable prev;
};

typedef struct _PKTJSONPath PKTJSONPath;

struct _PKTJSONPath {
    PKTLList *_Nullable nodes;
    bool is_compiled;
};

#pragma mark - Data Structures

PKTJSONPath * PKTJSONPathCreate(void);
void PKTJSONPathRelease(void * data);

PKTJSONPathNode * PKTJSONPathNodeCreate(void);
void PKTJSONPathNodeRelease(void * data);

PKTLList * PKTLLinkCreate(void * data);
void PKTLListRelease(PKTLList *_Nullable head, void (*free_func)(void *));

#pragma mark - Mutation

void PKTLListEnumerate(PKTLList *list, void (*func)(void *, void *), void * user_data);
PKTLList *PKTLListPrepend(PKTLList *_Nullable list, void * data);
void PKTLListAppend (PKTLList *list, void * data);
PKTLList *PKTLListReverse(PKTLList *list);

NS_ASSUME_NONNULL_END

#endif /* PKTJSONPathTypes_h */
