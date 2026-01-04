Current model status:

it's account and stock flow consistent. The real economy is really bad but I guess it's ok if one is interested in monetary changes and mechanisms.

# Agent-Based Monetary Model: Mathematical Description

This document provides a formal mathematical description of the agent-based monetary model implemented in the provided Julia code. The model is stock-flow consistent and features endogenous money creation through bank lending.

## 1. Agents and Balance Sheets

### 1.1 Banks

**Assets:**
- Reserves (central bank money): ```math R_b ```
- Government bonds: ```math B_b ```
- Loans: ```math L_b ```
- Fixed assets: ```math F_b ```

**Liabilities:**
- Deposits: ```math D_b ```

**Equity (capital):**
```math
K_b = R_b + B_b + L_b + F_b - D_b
```

**Excess reserves:**
```math
ER_b = R_b - \rho D_b, \quad \rho = 0.05
```

### 1.2 Households

**Assets:**
- Deposits: ```math D_h ```
- Government bonds: ```math B_h ```
- Real estate: ```math RE_h ```
- Share holdings: ```math s_{h,f} ``` (fraction of firm ```math f ``` owned by household ```math h ```)

**Liabilities:**
- Loans: ```math L_h ```

**Equity:**
```math
K_h = D_h + B_h + RE_h - L_h
```

### 1.3 Firms

**Assets:**
- Deposits: ```math D_f ```
- Fixed capital: ```math K_f ```
- Inventory (physical units): ```math I_f ```

**Liabilities:**
- Loans: ```math L_f ```

**Equity:**
```math
K_f = D_f + K_f + I_f - L_f
```
(Note: inventory is valued at normalized price 1 in capital calculation.)

### 1.4 Central Bank

**Assets:**
- Government bonds: ```math B_{cb} ```
- Reserve assets: ```math RA_{cb} ```

**Liabilities:**
- Reserves (monetary base): 
```math
MB = \sum R_b + R_g
```

### 1.5 Government

**Assets:**
- Fixed assets (infrastructure): ```math G_{fa} ```
- Reserves: ```math R_g ```

**Liabilities:**
- Bonds: ```math B_g ```

## 2. Production Technology

Firm production capacity (potential output in physical units):
```math
Y_f^{cap} = A \cdot N_f^\beta \cdot K_f^\alpha \cdot \left(\frac{G_{fa}}{n_{firms}}\right)^{1 - \alpha - \beta}
```
where:
- ```math A = 1.2 ``` (total factor productivity)
- ```math N_f ```: number of employees
- ```math \alpha = 0.35 ```, ```math \beta = 0.7 ```
- ```math 1 - \alpha - \beta = -0.05 ``` (slightly decreasing returns due to fixed public infrastructure)

**Actual production:**
```math
Y_f = 
\begin{cases}
Y_f^{cap} & \text{if } I_f < I^{target} = 60 \cdot p_f \\
0 & \text{otherwise}
\end{cases}
```

Aggregate capacity:
```math
Y^{cap} = \sum_f Y_f^{cap}
```

## 3. Consumption Demand

Household consumption expenditure:
```math
C_h = \min(0.1 \cdot w_h + 0.01 \cdot D_h,\ D_h)
```
(with wage ```math w_h = 1 ``` per period when employed)

## 4. Matching Probability (Consumption Allocation)

Probability that household buys from firm ```math f ```:
```math
\pi_f = \frac{1}{2} \left( \frac{Y_f^{cap}}{Y^{cap}} + \frac{\exp(-2 p_f)}{\sum_j \exp(-2 p_j)} \right)
```

- First term: relative capacity (firm size effect)
- Second term: price competitiveness (lower price → higher probability)

Firms with insufficient inventory value (```math I_f \cdot p_f < C_h ```) are temporarily excluded.

Quantity sold:
```math
\Delta I_f = -\frac{C_h}{p_f}
```

## 5. Price Adjustment

Firm price evolves as:
```math
p_f^{new} = p_f \cdot \left( \frac{W_f / Y_f^{cap}}{p_f} \right) \cdot \left( \frac{\bar{p}}{p_f} \right)
```
where:
- ```math W_f ```: total wage bill in last production cycle
- ```math \frac{W_f}{Y_f^{cap}} ```: unit labor cost at full capacity
- ```math \bar{p} ```: average price level

Overall price level:
```math
\bar{p} = \frac{1}{n_{firms}} \sum_f p_f
```

## 6. Money and Credit Creation

**Monetary aggregates:**
- Base money (MB): 
```math
MB = \text{central bank reserves}
```
- Broad money (M1): 
```math
M1 = \sum D_b = \text{total bank deposits}
```

**Endogenous money creation (loan → deposit):**
```math
\Delta L_h = \Delta D_h = \Delta L_b = \Delta D_b > 0
```

## 7. Key Scenarios

### Mortgage Credit Expansion
Non-homeowners borrow the full value of existing homes:
```math
\Delta L_h = \Delta D_h = RE^{sold}, \quad \Delta RE_{buyer} = - \Delta RE_{seller} = RE^{sold}
```
→ Strong increase in M1 and leverage.

### Government Bond Issuance
Government sells bonds to banks with sufficient excess reserves:
```math
\Delta B_g = \Delta R_g = \Delta B_b = -\Delta R_b
```

### Helicopter Money
Government issues bonds to banks, then transfers directly to households:
```math
\Delta D_h = \Delta R_b = +\text{transfer}, \quad \Delta R_g = -\text{transfer}
```

## 8. Simulation Sequence (per period)

1. Firms pay fixed wages (```math w = 1 ``` per employee)
2. Firms produce to replenish inventory if below target
3. Firms adjust prices
4. Households consume and purchase from matched firm
5. Firms pay dividends quarterly if liquid assets exceed 40% of fixed capital
6. Record aggregates (M1, capital, production, consumption, price level, etc.)

## 9. Accounting Consistency

The model maintains double-entry bookkeeping. Key identity:
```math
\sum K_h + \sum K_f + \sum K_b = \sum RE_h + G_{fa} + \sum K_f + \sum F_b
```
(Private sector net worth equals total real assets.)

This framework captures feedback between real activity, credit creation, money supply, and price dynamics in a fully articulated monetary economy.