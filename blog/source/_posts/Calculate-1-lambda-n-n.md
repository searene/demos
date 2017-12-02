title: Calculate $$\lim\limits_{n\to\infty}(1-\frac{\lambda_n}n)^n$$
date: 2016-09-30 21:49:00
tags: math
categories: Math
thumbnail: http://www.codeforest.net/wp-content/uploads/2010/11/lambda.jpg
---

I came upon the calculation of $\lim\limits_{n\to\infty}(1-\frac{\lambda_n}n)^n$ when I was reviewing Poisson distribution. Notice that $\lambda_n = np_n(n\in\mathbb{Z}_{\geq 0}, 0\leq p \leq 1)$ and $\lim\limits_{n\to\infty}\lambda_n = \lambda(\lambda\in\mathbb{R})$.

So how to calculate it? The first thought that came to my mind was that

$$\lim\limits_{n\to\infty}(1 + \frac1 n)^n = e \tag 1$$

So replace $n$ with $-n$, I got

$$\lim\limits_{n\to\infty}(1 - \frac1 n)^n = \frac1 e \tag 2$$

Then I have no clue about what to do next, I'm not even sure whether (2) is right or not. So I started digging from the calculation of $\lim\limits_{n\to\infty}(1 + \frac1 n)^n$.

Here is how I solve the problem.

Let $t$ be any number in the interval $[1-\frac{\lambda_n}n, 1]$, then we get

$$1-\frac{\lambda_n} n\leq t\leq1$$

Therefore

$$\frac 1{1-\frac{\lambda_n} n} \leq \frac 1 t \leq 1$$

Therefore

$$\int_{1-\frac{\lambda_n}n}^1\frac 1{1-\frac{\lambda_n} n}dt \leq \int_{1-\frac{\lambda_n}n}^1\frac 1 t dt\leq \int_{1-\frac{\lambda_n}n}^1 1dt$$

The first integral equals $\frac{\lambda_n}n$, the second integral equals $ln(1-\frac{\lambda_n} n)^{-1}$, the third integral equals $\frac{\lambda_n}{n-\lambda_n}$, so we get

$$\frac{\lambda_n}n\leq ln(1-\frac{\lambda_n} n)^{-1} \leq \frac{\lambda_n}{n-\lambda_n}$$

Exponentiating, we find that

$$e^{\frac{\lambda_n} n}\leq(1-\frac{\lambda_n}n)^{-1}\leq e^{\frac{\lambda_n}{n-\lambda_n}}$$

Taking the $(-n)^{st}$ power of the left inequality gives us

$$e^{-{\lambda_n}}\geq (1-\frac{\lambda_n} n)^n\tag{3}$$

Taking the $(\lambda_n - n)^{th}$ power of the right inequality gives us

$$(1-\frac{\lambda_n} n)^{(n-\lambda_n)}\geq e^{-\lambda_n}$$

Why was $\geq$ replaced with $\leq$?  Because $\lambda_n = np_n, n\geq 0, 0\leq p_n\leq 1$($p_n$ denotes the probability), so $\lambda_n-n = np_n - n = n(p_n - 1)\leq 0$, the power is less or equal to 0, so we need change the direction of the sign.

Multiply each side of the inequality by $(1-\frac{\lambda_n} n)^{\lambda_n}$, we get

$$(1-\frac{\lambda_n} n)^n\geq {e^{-\lambda_n}} {(1-\frac{\lambda_n} n)^{\lambda_n}}\tag 4$$

Combine (3) and (4), we get

$$e^{-\lambda_n}(1-\frac{\lambda_n} n)^{\lambda_n}\leq (1-\frac{\lambda_n} n)^n \leq e^{-\lambda_n}$$

According to [this theorem](https://searene.me/2016/10/01/Proof-of-limit-f-x-g-x-c-d/), because $1 - \frac{\lambda_n} n > 0, \lambda_n > 0, \lim\limits_{n\to\infty}\lambda_n = \lambda$, we have

$\lim\limits_{n \to \infty}(1-\frac{\lambda_n} n)^{\lambda_n} = [\lim\limits_{n \to \infty}(1-\frac{\lambda_n} n)]^{\lim\limits_{n\to\infty}\lambda_n}$

$ = \lim\limits_{n\to\infty}(1-\lambda_n\cdot\frac 1 n)^\lambda$

$ = (\lim\limits_{n\to\infty}1 - \lim\limits_{n\to\infty}\lambda_n\cdot\lim\limits_{n\to\infty}\frac 1 n)^\lambda$

$ = (1 -\lambda\cdot0)^\lambda = 1$

So

$$\lim\limits_{n\to\infty}e^{-\lambda_n}(1-\frac{\lambda_n} n)^{\lambda_n} = e^{-\lambda}$$

$$\lim\limits_{n\to\infty}e^{-\lambda_n} = e^{-\lambda}$$

According to squeeze theorem, we get

$$\lim\limits_{n\to\infty}(1-\frac{\lambda_n} n)^n = e^{-\lambda}$$

Which is the answer.

# Reference

1. [$e$ as the limit of $(1+\frac 1 n)^n$](http://aleph0.clarku.edu/~djoyce/ma122/elimit.pdf)
