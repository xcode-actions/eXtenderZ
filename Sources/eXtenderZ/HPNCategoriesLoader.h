/*
Copyright 2021 happn

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

@import Foundation;



#ifdef HPN_eXtenderZ_STATIC

NS_ASSUME_NONNULL_BEGIN

@interface HPNCategoriesLoader : NSObject

/* This method can be used in order to prevent the need for the `-ObjC` flag.
 * Simply call it before calling anything else in the library (before all the
 * `hpn_registerClass:asHelptenderForProtocol:` is probably the best place).
 *
 * Usually, for static xcframeworks containing category code, this flag is
 * required in order to avoid an `unrecognized selector sent to class` exception
 * when trying to use the method in one of the category. This was all and well
 * before SPM. Now we do have SPM, and this flag is unknown to it. Which means
 * it has to be defined as an “unsafe” flag. No big deal, you might say… and you
 * would be right! If you’re not writing a library… When you are, using an
 * unsafe flag is not really possible, as SPM will refuse to use a dependency
 * which has an unsafe flag instruction (unless the dep is declared using a
 * commit hash instead of a tag).
 * Using this method you can still have the eXtenderZ as a dependency in your
 * SPM library.
 *
 * A few links:
 *    - https://github.com/mapbox/mapbox-gl-native/issues/2966
 *    - https://github.com/mapbox/mapbox-gl-native/commit/7a38e568191a68e3311d36296e14c105b12c051c */
+ (void)loadCategories;

@end

NS_ASSUME_NONNULL_END

#endif
