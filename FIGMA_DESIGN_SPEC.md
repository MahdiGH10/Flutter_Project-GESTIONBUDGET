# DEVMOB - GestionBudgetaire — Figma Design Specification

> **This document provides the exact specifications for creating all 9 app screens in Figma,
> derived from the Flutter app code and design_tokens.json.**

---

## 📐 Global Setup

### Frame Size (Mobile)
- **Width:** 375px
- **Height:** 812px (iPhone X/11 size)

### Font Family
- **Primary:** Urbanist (install from Google Fonts in Figma)
- **Fallback:** sans-serif

---

## 🎨 Color Styles (Create as Figma Color Styles)

| Style Name         | Hex       | Usage                        |
|--------------------|-----------|------------------------------|
| primary/900        | `#1F2C37` | Main dark, buttons, nav bar  |
| primary/800        | `#2A3B47` | Gradient middle              |
| primary/700        | `#354A56` | Secondary dark               |
| primary/100        | `#F7F9FC` | Light backgrounds            |
| primary/50         | `#FAFBFC` | Subtle backgrounds           |
| success/500        | `#4CD964` | Income, positive actions     |
| success/400        | `#6EE084` | Success hover                |
| success/100        | `#E8F9EC` | Success bg light             |
| success/50         | `#F3FDF5` | Success bg subtle            |
| danger/500         | `#FF3B30` | Expense, errors, delete      |
| danger/400         | `#FF6B63` | Danger hover                 |
| danger/100         | `#FFE8E7` | Danger bg light              |
| danger/50          | `#FFF3F2` | Danger bg subtle             |
| neutral/900        | `#1F2C37` | Primary text                 |
| neutral/700        | `#3D4F5F` | Secondary text               |
| neutral/500        | `#78828A` | Caption text, icons          |
| neutral/400        | `#A5B0B9` | Placeholder, inactive icons  |
| neutral/300        | `#C5CCD2` | Borders light                |
| neutral/200        | `#E8ECF0` | Borders, dividers, tracks    |
| neutral/100        | `#F7F9FC` | Page backgrounds             |
| neutral/0          | `#FFFFFF` | Cards, white                 |
| category/food      | `#FF6B6B` | Food category                |
| category/transport | `#4ECDC4` | Transport category           |
| category/shopping  | `#45B7D1` | Shopping category            |
| category/entertainment | `#96CEB4` | Entertainment category   |
| category/health    | `#FFEAA7` | Health category              |
| category/housing   | `#DDA0DD` | Housing category             |
| category/utilities | `#98D8C8` | Utilities category           |
| category/education | `#F7DC6F` | Education category           |

---

## 🔤 Text Styles (Create as Figma Text Styles)

| Style Name       | Size | Weight    | Line Height | Letter Spacing |
|------------------|------|-----------|-------------|----------------|
| h1Bold           | 32px | Bold 700  | 40px        | -0.5           |
| h2Bold           | 24px | Bold 700  | 32px        | -0.3           |
| h3SemiBold       | 20px | SemiBold 600 | 28px     | -0.2           |
| bodyRegular      | 16px | Regular 400 | 24px      | 0              |
| bodyMedium       | 16px | Medium 500 | 24px       | 0              |
| bodySemiBold     | 16px | SemiBold 600 | 24px     | 0              |
| captionRegular   | 14px | Regular 400 | 20px      | 0              |
| captionMedium    | 14px | Medium 500 | 20px       | 0              |
| smallMedium      | 12px | Medium 500 | 16px       | 0.2            |
| balanceDisplay   | 42px | ExtraBold 800 | 48px    | -1             |
| amountLarge      | 48px | ExtraBold 800 | 56px    | -1             |

---

## 📏 Spacing Tokens

| Token | Value |
|-------|-------|
| xs    | 4px   |
| sm    | 8px   |
| md    | 16px  |
| lg    | 24px  |
| xl    | 32px  |
| 2xl   | 48px  |
| 3xl   | 64px  |

---

## ◻️ Border Radius Tokens

| Token | Value     |
|-------|-----------|
| sm    | 12px      |
| md    | 16px      |
| lg    | 20px      |
| xl    | 28px      |
| full  | 9999px    |

---

## 🌫️ Shadow Styles (Create as Figma Effects)

| Name | X | Y  | Blur | Color              |
|------|---|----|------|--------------------|
| sm   | 0 | 2  | 8    | #1F2C37 @ 6%       |
| md   | 0 | 4  | 20   | #1F2C37 @ 8%       |
| lg   | 0 | 8  | 30   | #1F2C37 @ 12%      |
| xl   | 0 | 25 | 80   | #1F2C37 @ 15%      |

---

## 🧩 Component Specs

### Button / Primary
- Height: 56px, Horizontal padding: 32px
- Border radius: 16px
- Background: `#1F2C37`, Text: `#FFFFFF`
- Font: 16px SemiBold 600

### Button / Secondary
- Height: 56px, Horizontal padding: 32px
- Border radius: 16px
- Background: `#F7F9FC`, Text: `#1F2C37`
- Font: 16px SemiBold 600

### Button / FAB
- Size: 56×56px, Border radius: 28px
- Background: `#1F2C37`, Icon: `#FFFFFF`
- Shadow: lg

### Input Field
- Height: 56px, Horizontal padding: 20px
- Border radius: 16px, Border: 2px `#E8ECF0`
- Background: `#FFFFFF`, Text: `#1F2C37`
- Placeholder: `#A5B0B9`, Font: 16px

### Card / Transaction Tile
- Height: 72px, Padding: 16px
- Border radius: 16px, Background: `#FFFFFF`
- Shadow: sm

### Card / Balance
- Height: ~180px, Padding: 32px
- Border radius: 28px, Background: `#1F2C37`
- Shadow: lg

### Card / Category
- Width: ~156px, Height: ~120px, Padding: 20px
- Border radius: 20px, Background: `#FFFFFF`
- Shadow: sm

### Progress Bar
- Height: 8px, Border radius: 4px
- Track: `#E8ECF0`

### Toggle
- Width: 56px, Height: 32px, Border radius: 16px
- Thumb: 24px
- Off track: `#E8ECF0`, On track: `#4CD964`

### Bottom Navigation
- Height: 64px (content) + safe area
- Background: `#FFFFFF`
- Shadow: top shadow `#1F2C37` @ 5%, blur 20

### Icon Sizes
- Transaction icon: 48×48px, radius 14px
- Category icon: 56×56px radius 18px (or 48×48 radius 14px in code)
- Nav icon: 24×24px

---

# 📱 SCREENS

---

## Screen 1: LOGIN (375×812)

**Background:** Linear gradient 135° — `#1F2C37` → `#2A3B47` → `#1F2C37`

### Decorative Elements
- **Circle 1:** x=20, y=100, 160×160px, circle, fill `#4CD964` @ 10% opacity
- **Circle 2:** x=right-20, y=bottom-100, 200×200px, circle, fill `#FF3B30` @ 10% opacity

### Content (centered vertically, padding: 24px all sides)

1. **Logo Container**
   - 80×80px, border-radius: 24px
   - Background: white @ 10% opacity
   - Border: 1px white @ 20% opacity
   - Icon: wallet icon, 40px, color `#4CD964`

2. **Spacing:** 24px

3. **Title:** "Welcome Back"
   - Style: h1Bold (32px, Bold 700), color: white

4. **Spacing:** 8px

5. **Subtitle:** "Sign in to manage your budget"
   - Style: captionRegular (14px, Regular), color: white @ 60%

6. **Spacing:** 40px

7. **Email Field (Glass Style)**
   - Full width, height: 56px, border-radius: 16px
   - Background: white @ 10% opacity
   - Border: 1px white @ 15% opacity
   - Left icon: Mail icon, white @ 40%, 20px
   - Placeholder: "Email address", white @ 40%, 16px
   - Padding horizontal: 20px

8. **Spacing:** 16px

9. **Password Field (Glass Style)**
   - Same glass style as email
   - Left icon: Lock icon, white @ 40%, 20px
   - Right icon: Eye icon, white @ 40%, 20px
   - Placeholder: "Password", white @ 40%

10. **Spacing:** 24px

11. **Sign In Button**
    - Full width, height: 56px, border-radius: 16px
    - Background: `#4CD964` (success/500)
    - Text: "Sign In", bodySemiBold, white

12. **Spacing:** 32px

13. **"Forgot Password?" link**
    - captionRegular, white @ 60%

14. **Spacing:** 16px

15. **Register Row (centered)**
    - "Don't have an account? " — captionRegular, white @ 40%
    - "Create Account" — captionMedium, `#4CD964`

---

## Screen 2: REGISTER (375×812)

**Background:** `#FFFFFF`

### Header
- Padding: 8px horizontal, 8px vertical
- Back button: 44×44px, icon ArrowBack `#1F2C37`, bg `#F7F9FC`, radius 12px
- Title: "Create Account", centered, 18px Bold 700, `#1F2C37`
- Right spacer: 48px (for symmetry)

### Content (padding: 24px)

1. **Progress Bar (3 segments)**
   - 3 equal bars, height: 4px, radius: 2px, spacing: 8px between
   - Segment 1 & 2: `#4CD964`
   - Segment 3: `#E8ECF0`

2. **Spacing:** 24px

3. **Subtitle:** "Complete your profile to get started"
   - captionRegular, `#78828A`

4. **Spacing:** 32px

5. **Avatar Upload (centered)**
   - Circle: 96×96px
   - Background: `#F7F9FC`, border: 2px `#E8ECF0`
   - Person icon: 40px, `#78828A`
   - Plus badge: 32×32px circle, bottomRight, bg `#1F2C37`, icon Plus 16px white

6. **Spacing:** 32px

7. **Form Fields** (each: label + 8px gap + input + 20px gap)
   - Label: captionMedium, `#1F2C37`
   - Input: standard input spec (56px height, 16px radius, 2px border `#E8ECF0`)

   a. "Full Name" → hint "John Doe"
   b. "Email" → hint "john@example.com"
   c. "Password" → hint "••••••••" (obscured)

8. **Spacing:** 20px

9. **Currency Dropdown**
   - Label: "Currency", captionMedium
   - Dropdown container: same border as input, icon: chevron down `#78828A`
   - Value: "TND - Tunisian Dinar", bodyRegular

10. **Spacing:** 32px

11. **"Create Account" Button**
    - Full width, 56px, radius 16px
    - Background: `#1F2C37`, text white, bodySemiBold

12. **Bottom link** (centered)
    - "Already have an account? " — captionRegular, `#78828A`
    - "Sign in" — captionMedium, `#4CD964`

---

## Screen 3: DASHBOARD (375×812)

**Background:** `#F7F9FC`

### Header (white bar)
- Padding: 20px left/right, 12px top, 16px bottom
- **Avatar circle:** 44×44px, bg `#1F2C37`, Text "AJ" white 14px SemiBold
- **Text column (12px from avatar):**
  - "Welcome back," — smallMedium (12px), `#78828A`
  - "Alex Johnson" — bodySemiBold 14px, `#1F2C37`
- **Notification bell** (right): 44×44px circle, bg `#F7F9FC`, icon Bell 22px `#1F2C37`
  - Red dot: 8×8px circle, `#FF3B30`, positioned top-right of bell

### Balance Card (margin: 20px horizontal, 8px top, 24px bottom)
- Full width, padding: 32px
- Border radius: 28px, bg: `#1F2C37`, shadow: lg
- **"Total Balance"** — captionRegular, white @ 70%
- **"3,250.50 TND"** — balanceDisplay (42px ExtraBold), white
- **Spacing:** 24px
- **Income/Expense stats row (centered, 48px gap):**
  - Each: 32×32px circle (white @ 20%), icon 16px
    - Income: arrow-down icon `#4CD964`, label "Income", amount value
    - Expense: arrow-up icon `#FF3B30`, label "Expense", amount value
  - Label: smallMedium, white @ 70%
  - Amount: bodySemiBold 14px, white

### Quick Actions (margin: 20px horizontal)
- 3 equal-width cards, 12px gap between
- Card: white, radius 16px, shadow sm, vertical padding 16px
- Each card:
  - Icon circle: 40×40px, color @ 10% opacity bg
    - "Add Income": Plus icon, `#4CD964`
    - "Add Expense": CreditCard icon, `#FF3B30`
    - "Goals": Target icon, `#1F2C37`
  - 8px spacing
  - Label: smallMedium, `#1F2C37`, centered

### Recent Transactions Section (24px top gap)
- **Header row** (padding 20px horizontal):
  - "Recent Transactions" — h3SemiBold 18px
  - "View All" — captionMedium, `#4CD964`
- **Transaction list** (padding 20px horizontal, 8px top):
  - Each `TransactionTile` (see component spec), 12px bottom margin

### Bottom Navigation (see component spec)

---

## Screen 4: TRANSACTIONS (375×812)

**Background:** `#F7F9FC`

### Header (white bar)
- "Transactions" — h2Bold 20px, `#1F2C37`
- Search icon button (right): bg `#F7F9FC`, icon Search, radius 12px

### Filter Tabs (margin: 20px horizontal, 8px vertical)
- Container: bg `#F7F9FC`, radius 16px, padding 4px
- 3 tabs: "All", "Income", "Expense"
- Active tab: white bg, radius 12px, shadow sm
  - Text: captionMedium, `#1F2C37`, FontWeight 600
- Inactive tab: transparent bg
  - Text: captionMedium, `#78828A`, FontWeight 500

### Summary Cards Row (20px horizontal, 12px top, 16px bottom, gap: 12px)
- 2 equal cards, white, radius 16px, shadow sm, padding 16px
- **Income card:**
  - Icon circle: 32×32px, bg `#4CD964` @ 10%, TrendingUp icon 16px `#4CD964`
  - Text "Income" — smallMedium
  - Amount: h3SemiBold 18px, `#4CD964`
- **Expense card:**
  - Icon circle: 32×32px, bg `#FF3B30` @ 10%, TrendingDown icon 16px `#FF3B30`
  - Text "Expense" — smallMedium
  - Amount: h3SemiBold 18px, `#FF3B30`

### History Section Header
- "HISTORY" — smallMedium, `#78828A`, letter-spacing 1.2, weight 600
- "Filter" with filter icon — captionMedium, `#1F2C37`

### Transaction List
- Each TransactionTile, 12px bottom spacing

### Bottom Navigation

---

## Screen 5: ADD TRANSACTION (375×812)

**Background:** `#FFFFFF`

### Header
- Close button (X icon): 44×44px, bg `#F7F9FC`, radius 12px
- Title: "New Transaction", h3SemiBold 18px, centered
- Right spacer: 48px

### Type Toggle (20px horizontal, 8px vertical)
- Container: bg `#F7F9FC`, radius 16px, padding 4px
- 2 tabs: "Income" / "Expense"
- Active tab: white bg, radius 12px, shadow
  - Income active: text `#4CD964`
  - Expense active: text `#FF3B30`
- Inactive: transparent, neutral text

### Amount Display (24px vertical padding, centered)
- "Amount" — captionRegular, `#78828A`
- **Amount value:** amountLarge (48px ExtraBold 800)
  - Income mode: `#4CD964`
  - Expense mode: `#FF3B30`
- " TND" suffix: h2Bold, same color

### Category Selection (20px horizontal)
- "Select Category" — bodySemiBold 14px
- 12px spacing
- **Grid of category chips:** 4 per row, 12px spacing
  - Each chip: ~(screenWidth - 76)/4 wide, vertical padding 12px
  - Border: 1px `#E8ECF0` (or 2px `#1F2C37` when selected)
  - Radius: 16px, white bg
  - Icon container: 44×44px, category color @ 15% bg, radius 12px
  - Icon: 22px, category color
  - Label below: smallMedium 11px, `#1F2C37`

### Note Input (20px horizontal)
- Standard input, hint: "Add a note (optional)"

### Date Selector (12px gap, 20px horizontal)
- Container: bg `#F7F9FC`, radius 16px, padding 16px
- Calendar icon: 20px, `#78828A`
- Date text: captionMedium, `#1F2C37`

### Numeric Keypad (20px horizontal, 16px gap)
- 4×3 grid, 8px spacing
- Keys 1-9, ".", "0", "⌫"
- Each key: bg `#F7F9FC`, radius 12px, aspect ratio 2:1
- Text: 20px SemiBold, `#1F2C37`

### Submit Button (20px horizontal, 8px top, 16px bottom)
- Full width, 56px, radius 16px
- Background: `#1F2C37`, text white bodySemiBold
- "Add Income" or "Add Expense" based on mode

---

## Screen 6: CATEGORIES (375×812)

**Background:** `#F7F9FC`

### Header (white bar)
- "Categories" — h2Bold 20px
- Add button (right): icon Plus, bg `#F7F9FC`, radius 12px

### Tab Selector (20px horizontal, 8px vertical)
- Container: bg `#F7F9FC`, radius 16px, padding 4px
- 2 tabs: "Expense", "Income"
- Same active/inactive style as transactions filter

### Category Grid (20px horizontal, 16px top)
- 2 columns, 12px gap, aspect ratio ~0.82
- **Each CategoryCard:**
  - White bg, radius 20px, shadow sm, padding 20px
  - Icon: 48×48px, category color @ 20% bg, radius 14px, icon 24px
  - 12px gap
  - Name: bodySemiBold 14px
  - 4px gap
  - "spent / budget TND" — smallMedium, `#78828A`
  - 12px gap
  - Progress bar: 8px height, radius 4px, track `#E8ECF0`, fill category color
  - 8px gap
  - "XX%" — smallMedium

### Bottom Navigation

---

## Screen 7: STATISTICS (375×812)

**Background:** `#F7F9FC`

### Header (white bar)
- "Statistics" — h2Bold 20px
- More (⋯) icon button (right): bg `#F7F9FC`, radius 12px

### Time Filter (20px horizontal, 8px vertical)
- Container: bg `#F7F9FC`, radius 16px, padding 4px
- 4 tabs: "Day", "Week", "Month", "Year"
- Active: white bg, radius 12px, shadow sm
  - captionMedium 13px, `#1F2C37`, weight 600
- Inactive: captionMedium 13px, `#78828A`, weight 500

### Summary Stats Row (20px horizontal, 12px top, 16px bottom, 8px gap)
- 3 equal cards, white, radius 16px, shadow sm, padding 14px
- Each: value (h3SemiBold 16px, colored) + 4px gap + label (smallMedium)
  - "Income" → `#4CD964`
  - "Expense" → `#FF3B30`
  - "Saved" → `#1F2C37`

### Expense Overview Card (20px horizontal)
- White, radius 24px, shadow sm, padding 20px
- Title: "Expense Overview" — h3SemiBold 18px
- 20px spacing
- **Bar Chart:** 200px height
  - 7 bars (daily), red `#FF3B30`, width 20px, top radius 6px
  - Day labels below: smallMedium
  - No grid, no axis lines

### Spending by Category Card (16px top gap, 20px horizontal)
- White, radius 24px, shadow sm, padding 20px
- Title: "Spending by Category" — h3SemiBold 18px
- 20px spacing
- **Donut Chart:** 200px height
  - Center space radius: 60px
  - Sections: colored by category, radius 40px, 2px gap
  - Center text: total expense (h2Bold) + "TND" (smallMedium)
- 16px spacing
- **Legend:** Wrap layout, 16px horizontal spacing, 8px vertical
  - Each: 10×10px colored circle + 6px gap + category name (smallMedium)

### Bottom Navigation

---

## Screen 8: BUDGET GOALS (375×812)

**Background:** `#F7F9FC`

### Header (white bar)
- Back button + Title "Budget Goals" centered + Add button (right)
- Same button style as other headers

### Summary Card (20px margin all sides)
- Background: `#1F2C37`, radius 24px, shadow lg, padding 24px
- "February 2026 Progress" — captionRegular, white @ 70%
- 8px gap
- "X of Y goals on track" — h2Bold 24px, white
- 16px gap
- Status indicators row (16px gap between):
  - Green dot `#4CD964` + "X On Track"
  - Red dot `#FF3B30` + "X Exceeded"
  - Yellow dot `#FFEAA7` + "X Warning"
  - Each: 8×8px circle + 6px gap + smallMedium white @ 70%

### "YOUR GOALS" section header
- smallMedium, `#78828A`, letter-spacing 1.2, weight 600

### Goals List (20px horizontal)
- **Each Goal Card:** white, radius 20px, shadow sm, padding 20px, 16px bottom margin
  - **Top row:**
    - Icon: 44×44px, category color @ 20% bg, radius 12px, icon 22px
    - 12px gap
    - Name: bodySemiBold 14px
    - Subtitle: "current / target TND" — smallMedium, `#78828A`
    - Percentage: bodySemiBold, green or red
  - 16px gap
  - **Progress bar:** 8px height, radius 4px
    - Track: `#E8ECF0`
    - Fill: green (on track), yellow `#F7DC6F` (warning), red (exceeded)
  - **Warning/exceeded text** (if applicable): 8px gap
    - Icon 14px + 4px gap + smallMedium colored text

---

## Screen 9: PROFILE (375×812)

**Background:** `#F7F9FC`

### Header (white bar)
- "Profile" — h2Bold 20px
- Settings icon button (right): bg `#F7F9FC`, radius 12px

### Profile Card (20px horizontal, 8px vertical)
- White, radius 24px, shadow sm, padding 24px
- **Avatar (centered):**
  - 96×96px circle
  - Gradient: `#4CD964` → `#2ECC71` (top-left to bottom-right)
  - Text: "AJ" — h1Bold 32px, white
  - Edit badge: 32×32px circle, bottomRight, bg `#1F2C37`, Edit icon 14px white
- 16px gap
- "Alex Johnson" — h3SemiBold
- 4px gap
- "alex.johnson@email.com" — captionRegular, `#78828A`
- 20px gap
- **Stats row** (centered, separated by 1px × 32px `#E8ECF0` dividers, 24px margin):
  - "Transactions" / "156"
  - "Categories" / "12"
  - "Goals" / "5"
  - Value: h3SemiBold, Label: smallMedium

### "SETTINGS" section header
- 20px left, 16px top, 12px bottom
- smallMedium, `#78828A`, letter-spacing 1.2, weight 600

### Settings Menu (20px horizontal)
- White container, radius 24px, shadow sm
- **Menu items** (each: 20px horizontal padding, 16px vertical):
  - Icon container: 40×40px, bg `#F7F9FC`, radius 12px, icon 20px `#3D4F5F`
  - 12px gap
  - Name: bodySemiBold 14px
  - Subtitle: smallMedium, `#78828A`
  - Right: chevron icon 20px `#A5B0B9` (or Toggle switch for Dark Mode)
  - Divider between items: height 1px, `#E8ECF0`, indent 72px from left

| Icon              | Name                | Subtitle              | Type    |
|-------------------|---------------------|-----------------------|---------|
| Person            | Account Settings    | Personal info, security | arrow |
| Notifications     | Notifications       | Push, email, SMS      | arrow   |
| Globe             | Currency            | TND - Tunisian Dinar  | arrow   |
| Moon              | Dark Mode           | System default        | toggle  |
| Shield            | Privacy & Security  | Password, biometrics  | arrow   |
| HelpCircle        | Help & Support      | FAQ, contact us       | arrow   |

### Logout Button (20px horizontal, 24px top)
- Full width, 56px, radius 16px
- Background: `#FF3B30` @ 10%
- Icon: Logout 20px `#FF3B30` + 8px gap
- Text: "Log Out" — bodySemiBold, `#FF3B30`

---

## 🧭 Bottom Navigation Bar (shared across screens 3, 4, 6, 7, 9)

- Background: white, top shadow (`#1F2C37` @ 5%, blur 20, offset 0,-4)
- Height: 64px (content area)
- 4 items equally spaced:

| Icon (outline/fill)       | Label         |
|---------------------------|---------------|
| Home outline / Home       | Home          |
| Wallet outline / Wallet   | Transactions  |
| PieChart outline / filled | Stats         |
| Person outline / filled   | Profile       |

- Active: icon `#1F2C37`, label 11px weight 600 `#1F2C37`
- Inactive: icon `#A5B0B9`, label 11px weight 500 `#A5B0B9`

### FAB (Floating Action Button)
- Centered over nav bar (or offset as Figma layout allows)
- 56×56px, radius 28px (circle), bg `#1F2C37`, shadow elevation 8
- Plus icon: 28px, white

---

## 📋 Figma Setup Checklist

1. [ ] Create a new page or use existing "Page 1"
2. [ ] Set up all **Color Styles** from the table above
3. [ ] Set up all **Text Styles** using Urbanist font
4. [ ] Set up **Effect Styles** for shadows (sm, md, lg, xl)
5. [ ] Create **Component** frames for reusable elements:
   - Button/Primary, Button/Secondary, Button/FAB
   - Input Field
   - Transaction Tile
   - Category Card
   - Balance Card
   - Bottom Navigation Bar
   - Progress Bar
   - Toggle
6. [ ] Create 9 frames (375×812) named:
   - LOGIN, REGISTER, DASHBOARD, TRANSACTIONS
   - ADD_TRANSACTION, CATEGORIES, STATISTICS
   - BUDGET_GOALS, PROFILE
7. [ ] Build each screen using the specifications above
8. [ ] Apply Auto Layout where appropriate for proper spacing
