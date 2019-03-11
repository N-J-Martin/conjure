import unittest, intsets
import util/setType

suite "Included":

    test "empty":
        let oSet = newOSet("s")
        check(oSet.getPrettyIncluded() == "int()")

    test "1":
        let oSet = newOSet("s")
        oSet.includeInSet(1)
        check(oSet.getPrettyIncluded() == "int(1)")

    test "26,28,31..32":
        let oSet = newOSet("s")
        oSet.includeInSet(26)
        oSet.includeInSet(28)
        oSet.includeInSet(31)
        oSet.includeInSet(32)
        check(oSet.getPrettyIncluded() == "int(26,28,31..32)")

    test "1..10":
        let oSet = newOSet("s")

        for i in countUp(1,10):
            oSet.includeInSet(i)
        
        check(oSet.getPrettyIncluded() == "int(1..10)")

    test "1,3,5":
        let oSet = newOSet("s")
        oSet.includeInSet(1)
        oSet.includeInSet(3)
        oSet.includeInSet(5)
        check(oSet.getPrettyIncluded() == "int(1,3,5)")

    test "1..5,8,11":
        let oSet = newOSet("s")

        for i in countUp(1,5):
            oSet.includeInSet(i)
        oSet.includeInSet(8)
        oSet.includeInSet(11)
        check(oSet.getPrettyIncluded() == "int(1..5,8,11)")

    test "1..5,10..20":
        let oSet = newOSet("s")

        for i in countUp(1,5):
            oSet.includeInSet(i)
        for i in countUp(10,20):
            oSet.includeInSet(i)
        check(oSet.getPrettyIncluded() == "int(1..5,10..20)")

    test "1..5,8,10..20,69":
        let oSet = newOSet("s")

        for i in countUp(1,5):
            oSet.includeInSet(i)
        oSet.includeInSet(8)
        for i in countUp(10,20):
            oSet.includeInSet(i)
        oSet.includeInSet(69)
        check(oSet.getPrettyIncluded() == "int(1..5,8,10..20,69)")


# suite "NotExcluded":
#     test "1..10":
#         let oSet = newOSet("s")

#         for i in countUp(1,10):
#             oSet.notExcluded.incl(i)
        
#         check(oSet.getPrettyNotExcluded() == "int(1..10)")

#     test "1,3,5":
#         let oSet = newOSet("s")
#         oSet.notExcluded.incl(1)
#         oSet.notExcluded.incl(3)
#         oSet.notExcluded.incl(5)
#         check(oSet.getPrettyNotExcluded() == "int(1,3,5)")

#     test "1..5,8,11":
#         let oSet = newOSet("s")

#         for i in countUp(1,5):
#             oSet.notExcluded.incl(i)
#         oSet.notExcluded.incl(8)
#         oSet.notExcluded.incl(11)
#         check(oSet.getPrettyNotExcluded() == "int(1..5,8,11)")

#     test "1..5,10..20":
#         let oSet = newOSet("s")

#         for i in countUp(1,5):
#             oSet.notExcluded.incl(i)
#         for i in countUp(10,20):
#             oSet.notExcluded.incl(i)
#         check(oSet.getPrettyNotExcluded() == "int(1..5,10..20)")

#     test "1..5,8,10..20,69":
#         let oSet = newOSet("s")

#         for i in countUp(1,5):
#             oSet.notExcluded.incl(i)
#         oSet.notExcluded.incl(8)
#         for i in countUp(10,20):
#             oSet.notExcluded.incl(i)
#         oSet.notExcluded.incl(69)
#         check(oSet.getPrettyNotExcluded() == "int(1..5,8,10..20,69)")
