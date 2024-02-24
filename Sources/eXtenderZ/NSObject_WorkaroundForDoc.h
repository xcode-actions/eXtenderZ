/*
Copyright 2024 happn

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

#ifdef __DOC_WORKAROUND__

# import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

/* When <https://github.com/apple/swift-docc/issues/843> is implemented, we should get rid of this workaround altogether.
 * To do so:
 *   - Remove the `eXtenderZ-docWorkaround` target and scheme;
 *   - Remove this file and its implementation counterpart;
 *   - Fix the compilation errors (basically remove some imports and replace all instances of `NSObject_WorkaroundForDoc` and `HPN_NSObject` by `NSObject`);
 *   - Add the Documentation.docc file to the `eXtenderZ-dynamic` (or static) target;
 *   - If documentation generation is automated (not done at time of writing) use the `eXtenderZ-dynamic` (or static) scheme instead of `eXtenderZ-docWorkaround` one. */

/**
 An entity representing `NSObject` for the documentation.
 
 You should never (and cannot) use this entity when using the eXtenderZ.
 
 We had to define this for the documentation:
  all the extensions defined on `NSObject` are fully absent from the documentation as
  [Objective-C extensions are not supported in DocC](<https://github.com/apple/swift-docc/issues/843>). */
@interface NSObject_WorkaroundForDoc : NSObject

@end

NS_ASSUME_NONNULL_END

# define HPN_NSObject NSObject_WorkaroundForDoc

#else /* __DOC_WORKAROUND__ */

# define HPN_NSObject NSObject

#endif /* __DOC_WORKAROUND__ */
