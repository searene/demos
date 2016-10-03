title: Proof of $$\lim_{x\rightarrow \infty} f(x)^{g(x)} = c^d$$
date: 2016-10-01 19:29:59
tags: [limit, math]
categories: Math
thumbnail: /images/Math_Business_sm.jpg
---

**Theorem**: 

$$c,\ d\in {\bf R},\  \lim_{x\rightarrow \infty} f(x)=c>0,\ \lim_{x\rightarrow \infty} g(x) =d>0$$

then

$$\lim_{x\rightarrow \infty} f(x)^{g(x)} = c^d$$

**Proof**: Because 

1. $y(x)=ln(x)$ is continuous at $x = c > 0$

2. $\lim\limits_{x\to \infty}f(x) = c$

according to the [composition law][1], we have

$$\lim\limits_{x \to \infty}lnf(x) = ln\lim\limits_{x \to \infty}f(x) = lnc$$

Because $\lim\limits_{x \to \infty}g(x) = d$, we have

$$\lim\limits_{x\to \infty}g(x)lnf(x) = \lim\limits_{x\to \infty}g(x)\cdot\lim\limits_{x \to \infty}lnf(x) = dlnc$$

Apply [composition law][1] again, we get

$$\lim\limits_{x\to \infty}f(x)^{g(x)} = \lim\limits_{x\to \infty}e^{g(x)lnf(x)} = e^{\lim\limits_{x\to \infty}g(x)lnf(x)} = e^{dlnc} = c^d$$


  [1]: http://math.oregonstate.edu/home/programs/undergrad/CalculusQuestStudyGuides/SandS/lHopital/limit_laws.html#composition_law
