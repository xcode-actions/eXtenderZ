/*
Copyright 2019 happn
Copyright 2024 François Lamboley

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

#import "NSObject_WorkaroundForDoc.h"
#import "NSObject+Utils.h"



#define DEFAULT_BUFFER_LENGTH (16)

@implementation NSObject (XTZUtils)

+ (void)xtz_forwardInvocationLikeNil:(NSInvocation *)invocation
{
	if (invocation.methodSignature.methodReturnLength == 0)
		return;
	
	void *dynamicBuffer = NULL;
	char staticBuffer[DEFAULT_BUFFER_LENGTH] = {'\0'};
	
	void *ret = &staticBuffer;
	if (invocation.methodSignature.methodReturnLength > DEFAULT_BUFFER_LENGTH) {
		dynamicBuffer = calloc(invocation.methodSignature.methodReturnLength, 1);
		ret = dynamicBuffer;
	}
	
	[invocation setReturnValue:ret];
	
	/* Ok to free the buffer, setReturnValue: copies its content. */
	if (dynamicBuffer != NULL) free(dynamicBuffer);
}

- (nullable id)xtz_getAssociatedObjectWithKey:(void *)key
			  createIfNotExistWithBlock:(id (^_Nullable)(void))objectCreator
						 associationPolicy:(objc_AssociationPolicy)associationPolicy
{
	id ret = objc_getAssociatedObject(self, key);
	if (ret == nil && objectCreator != NULL) {
		@synchronized(self) {
			ret = objc_getAssociatedObject(self, key);
			if (ret == nil) {
				ret = objectCreator();
				objc_setAssociatedObject(self, key, ret, associationPolicy);
				
				/* In case associationPolicy is OBJC_ASSOCIATION_COPY for instance, we must get the new associated object. */
				ret = objc_getAssociatedObject(self, key);
			}
		}
	}
	
	return ret;
}

- (nullable id)xtz_getAssociatedObjectWithKey:(void *)key createIfNotExistWithBlock:(id (^_Nullable)(void))objectCreator
{
	return [self xtz_getAssociatedObjectWithKey:key createIfNotExistWithBlock:objectCreator associationPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (nullable id)xtz_getAssociatedObjectWithKey:(void *)key
{
	return [self xtz_getAssociatedObjectWithKey:key createIfNotExistWithBlock:NULL associationPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

#ifdef eXtenderZ_STATIC
void __xtz_linkNSObjectUtilsCategory(void) {
}
#endif

@end
