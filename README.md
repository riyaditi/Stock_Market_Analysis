# 📊 MarketPulse  
### Stock Trading & Market Intelligence Platform

MarketPulse is an end-to-end **Stock Market Trading Analytics Platform** built using **SQL Server, Power BI, and MS Fabric–ready architecture**.  
It transforms raw trade execution data into **market intelligence dashboards** used for liquidity analysis, order-flow monitoring, and market surveillance.

This project simulates how **exchanges, brokers, and fintech platforms** analyze trading behavior in real time.

---

## 🚀 Project Highlights

- End-to-end **data engineering + BI solution**
- Star-schema **data warehouse design**
- Parsing of **semi-structured trading data**
- **Order-flow & liquidity analytics**
- Multi-page **fintech-style Power BI dashboard**
- App-like navigation and dark trading terminal UI
- Designed for **Power BI Service / MS Fabric deployment**

---

## 🏗️ Architecture Overview
Raw CSV Files
↓
Staging Layer (SQL Server)
↓
Dimensional Data Warehouse (Star Schema)
↓
Power BI Semantic Model
↓
MarketPulse Dashboard (4 Pages)


---

## 📂 Data Sources

| File | Description |
|----|----|
| `shares.csv` | Market price snapshots |
| `share_trade.csv` | Executed BUY/SELL trades |
| `share_lookup.csv` | Instrument reference data |

> ⚠️ Price feed and trade feed are intentionally independent, reflecting real-world financial systems.

---

## 🗂️ Data Warehouse Design

### Dimensions
| Table | Description |
|----|----|
| `dim_security` | Stock master (ISIN, Company Name) |
| `dim_date` | Calendar dimension |
| `dim_time` | Intraday time dimension |
| `dim_source` | Trade source (HL, ICE, UNKNOWN) |

### Fact Tables
| Table | Description |
|----|----|
| `fact_trade` | Executed trades (BUY/SELL, quantity, source) |
| `fact_price` | Market prices (reference only) |

Schema design follows **industry-standard star schema modeling** for high-performance analytics.

---

## 🔧 Data Engineering Process

### 1️⃣ Staging Layer
- Raw CSVs loaded into staging tables
- No transformation (raw ingestion)

### 2️⃣ Parsing Trade Data
Trade records contained semi-structured fields like:
{name=Tesla, quantity=1, source=HL}
{buyPrice=177.95, name=Lululemon Athletica, quantity=2, ...}


SQL string parsing was used to extract:
- Company name
- Quantity
- Trade source

---

### 3️⃣ Dimension Construction
- Company names extracted from trade feed
- Trade sources standardized (HL / ICE / UNKNOWN)
- Date & time dimensions generated from timestamps

---

### 4️⃣ Fact Table Population
`fact_trade` populated using:
- Real timestamps
- BUY / SELL direction
- Extracted quantities
- Source keys
- ISIN mapping

This creates a **true order-flow dataset** suitable for market analysis.

---

## ⚠️ Important Modeling Decision

During analysis, it was identified that:
- **Price feed and trade feed were not perfectly aligned by ISIN and time**

To avoid **misleading financial metrics**, the project intentionally focuses on:
- Liquidity
- Volume
- Order flow
- Participation analysis

Rather than inaccurate:
- PnL
- VWAP
- OHLC

This mirrors how **exchanges and surveillance teams** operate.

---

## 📈 KPIs & Metrics

- Total Trades
- Total Volume
- Buy Quantity
- Sell Quantity
- Net Position
- Trades by Hour
- Net Volume by Hour
- Source Participation
- Company Activity Heatmaps

These metrics are commonly used by:
- Brokers
- Exchanges
- Market surveillance teams

---

## 🖥️ Dashboard Pages

### 🟦 Page 1 — Home
Market overview:
- Market activity trend
- Top active companies
- Trades by source
- Key market KPIs

---

### 🟦 Page 2 — Market Overview
Market behavior:
- Trades by hour
- Net volume by hour (buying vs selling pressure)
- Buy vs Sell trends
- Source participation over time

---

### 🟦 Page 3 — Company Analysis
Stock-level insights:
- Buy vs Sell behavior
- Net position
- Intraday trading heatmap
- Company-specific trends

---

### 🟦 Page 4 — Trade Intelligence
Market surveillance:
- Live trade log
- Company × hour heatmap
- Source vs company analysis

---

## 🎨 UX & Design Features

- Dark fintech trading terminal theme
- App-style navigation buttons
- Conditional formatting (BUY = green, SELL = red)
- Drill-through between pages
- Optimized for widescreen dashboards

---

## ☁️ Deployment Ready

- Designed for **Power BI Service**
- Compatible with **Microsoft Fabric**
- GitHub-ready SQL + documentation
- Scalable warehouse architecture

---

## 🧠 Skills Demonstrated

- SQL & Data Warehousing
- Dimensional Modeling
- Financial data parsing
- Power BI semantic modeling
- Market & liquidity analytics
- UX-driven BI design
- End-to-end analytics engineering

---

## 🏁 Final Note

MarketPulse is not just a dashboard —  
it is a **Stock Trading & Market Intelligence Platform** that demonstrates how raw trading data is transformed into **actionable market insights**.

---

### 👤 Author
**Riya D**

