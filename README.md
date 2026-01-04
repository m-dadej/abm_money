# Agent-Based Monetary Model: Mathematical Description

This document provides a formal mathematical description of the agent-based model (ABM) of a monetary economy implemented in the provided Julia code. The model features heterogeneous agents (households, firms, banks, government, and central bank) interacting through balance sheets, production, consumption, and credit creation.

## 1. Agents and Balance Sheets

### 1.1 Banks
Each bank has the following balance sheet items:

**Assets:**
- Reserves: \( R_b \) (central bank money)
- Government bonds: \( B_b \)
- Loans to households/firms: \( L_b \)
- Fixed assets: \( F_b \)

**Liabilities:**
- Deposits: \( D_b \)

**Bank capital (equity):**
\[
K_b = R_b + B_b + L_b + F_b - D_b
\]

**Excess reserves:**
\[
ER_b = R_b - \rho \cdot D_b
\]
where \( \rho = 0.05 \) is the minimum reserve ratio.

### 1.2 Households
**Assets:**
- Bank deposits: \( D_h \)
- Government bonds: \( B_h \)
- Real estate: \( RE_h \)
- Shares in firms: \( s_{h,f} \) (vector over firms \( f \))

**Liabilities:**
- Bank loans: \( L_h \)

**Household equity:**
\[
K_h = D_h + B_h + RE_h - L_h
\]

### 1.3 Firms
**Assets:**
- Bank deposits: \( D_f \)
- Fixed capital (machinery): \( K_f \)
- Inventory (goods): \( I_f \) (in physical units, valued at price 1 in capital calculation)

**Liabilities:**
- Bank loans: \( L_f \)

**Firm equity:**
\[
K_f = D_f + K_f + I_f - L_f
\]

### 1.4 Central Bank
**Assets:**
- Government bonds: \( B_{cb} \)
- Reserve assets (FX, gold): \( RA_{cb} \)

**Liabilities:**
- Reserves (base money): \( MB = R_{total} \)

### 1.5 Government
**Assets:**
- Fixed assets (infrastructure): \( G_{fa} \)
- Reserves at central bank: \( R_g \)

**Liabilities:**
- Government bonds: \( B_g \)

## 2. Production and Capacity

Firm production follows a Cobb–Douglas-type function with decreasing returns to scale:

\[
Y_f^{cap} = A \cdot N_f^\beta \cdot K_f^\alpha \cdot G^{1-\alpha-\beta}
\]

where:
- \( A = 1.2 \) is total factor productivity,
- \( N_f \) = number of employees,
- \( K_f \) = firm fixed capital,
- \( G = \frac{G_{fa}}{n_{firms}} \) = per-firm public infrastructure,
- \( \alpha = 0.35 \), \( \beta = 0.7 \), so \( 1 - \alpha - \beta = -0.05 \) (slightly decreasing returns).

**Actual production:**
\[
Y_f = 
\begin{cases}
Y_f^{cap} & \text{if } I_f < I^{target} \\
0 & \text{otherwise}
\end{cases}
\]
with target inventory \( I^{target} = 60 \cdot p_f \).

Aggregate potential output:
\[
Y^{cap} = \sum_f Y_f^{cap}
\]

## 3. Consumption

Each household consumes a fraction of income and wealth:
\[
C_h = \min(0.1 \cdot w_h + 0.01 \cdot D_h,\ D_h)
\]
where \( w_h \) is last period's wage (here fixed at 1).

## 4. Matching and Sales

Households select a firm to buy from using a weighted probability:
\[
\pi_f = \frac{1}{2} \left( \frac{Y_f^{cap}}{Y^{cap}} + \frac{e^{-2 p_f}}{\sum_j e^{-2 p_j}} \right)
\]

- First term: relative firm size (capacity)
- Second term: price competitiveness (lower price → higher probability)

Firms with insufficient inventory value (\( I_f \cdot p_f < C_h \)) are excluded.

Sale quantity:
\[
\Delta I_f = -\frac{C_h}{p_f}
\]

## 5. Price Setting

Firms adjust price based on unit labor cost and relative price level:
\[
p_f^{new} = p_f \cdot \left( \frac{UC_f}{p_f} \right) \cdot \left( \frac{\bar{p}}{p_f} \right)
\]
where:
- \( UC_f = \frac{\text{total wage bill}}{Y_f^{cap}} \) = unit labor cost at capacity,
- \( \bar{p} \) = average price level across firms.

Overall price level:
\[
\bar{p} = \frac{1}{n_{firms}} \sum_f p_f
\]

## 6. Money and Credit Creation

### Money Supply
- Monetary base (MB): \( MB = \) central bank reserves
- Broad money (M1): \( M1 = \sum_b D_b \) (total bank deposits)

### Endogenous Money Creation
When a household takes a loan:
\[
\Delta L_h = \Delta D_h = \Delta L_b = \Delta D_b = \text{loan amount}
\]
→ Banks create deposits (money) simultaneously with loans.

## 7. Key Scenarios

### Mortgage Boom
Non-homeowners take loans equal to the value of existing real estate and purchase it from owners → strong credit and money creation.

### Government Bond Issuance
Government sells bonds to banks with sufficient excess reserves:
\[
\Delta B_g = \Delta R_g = \Delta B_b = -\Delta R_b
\]

### Helicopter Money
Government issues bonds to all banks (regardless of reserves), then credits household deposits directly → financed by primary dealers.

## 8. Aggregate Accounting Consistency

The model enforces double-entry bookkeeping. Key identities:
\[
\sum K_h + \sum K_f + \sum K_b = \sum RE_h + G_{fa} + \sum K_f + \sum F_b
\]
(Net worth equals total real assets)

Money supply relations hold by construction due to balance sheet consistency.

## 9. Simulation Flow (per period)

1. Firms pay wages (fixed at 1 per worker)
2. Firms produce if inventory below target
3. Firms adjust prices
4. Households consume and purchase from matched firm
5. Firms pay dividends quarterly (if deposits exceed 40% of fixed capital)
6. Record aggregates

This model captures endogenous money creation, balance sheet interdependencies, and real-monetary feedback in a stock-flow consistent framework.