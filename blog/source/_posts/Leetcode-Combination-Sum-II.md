title: 'Leetcode: Combination Sum II'
date: 2017-07-15 08:33:03
tags: [leetcode, algorithm]
categories: Coding
thumbnail: /images/combination.jpg
---

# Problem

Given a collection of candidate numbers (**C**) and a target number (**T**), find all unique combinations in **C** where the candidate numbers sums to **T**.

Each number in **C** may only be used **once** in the combination.

**Note:**

- All numbers (including target) will be positive integers.
- The solution set must not contain duplicate combinations.

For example, given candidate set `[10, 1, 2, 7, 6, 1, 5]` and target `8`, 
A solution set is: 

```
[
  [1, 7],
  [1, 2, 5],
  [2, 6],
  [1, 1, 6]
]
```

------

# Leetcode Link

https://leetcode.com/problems/combination-sum-ii/#/description

# Solution

This problem can be solved using DFS:

* Get the result starting with the **first** number
* Get the result starting with the **second** number
* ...
* Get the result starting with the **last** number

But we need to sort the array first in order to remove duplicate records.

```java
public class Solution {
    public List<List<Integer>> combinationSum2(int[] candidates, int target) {
        if(candidates == null || candidates.length == 0) {
            return new ArrayList<>();
        }
        Arrays.sort(candidates);
        return combinationSum2(candidates, target, new ArrayList<>(), 0);
    }

    private List<List<Integer>> combinationSum2(int[] candidates, int target, List<Integer> prefix, int startPos) {
        List<List<Integer>> result = new ArrayList<>();
        if(target == 0) {
            result.add(new ArrayList<>(prefix));
        } else if(target > 0){
            for (int i = startPos; i < candidates.length; i++) {
                if(i > startPos && candidates[i] == candidates[i - 1]) {
                    continue;
                }
                prefix.add(candidates[i]);
                List<List<Integer>> subResult = combinationSum2(candidates, target - candidates[i], prefix, i + 1);
                prefix.remove(prefix.size() - 1);

                result.addAll(subResult);
            }
        }
        return result;
    }
}
```



