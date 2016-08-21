///////////////////////////////////////////////////////////////////////////////
//
// Module      :  Foldable.hh
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
#ifndef Data_FoldableFFI_HH
#define Data_FoldableFFI_HH

#include "PureScript/PureScript.hh"

namespace Data_Foldable {

  using namespace PureScript;

  // foreign import foldrArray :: forall a b. (a -> b -> b) -> b -> Array a -> b
  //
  auto foldrArray(const any& f, const any& init, const any::array& xs) -> any;

  // foreign import foldlArray :: forall a b. (b -> a -> b) -> b -> Array a -> b
  //
  auto foldlArray(const any& f, const any& init, const any::array& xs) -> any;

}

#endif // Data_FoldableFFI_HH
