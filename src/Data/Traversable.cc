#include "Traversable.hh"

define_symbol(acc);
define_symbol(fn);

namespace Data_Traversable {

  using namespace PureScript;

  static auto cons(const any& x) -> any {
    return [=](const any& xs) -> any {
      any::array result(cast<any::array>(xs));
      result.emplace_front(x);
      return result;
    };
  }

  template <typename T>
  static auto go(const any& acc,
                 const size_t currentLen,
                 const any::array& xs,
                 const T& buildFrom) -> any {
    if (currentLen == 0) {
      return any::map<2>{{ { symbol(acc), acc }, { nullptr, nullptr } }};
    } else {
      const auto last = xs[currentLen - 1];
      const auto fn = [=]() -> any {
        return go(buildFrom(last, acc), currentLen - 1, xs, buildFrom);
      };
      return any::map<2>{{ { symbol(fn), fn }, { nullptr, nullptr } }};
    }
  };

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
                         const any::array& array) -> any {
    const auto buildFrom = [=](const any& x, const any& ys) -> any {
      return apply(map(cons)(f(x)))(ys);
    };

    auto result = go(pure(any::array()), array.size(), array, buildFrom);
    while (result.contains(symbol(fn))) {
      result = result[symbol(fn)]();
    }
    return result[symbol(acc)];
  }

} // namespace Data_Traversable
