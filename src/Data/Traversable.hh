///////////////////////////////////////////////////////////////////////////////
//
// Module      :  Traversable.hh
// Copyright   :  (c) Andy Arvanitis 2015
// License     :  MIT
//
// Maintainer  :  Andy Arvanitis <andy.arvanitis@gmail.com>
// Stability   :  experimental
// Portability :
//
// Traversable FFI functions
//
///////////////////////////////////////////////////////////////////////////////
//
#ifndef Data_TraversableFFI_HH
#define Data_TraversableFFI_HH

#include "PureScript/PureScript.hh"

namespace Data_Traversable {

  using namespace PureScript;

  // foreign import traverseArrayImpl
  //   :: forall m a b
  //    . (m (a -> b) -> m a -> m b)
  //   -> ((a -> b) -> m a -> m b)
  //   -> (a -> m a)
  //   -> (a -> m b)
  //   -> Array a
  //   -> m (Array b)
  //
  auto traverseArrayImpl(const any& apply,
                         const any& map,
                         const any& pure,
                         const any& f,
                         const any::array& array) -> any;
}

#endif // Data_TraversableFFI_HH
