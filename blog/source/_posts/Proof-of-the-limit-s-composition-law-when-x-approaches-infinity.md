title: Proof of the limit's composition law when x approaches infinity
date: 2016-10-01 13:20:32
tags: [limit, composition, proof]
categories: Math
thumbnail: https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/Limit-at-infinity-graph.png/306px-Limit-at-infinity-graph.png
---

**Theorem**: If $f(x)$ is continous at $b$ and $\lim\limits_{x \to\infty}g(x) = b$, then 

$$\lim\limits_{x \to \infty}f(g(x)) = f(b) = f(\lim\limits_{x\to \infty}g(x))\tag1$$

**Proof**:  Because $f(x)$ is continous at $b$, so 

$$\lim\limits_{x\to b}f(x) = f(b)\tag2$$

Because $$\lim\limits_{x\to\infty}g(x) = b \tag3$$

Combine $(1)$ and $(2)$, we get

$$\lim\limits_{x\to\infty}f(g(x)) = f(b)$$

Thus we proved the right side of equation $(1)$

Now we need to prove $$\lim\limits_{x \to \infty}f(g(x)) = f(b)\tag 4$$

Because 

$$\lim\limits_{x\to b}f(x) = f(b)$$

according to the definition of limit, $\forall \varepsilon > 0$, there exists a $\delta'$ such that for all $|x-b|<\delta'$, we have

$$|f(x) - f(b)| < \varepsilon\tag5$$

Replace $x$ with $g(x)$ in the above conclusion, we get

$\forall \varepsilon' > 0$, there exists a $\delta'$ such that for all $|g(x)-b|<\delta'$, we have 

$$|f(g(x)) - f(b)| < \varepsilon'\tag6$$

Note that although $f(x)$ needs to be defined and has a limited value (6) around $b$, $g(x)$ doesn't need to be so. For example, $g(x)$ may never be larger than $b$. But every time we get a $g(x)$ that meets the condition $|g(x) - b| < \delta'$, $|f(g(x)) - f(b)| < \varepsilon$ is guaranteed. 

Because

$$\lim\limits_{x \to \infty}g(x) = b$$

according to the definition of limit, $\forall \varepsilon > 0$, there exists a $\delta$ such that for all $x > \delta$ we have $|g(x) -b| < \varepsilon$

Let $\varepsilon = \delta'$, so $\forall x>\delta$, we have

$$|g(x) - b| < \delta'$$

Combine this with $(6)$, $\forall \varepsilon' > 0$, there exists $\delta$, whenever $x > \delta$, we have

$$|f(g(x)) - f(b)| < \varepsilon'$$

Which is exactly the definition of the limit

$$\lim\limits_{x \to \infty}f(g(x)) = f(b)$$

So we proved the left side of $(1)$ equation. So equation

$$\lim\limits_{x \to \infty}f(g(x)) = f(b) = f(\lim\limits_{x\to \infty}g(x))$$
 
 holds.
