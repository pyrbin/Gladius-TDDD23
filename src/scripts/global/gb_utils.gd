extends Node
# Return duplicates in an array
func find_duplicates_small(a):
    var duplicates = []
    for i in range(0, a.size()):
        for j in range(j+1, a.size()):
            if a[j] == a[i]:
                duplicates.append(j)
    return duplicates

func has_duplicates(a, ignore):
    var duplicates = []
    for i in range(0, a.size()):
        for j in range(j+1, a.size()):
            if a[j] == a[i] && a[j] != ignore:
                duplicates.append(j)
    return duplicates.size() > 0