title: Understand poisson distribution
date: 2016-10-01 23:34:25
tags: [poisson, probability, math]
categories: Math
thumbnail: /images/call.jpg
---

# Introduction
Poisson distribution can be derived from Binomial distribution when $\lim\limits_{n\to\infty}np = \lambda(\lambda\in\mathbb R)$, in which $n$ is the number of trials, $p$ is the probability of success in each trial. But how is the formula of poisson distribution obtained? Why is $p$ getting smaller when $n$ approaches infinity? I will try to answer these questions in this post.

# Question
Imagine there's a call center in your local city, it receives a certain amount of calls per day. Let's say the expected value of the number of the received calls is $\lambda$. Now we need to calculate the probability of the number of received calls equaling $x$. How can we do it?

# Model
Let's split one day into $n$ periods. So there could exist the two following cases for each period of time.

1. There are calls received, either only one call or multiple calls
2. There are no call received

Whether there being calls received in each period of time is independent. Let's define the following symbols:

1. $P(X=x)$: the probability of the number of periods during which one or more calls received being $x$,
2. $p_n$: the probability of there existing one or more calls during one period of time.
3. ${p_n}'$: the probability of there existing only one call during one period of time

It can be easily found out that $P(X=x)$ follows Binomial distribution, so

$$P(X=x) = \binom n x {p_n}^x(1-p_n)^{(n - x)}\tag1$$

The expected value of $X$ is

$$E(X) = np_n$$

Notice that we have another information: the average number of received calls per day is $\lambda$, which means the expected value of the number of received calls per day is $\lambda$. It's going to come in handy later on.

Increase $n$, we will notice that the amount of time each period contains decreases, so some periods in which there exist two or more calls before only exist one or even zero call now. So the expected value of $X$ increases(because some periods in which two or more calls exists is split into multiple periods in which only one call exists), which means $np_n$ increases as $n$ increases. When $n$ is large enough, so that each period of time is so short that no more than one call can exist in one period of time, the following equation would hold in this case.

$$p_n = {p_n}'$$

So that

$$E(X) = np_n = n{p_n}' = \lambda\tag2$$

Let's define another variable Y

* $Y$: the total number of calls received per day.
*  $\delta t$: the amount of time each period contains

When $n$ is large enough, no more than one call exists in one period of time, so the number of periods of time in which one or more calls received($X$) equals the number of total calls received per day($Y$).

So

$$P(Y=x) = P(X=x) = \binom n x {p_n}^x(1-p_n)^{(n-x)}\tag3$$

How large should $n$ be to hold the above equation? 100, 10000, 10000000000? The larger, the better, so we set $n \to\infty$, so $\delta t \to 0$. In this case, no more than one call exists in one period of time. 

Let's prove that no more than one call exists in $\delta t$ when $\delta t \to 0$. Assuming more than one call exist in $\delta t$, because $\delta t \to 0$, so $\delta t$ should be smaller than $\forall \varepsilon>0$. So we can futher split $\delta t$ into several parts so each part only contains one call or no call, so no more than one call could exist in $\delta t$ when $\delta t \to\infty$. But is there a possibility that one call exists in $\delta t$? Yes. Notice that $\delta t\to 0$ doesn't mean $\delta t = 0$. It just means $\delta t$ is smaller than any positive real number. Just like the figure of $y=\frac 1 x$ below. While $y\to0$ when $x\to \infty$, but $y$ could be smaller than any positive real number, but $y$ can never be 0.

![$y=\frac 1 x$](/images/y=1_over_x.png)

So $p_n$ becomes the possibility of there existing only one call in each period of time, so $np_n$ becomes the total number of calls per day, i.e.

$$\lim\limits_{n\to\infty}np_n = \lambda$$

To make it work, the following equation must hold.

$$\lim\limits_{n\to\infty}p_n = 0$$

So the possibility of there existing only one call in $\delta t$ is 0. Does it mean there exists no call in any period of time? Of course not. The probability being 0 doesn't mean it's not possible. There will always be some calls falling into some periods of time, $p_n\to 0$ only means $p_n$ could be smaller than any positive real number. In the real world, you cannot actually make $n = \infty$, so you cannot actually make $p_n = 0$. To better illustrate what I mean, let's define the two following events.

* *event1*: Only one call is received in some periods of time
* *event2*: Two or more calls are received in some periods of time. 

The number of *event1* can never be 0 as long as we receive at least one call in a day. But when $n$ gets larger and larger, *event2* will finally be 0. This is different although the possibility of both events is 0 when $n\to\infty$.

Let's add $n\to\infty$, so $(3)$ becomes

$$P(Y=x) = P(X=x) = \lim\limits_{n\to\infty}\binom n x {p_n}^x(1-p_n)^{(n-x)}\tag4$$

Let

$$\lambda_n = np_n$$

According to $(2)$

$$\lim\limits_{n\to\infty}np_n = \lambda$$

So

$$\lim\limits_{n\to\infty}\lambda_n = \lambda$$

Put $p_n = \frac{\lambda_n} n$ into $(4)$, we get

$$\begin{equation}\begin{split} &P(Y=x) \\
&= \lim\limits_{n\to\infty}\binom n x(\frac{\lambda_n} n)^x(1-\frac{\lambda_n}n)^{(n-x)}\\
&=\lim\limits_{n\to\infty}\frac{n(n-1)\cdots(n-x+1)}{x!\cdot n^x}\cdot{\lambda_n}^x\cdot(1-\frac{\lambda_n} n)^n\cdot(1-\frac{\lambda_n} n)^{-x}\\
&=\lim\limits_{n\to\infty}\frac 1 {x!} \cdot 1 \cdot \underbrace{(1-\frac 1 n)\cdot(1-\frac 2 n)\cdots(1-\frac{x-1} n)}_1\cdot\underbrace{ {\lambda_n}^x}_{\lambda}\cdot\underbrace{(1-\frac{\lambda_n} n)^n}_{e^{-\lambda}}\cdot\underbrace{(1-\frac{\lambda_n} n)^{-x}}_1\\
&=\frac{e^{-\lambda}{\lambda}^x}{x!}\end{split}\end{equation}$$

You can find out why $\lim\limits_{n\to\infty}(1-\frac{\lambda_n} n)^n = e^{-\lambda}$ in [this post](https://searene.me/2016/09/30/Calculate-1-lambda-n-n/)

# FAQ

**Q**: If I was given $n$ and $p_n$, and I got $\lambda$ using $\lambda = np_n$, then I calculate the probability of there exising $x$ events in the total amount of time using the following equation.

$$P(X=x) = \frac{e^{-\lambda}{\lambda}^x}{x!}$$

 Is it the exact value I want or just an approximation?

**A**: This is just an approximation. The value you get is **the number of pieces where events exist**. There could be one event in a piece, there could be two or more events in a piece. So $P(X=x)$ not only includes the some of the cases where we want, but also the case where we don't want, e.g. it also includes the case where $x+1$ events occur, but it doesn't include the case where $x$ events fall into $x-1$ or less pieces.

**Q**: If I was given the expected value $\lambda$, and I calculate the probability using the following equation, then I calculate the probability of there exising $x$ events in the total amount of time using the following equation.

$$P(X=x) = \frac{e^{-\lambda}{\lambda}^x}{x!}$$

 Is it the exact value I want or just an approximation?

**A**: It's the value you want. When $n$ is not large, the reason why there is a difference between $\binom n x{p_n}^x(1-p_n)^{(n-x)}$ and $\frac{e^{-\lambda}{\lambda}^x}{x!}$ is that $p_n$ is not exactly the value we want. That is, when $n$ is not large and we calculate the probability using $(1)$, the answer we get is

$$P(X=x) = P_1 + P_2$$

* $X$: the number of pieces where one or more events exist
* $P_1$ refers to the case where $x$ events fall into $x$ pieces
* $P_2$ refers to the case where $x+1$ or more events fall into $x$ pieces

The value we want would be

$$P(Y = x) = P_1 + P_3$$

* $P_3$ refers to the case where $x$ events fall into $x-1$ or less pieces.
* Y: the total number of events occurring.

As $n\to\infty$, $P_2\to 0$, $P_3\to 0$, so $P(X=x) \to P(Y=x)$

So

$$\lim\limits_{n\to\infty}P(X=x) = \lim\limits_{n\to\infty}P(Y=x) = P_1$$

Because

$$P(X=x) = \binom n x {p_n}^x(1-p_n)^{(n-x)}$$

So

$$\lim\limits_{n\to\infty}P(Y=x) = \frac{e^{-\lambda}{\lambda}^x}{x!}$$

Because P(Y=x) has nothing to do with what $n$ is, so $\lim\limits_{n\to\infty}P(Y=x) = P(Y=x)$

So

$$P(Y=x) = \frac{e^{-\lambda}{\lambda}^x}{x!}$$

That is, the number of total events is $\frac{e^{-\lambda}{\lambda}^x}{x!}$.
