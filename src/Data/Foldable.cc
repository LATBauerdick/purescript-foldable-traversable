///////////////////////////////////////////////////////////////////////////////
//
// Module      :  Foldable.cc
// Copyright   :  (c) Andy Arvanitis 2015
// License     :  MIT
//
// Maintainer  :  Andy Arvanitis <andy.arvanitis@gmail.com>
// Stability   :  experimental
// Portability :
//
// Foldable FFI functions
//
///////////////////////////////////////////////////////////////////////////////
//
#include "Foldable.hh"

namespace Data_Foldable {

  using namespace PureScript;

  // foreign import foldrArray :: forall a b. (a -> b -> b) -> b -> Array a -> b
  //
  auto foldrArray(const any& f, const any& init, const any::array& xs) -> any {
    auto acc = any(init);
    for (auto it = xs.crbegin(), end = xs.crend(); it != end ; it++) {
      acc = f(*it)(acc);
    }
    return acc;
  }

  // foreign import foldlArray :: forall a b. (b -> a -> b) -> b -> Array a -> b
  //
  auto foldlArray(const any& f, const any& init, const any::array& xs) -> any {
    auto acc = any(init);
    for (auto it = xs.cbegin(), end = xs.cend(); it != end ; it++) {
      acc = f(acc)(*it);
    }
    return acc;
  }

}
