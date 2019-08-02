
type
  BranchPair[T] = object
    then, otherwise: T

# This cannot be a template yet, buggy compiler...
template `|`*[T](a, b: T): BranchPair[T] = BranchPair[T](then: a, otherwise: b)

template `?`*[T](cond: bool; p: BranchPair[T]): T =
  (if cond: p.then else: p.otherwise)
