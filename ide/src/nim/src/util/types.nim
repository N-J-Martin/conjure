import variable, setType, expression
export variable, setType, expression

# Constants

let maxIndex* = 4
let rootNodeId* = 0

# Exceptions
type
    InitException* = object of Exception

type
    CannotOpenEprimeException* = object of Exception
type
    CannotOpenMinionException* = object of Exception
type
    CannotOpenDatabaseException* = object of Exception
type
    EprimeParseException* = object of Exception
type
    MinionParseException* = object of Exception


# Responses

type SimpleDomainResponse* = ref object of RootObj
    changedNames*: seq[string]
    vars*: seq[Variable]

type ParentChild* = ref object of RootObj
    id*: int
    parentId*: int
    label*: string
    prettyLabel*: string
    childCount*: int
    isSolution*: bool
    isLeftChild*: bool
    decCount*: int

# type ChildResponse* = ref object of RootObj
#     nodeId*: int
#     children*: seq[int]
#     decendantCount*: int

type Node* = ref object of RootObj
    id*: int
    name*: string
    children*: seq[Node]

# Json

type TreeViewNode* = ref object of RootObj
    name*: string
    children*: seq[TreeViewNode]
