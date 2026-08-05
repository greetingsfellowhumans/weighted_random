## Introduction

Here are a few benchmark samples I took. Your mileage may vary.

This is especially unfair to the ThreeFry algorithm, via Nx. The main advantage to it is GPU acceleration and parallel operations... but the PC I am using for testing doesn't have a GPU with CUDA cores, so the performance is terrible. At some point I will try to do another series of tests, taking advantage of the GPU.

If you want to contribute, please do run the tests yourself and post your results. I would love to see them.

## Conclusions

ThreeFry is fastest during preprocessing, but slowest at sampling.
WalkerAlias is the opposite. Slowest preprocessing, but fastest sampling.

In most cases you probably want to preprocess only once, and sample from it many times. So the WalkerAlias is a good default.

It seems that in most cases the Walker Alias Method is the clear winner, unless you know you just want a small number of results, in which Linear sometimes wins.
I think ThreeFry is a bit more niche and is useful when you need reproducible results.

For every test, I am using a range of 1..100 for the possible outcomes, and the following weights:
`[%{target: 50, weight: 50, radius: 15}]`

## Preprocessing phase

Preprocessing 1 time:

```
Name                                ips        average  deviation         median         99th %
preprocess_three_fry_1          27.16 K       36.82 μs     ±6.89%       35.90 μs       44.04 μs
preprocess_linear_1             26.27 K       38.07 μs    ±12.28%       37.19 μs       45.81 μs
preprocess_walker_alias_1       24.44 K       40.91 μs    ±12.30%       40.51 μs       54.56 μs

Comparison:
preprocess_three_fry_1          27.16 K
preprocess_linear_1             26.27 K - 1.03x slower +1.25 μs
preprocess_walker_alias_1       24.44 K - 1.11x slower +4.09 μs
```

Preprocessing 10 times:

```
Name                                 ips        average  deviation         median         99th %
preprocess_three_fry_10           2.59 K      385.69 μs     ±8.20%      376.13 μs      539.29 μs
preprocess_walker_alias_10        2.09 K      479.58 μs    ±15.08%      458.99 μs      806.35 μs
preprocess_linear_10              2.08 K      480.23 μs    ±21.20%      450.44 μs      902.91 μs

Comparison:
preprocess_three_fry_10           2.59 K
preprocess_walker_alias_10        2.09 K - 1.24x slower +93.89 μs
preprocess_linear_10              2.08 K - 1.25x slower +94.54 μs
```

Preprocessing 100 times:

```
Name                                 ips        average  deviation         median         99th %
preprocess_three_fry_100           252.82        3.96 ms     ±2.19%        3.93 ms        4.30 ms
preprocess_linear_100              222.51        4.49 ms     ±9.81%        4.36 ms        5.63 ms
preprocess_walker_alias_100        211.83        4.72 ms     ±7.89%        4.58 ms        5.76 ms

Comparison:
preprocess_three_fry_100           252.82
preprocess_linear_100              222.51 - 1.14x slower +0.54 ms
preprocess_walker_alias_100        211.83 - 1.19x slower +0.77 ms
```

Preprocessing 1000 times:

```
Name                                   ips        average  deviation         median         99th %
preprocess_walker_alias_1000         22.37       44.70 ms     ±4.45%       43.99 ms       48.54 ms
preprocess_linear_1000               21.07       47.47 ms     ±6.88%       48.00 ms       55.81 ms
preprocess_three_fry_1000            16.19       61.78 ms     ±3.45%       61.67 ms       66.82 ms

Comparison:
preprocess_walker_alias_1000         22.37
preprocess_linear_1000               21.07 - 1.06x slower +2.77 ms
preprocess_three_fry_1000            16.19 - 1.38x slower +17.09 ms
```

Preprocessing 1_000_000 times:

```
Name                                      ips        average  deviation         median         99th %
preprocess_walker_alias_1000000        0.0130       1.28 min     ±0.00%       1.28 min       1.28 min
preprocess_linear_1000000              0.0118       1.42 min     ±0.00%       1.42 min       1.42 min
preprocess_three_fry_1000000          0.00670       2.49 min     ±0.00%       2.49 min       2.49 min

Comparison:
preprocess_walker_alias_1000000        0.0130
preprocess_linear_1000000              0.0118 - 1.11x slower +0.140 min
preprocess_three_fry_1000000          0.00670 - 1.95x slower +1.21 min
```

## Sampling phase

take(1)

```
Name                          ips        average  deviation         median         99th %
take_walker_alias_1        2.83 M     0.00035 ms  ±2426.97%     0.00031 ms     0.00051 ms
take_linear_1             0.102 M     0.00980 ms    ±48.48%     0.00956 ms      0.0167 ms
take_three_fry_1        0.00090 M        1.12 ms     ±8.20%        1.07 ms        1.38 ms

Comparison:
take_walker_alias_1        2.83 M
take_linear_1             0.102 M - 27.69x slower +0.00945 ms
take_three_fry_1        0.00090 M - 3154.50x slower +1.12 ms
```

take(10)

```
Name                           ips        average  deviation         median         99th %
take_walker_alias_10       48.08 K       20.80 μs    ±18.20%       20.61 μs       23.24 μs
take_linear_10              4.82 K      207.38 μs     ±8.65%      205.70 μs      254.90 μs
take_three_fry_10         0.0736 K    13592.21 μs     ±1.67%    13570.03 μs    14386.16 μs

Comparison:
take_walker_alias_10       48.08 K
take_linear_10              4.82 K - 9.97x slower +186.58 μs
take_three_fry_10         0.0736 K - 653.46x slower +13571.41 μs
```

take(100)

```
Name                            ips        average  deviation         median         99th %
take_walker_alias_100        457.27        2.19 ms     ±2.74%        2.16 ms        2.30 ms
take_linear_100              114.90        8.70 ms     ±2.79%        8.75 ms        9.74 ms
take_three_fry_100             2.36      423.50 ms     ±0.37%      422.92 ms      426.51 ms

Comparison:
take_walker_alias_100        457.27
take_linear_100              114.90 - 3.98x slower +6.52 ms
take_three_fry_100             2.36 - 193.65x slower +421.31 ms
```

take(1000)

```
Name                             ips        average  deviation         median         99th %
take_walker_alias_1000          4.39      227.63 ms     ±1.08%      227.64 ms      234.94 ms
take_linear_1000                3.77      265.58 ms     ±0.87%      264.92 ms      271.89 ms
take_three_fry_1000           0.0175    57203.02 ms     ±0.00%    57203.02 ms    57203.02 ms

Comparison:
take_walker_alias_1000          4.39
take_linear_1000                3.77 - 1.17x slower +37.95 ms
take_three_fry_1000           0.0175 - 251.29x slower +56975.39 ms
```

take(1_000_000)
Test not completed. After an hour, I just stopped it.

## Combined test (`rand` function)

rand(_,_, take: 1)

```
Name                          ips        average  deviation         median         99th %
rand_walker_alias_1       24.07 K       41.55 μs    ±15.05%       41.07 μs       55.03 μs
rand_linear_1             20.58 K       48.60 μs    ±11.18%       47.69 μs       60.33 μs
rand_three_fry_1           0.85 K     1178.85 μs     ±7.89%     1134.54 μs     1453.28 μs

Comparison:
rand_walker_alias_1       24.07 K
rand_linear_1             20.58 K - 1.17x slower +7.05 μs
rand_three_fry_1           0.85 K - 28.37x slower +1137.30 μs
```

rand(_,_, take: 10)

```
Name                           ips        average  deviation         median         99th %
rand_walker_alias_10        1.97 K      506.79 μs    ±11.54%      488.24 μs      659.45 μs
rand_linear_10              1.47 K      680.18 μs     ±7.75%      660.01 μs      817.40 μs
rand_three_fry_10         0.0709 K    14104.76 μs     ±1.24%    14119.28 μs    14507.52 μs

Comparison:
rand_walker_alias_10        1.97 K
rand_linear_10              1.47 K - 1.34x slower +173.38 μs
rand_three_fry_10         0.0709 K - 27.83x slower +13597.97 μs
```

rand(_,_, take: 100)

```
Name                            ips        average  deviation         median         99th %
rand_walker_alias_100        143.66        6.96 ms     ±5.20%        6.84 ms        7.90 ms
rand_linear_100               69.90       14.31 ms     ±1.25%       14.31 ms       14.85 ms
rand_three_fry_100             2.33      428.27 ms     ±0.49%      429.04 ms      430.99 ms

Comparison:
rand_walker_alias_100        143.66
rand_linear_100               69.90 - 2.06x slower +7.35 ms
rand_three_fry_100             2.33 - 61.52x slower +421.31 ms
```

rand(_,_, take: 1_000)

```
Name                             ips        average  deviation         median         99th %
rand_walker_alias_1000          3.60      277.81 ms     ±2.14%      277.64 ms      292.34 ms
rand_linear_1000                3.22      310.21 ms     ±1.71%      308.89 ms      324.55 ms
rand_three_fry_1000           0.0173    57846.59 ms     ±0.00%    57846.59 ms    57846.59 ms

Comparison:
rand_walker_alias_1000          3.60
rand_linear_1000                3.22 - 1.12x slower +32.39 ms
rand_three_fry_1000           0.0173 - 208.22x slower +57568.77 ms
```
