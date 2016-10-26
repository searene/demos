title: The empty set is the subset of any set
date: 2016-10-06 09:44:52
tags: set-thoery
categories: Math
thumbnail: /images/empty.jpg
---

The empty set is the subset of any set. This is true. Some people take it as a convention, but in fact, it can be explained.

According to the definition of $\subset$, 

$\varnothing\subset A\Leftrightarrow$ 

> $\forall x$, if $x\in\varnothing$, then $x\in A$. 

This is a vacuous truth, because the antecedent ($x\in\varnothing$) could never be true, so the conclusion always holds ($x\in A$). So $\varnothing\subset A$ holds.

Maybe you are thinking, OK, this is a vacuous truth, so maybe I can change it so that the following expression is also true.

$\forall x$, if $x\in\varnothing$, then $x\not\in A$. 

Then you could say, $\varnothing\subset A$ is false.

This is what I asked on [math.stackexchange.com](https://math.stackexchange.com/questions/1953218/is-the-empty-set-is-a-subset-of-any-set-a-convention?noredirect=1#comment4015040_1953218) the other day, and I read through all the answers and comments in it. Then I realized the above expression doesn't mean $\varnothing\not\subset A$, it just means $\varnothing\subset A^c$.

I think what $\varnothing\not\subset A$ means is

$\exists x, x\in\varnothing$ and $x\not\in A$

Since you can never find $x$ such that $x\in\varnothing$, so the condition could never be correct, so we don't have enough evidence to make the conclusion($\varnothing\not\subset A$).

Notice the whole expression itself(If there exists $x\in\varnothing$ such that $x\not\in A$, then we say $\varnothing\not\subset A$) is correct since it's a vacuous truth(the condition could never be true).

In fact

$\exists x, x\in\varnothing$ and $x\not\in A\Leftrightarrow$ $\varnothing\not\subset A$

Because 

$\exists x, x\in\varnothing$ and $x\not\in A$

is false, so 

$\varnothing\not\subset A$

 is false, which makes $\varnothing\subset A$ true.
