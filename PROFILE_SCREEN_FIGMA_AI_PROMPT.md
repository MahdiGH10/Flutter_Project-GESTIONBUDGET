# Figma AI Prompt — Screen 9: Profile (Copy/Paste)

Create a mobile app screen named **“Profile”** for a budget app. Use an iPhone frame **375×812**. Use **Urbanist** font for all text. Follow these color tokens exactly:
- Background: `neutral/100 #F7F9FC`
- Surfaces/cards: `neutral/0 #FFFFFF`
- Primary text: `neutral/900 #1F2C37`
- Secondary text: `neutral/500 #78828A`
- Icons secondary: `neutral/700 #3D4F5F`
- Disabled/chevron: `neutral/400 #A5B0B9`
- Dividers/tracks: `neutral/200 #E8ECF0`
- Primary brand: `primary/900 #1F2C37`
- Success: `success/500 #4CD964`
- Danger: `danger/500 #FF3B30`

Use these text styles (Urbanist):
- Title: **h2Bold** but set size to **20px**, weight **700**, color `#1F2C37`
- Section label: **smallMedium** 12px weight 600, letter-spacing **1.2**, color `#78828A`
- Item title: 14px semi-bold (use bodySemiBold but font-size **14**) color `#1F2C37`
- Item subtitle: 12px medium color `#78828A`
- Profile name: **h3SemiBold** 20px weight 600
- Email: 14px regular color `#78828A`

## Layout (top to bottom)
Overall page background: **`#F7F9FC`**.

### 1) Header bar (top)
- Full width container, background **white**
- Padding: **20 left/right, 12 top, 16 bottom**
- Left: text **“Profile”** (20px bold)
- Right: **settings icon button**
  - Size **44×44**
  - Background `#F7F9FC`
  - Corner radius **12**
  - Icon: “settings” outline, size ~22, color `#1F2C37`

### 2) Profile card
- Container centered with margin **20 left/right** and **8px** top/bottom
- Padding **24**
- Background white, corner radius **24**
- Shadow “sm”: y=2 blur=8 color `#1F2C37` at **6%**

Inside the card (center aligned):
- **Avatar**: 96×96 circle with a diagonal gradient (top-left to bottom-right) from `#4CD964` to `#2ECC71`
  - Center initials: **“AJ”** in white, **32px bold**
  - Bottom-right overlay edit badge: **32×32** circle, fill `#1F2C37`
    - Edit pencil icon 14px, white
- Spacing under avatar: **16**
- Name: “Alex Johnson” (h3SemiBold)
- Spacing: **4**
- Email: “alex.johnson@email.com” (14 regular, `#78828A`)
- Spacing: **20**
- **Stats row** centered with 3 stats:
  - Stat 1: value **156** (h3SemiBold), label “Transactions” (12 medium)
  - Stat 2: value **12**, label “Categories”
  - Stat 3: value **5**, label “Goals”
  - Between stats add vertical dividers: **1×32** color `#E8ECF0`, with **24px** horizontal margin on both sides of each divider.

### 3) Section label
- Text: **“SETTINGS”**
- Padding: **20 left**, **16 top**, **12 bottom**
- Style: 12px, weight 600, letter spacing 1.2, color `#78828A`

### 4) Settings list card
- Container with margin **20 left/right**
- Background white, corner radius **24**
- Shadow sm (same as profile card)

Create **6 menu rows**, each row:
- Row padding: **20 horizontal, 16 vertical**
- Left icon container: **40×40**, bg `#F7F9FC`, radius **12**
  - Icon size 20, color `#3D4F5F`
- Gap between icon container and text: **12**
- Text stack (left aligned):
  - Title 14 semi-bold (`#1F2C37`)
  - Subtitle 12 medium (`#78828A`) — BUT for the toggle row, do not show subtitle text.
- Right side:
  - For normal rows: chevron-right icon size 20 color `#A5B0B9`
  - For “Dark Mode”: a toggle switch (ON color thumb `#4CD964`), aligned center vertically

Menu items (in this exact order):
1. Icon person, “Account Settings”, subtitle “Personal info, security”
2. Icon bell, “Notifications”, subtitle “Push, email, SMS”
3. Icon globe/language, “Currency”, subtitle “TND - Tunisian Dinar”
4. Icon moon/dark mode, “Dark Mode”, toggle on right (no subtitle text visible in the row)
5. Icon shield, “Privacy & Security”, subtitle “Password, biometrics”
6. Icon help, “Help & Support”, subtitle “FAQ, contact us”

Between rows add dividers:
- Height **1px**, color `#E8ECF0`
- Indent from left: **72px** (so divider starts after icon + gap)
- No divider after the last row.

### 5) Logout button
- Place below settings card with padding **20 left/right**, **24 top**, and leave extra bottom space for nav: **100px bottom padding**
- Button size: full width, height **56**
- Background: `#FF3B30` at **10% opacity** (light red)
- Corner radius **16**
- Content centered horizontally:
  - Logout icon 20px, color `#FF3B30`
  - Gap **8**
  - Text “Log Out” 16 semi-bold, color `#FF3B30`

### 6) Bottom navigation + FAB (shared app nav)
Add a bottom navigation bar (fixed at bottom):
- Background white, height **64px** plus safe-area
- Top shadow: `#1F2C37` at 5%, blur 20, offset 0,-4
- 4 items equally spaced: **Home**, **Transactions**, **Stats**, **Profile**
- Active item: **Profile** (icon + label color `#1F2C37`, label 11px weight 600)
- Inactive items: color `#A5B0B9`, label 11px weight 500

Add a centered **FAB** overlapping the nav:
- Size **56×56**, circle, background `#1F2C37`
- Shadow elevation feel (use stronger shadow similar to “lg”)
- Plus icon size ~28, white.

## Constraints / structure
Use Auto Layout for:
- Header row
- Profile card contents (vertical)
- Settings list (vertical stack with dividers)
- Bottom nav items
Keep all spacing exactly as specified.

## Quick verification checklist
- Header padding is **20/12/20/16** and settings button is **44×44 radius 12**
- Both cards are **white, radius 24, shadow sm**
- Avatar is **96 circle** + **32 edit badge**
- Dividers in stats are **1×32** with **24px** side margins
- Settings rows have **40×40** icon tile, **12px** gap, and divider **indent 72**
- Logout button is **56px** height, **radius 16**, light red background, red text/icon
- Bottom nav present and **Profile is active**, plus centered FAB
