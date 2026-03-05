# Profile Subpages — Figma AI Prompts (each prompt standalone)

All prompts below follow your tokens in `design_tokens.json` and match the Flutter Profile UI style (cards: radius 24, shadow sm, rows: icon tile 40×40, divider indent 72, padding 20/16).

---

## 0) UX Logic (use this in the prototype)

- **Account Settings** → **New page** (push navigation). Reason: form editing needs full-screen focus + keyboard.
- **Notifications** → **New page** (push). Reason: multiple toggles + granular control.
- **Currency** → **Bottom sheet modal** (searchable list + radio). Reason: single selection, quick.
- **Dark Mode** → **Bottom sheet modal** with 3 options (System/Light/Dark). Reason: global preference; avoid accidental toggles.
- **Privacy & Security** → **New page** (push). Reason: security options + confirmations.
- **Help & Support** → **New page** (push). Reason: browse FAQ + contact actions.
- **Edit avatar badge** → **Bottom sheet modal** (Choose photo / Take photo / Remove). Reason: short action menu.
- **Top-right settings icon** → **New page** “Settings” (push) OR deep-link to “Account Settings”. Best practice: do not duplicate; prefer deep-link to Account Settings.

International UX rules baked in for each prompt:
- Support **long translations** (truncate with ellipsis where needed; allow 2 lines for subtitles).
- Support **RTL** (mirror chevrons, alignment, and back navigation).
- Touch targets minimum **44×44**.
- Contrast + readable text sizes.

---

## Prompt 1 — Account Settings (New Page)

Create a mobile screen **375×812** named **“Account Settings”**. Style must match a premium budgeting app.

Use **Urbanist**. Background `#F7F9FC`. Surfaces `#FFFFFF`. Radius: 24 for cards, 16 for inputs/buttons, 12 for small icon tiles. Shadow sm: y=2 blur=8 color `#1F2C37` @ 6%.

### Header
- White top bar
- Padding: 20 left/right, 12 top, 16 bottom
- Left: back button 44×44, bg `#F7F9FC`, radius 12, icon arrow-left `#1F2C37`
- Center title: “Account Settings” (Urbanist 20px bold, `#1F2C37`)
- Right: optional “Save” text button (14–16 semi-bold, success color `#4CD964`) but disabled state uses `#A5B0B9`.

### Content (scrollable)
Place content in **cards** (white, radius 24, shadow sm) with margin 20.

Card A: **Profile**
- Avatar row: 56×56 circle gradient (success), name + email
- Action: “Change photo” row (chevron)

Card B: **Personal info** (form)
- Label style: 12–14 medium `#78828A`
- Inputs: height 56, radius 16, border 2px `#E8ECF0`, padding horizontal 20, text `#1F2C37`, placeholder `#A5B0B9`
Fields:
- Full Name (Alex Johnson)
- Email
- Phone (with country code selector, default +216)

Card C: **Security**
Rows with icon tile 40×40 (bg `#F7F9FC`, radius 12, icon `#3D4F5F`), title + subtitle, chevron:
- Change Password (subtitle: “Update your password”)
- Two-factor Authentication (subtitle: “Add an extra layer of security”)

### Save behavior hints (UI only)
- Save button pinned at bottom as full-width primary button (height 56, radius 16, bg `#1F2C37`, text white).
- Show inline error text under fields in danger color `#FF3B30`.

Accessibility/international:
- Allow long names/emails; inputs expand / scroll.
- RTL mirrored layout.

---

## Prompt 2 — Notifications (New Page)

Create a mobile screen **375×812** named **“Notifications”**.

Use Urbanist. Background `#F7F9FC`. Header same style as Profile.

### Header
- Back button left (44×44)
- Title centered: “Notifications” (20 bold)
- Right: “Reset” text button (14 semi-bold `#78828A`)

### Content
Use 2–3 white cards (radius 24, shadow sm, margin 20, padding 16–20) with toggles.

Card 1: **General**
Rows (padding 20 horizontal, 16 vertical, divider indent 72) with icon tile 40×40:
- Push Notifications (toggle)
- Email Notifications (toggle)
- SMS Notifications (toggle)

Card 2: **Budget alerts**
- Overspending alerts (toggle)
- Goal progress updates (toggle)
- Weekly summary (toggle)

Card 3: **Quiet hours**
- Row opens a time picker page or bottom sheet: “Quiet hours” (subtitle: “22:00 – 07:00”)
- Row opens day selector: “Active days” (subtitle: “Mon–Fri”)

Switch styling:
- ON thumb `#4CD964`.

International UX:
- Explain toggles with concise subtitles.
- Ensure all rows are tappable 44px+.
- RTL support.

---

## Prompt 3 — Currency (Bottom Sheet Modal)

Create a **bottom sheet modal** UI for a 375px wide phone named **“Select Currency”**.

### Container
- Sheet background white, top corners radius 24
- Top grabber: 36×4, color `#E8ECF0`, centered, margin top 8
- Title row: “Select Currency” (18–20 bold `#1F2C37`) + close (X) button 44×44 bg `#F7F9FC` radius 12

### Search
- Search field height 56, radius 16, border 2px `#E8ECF0`, left search icon, placeholder “Search currency” in `#A5B0B9`

### List
Scrollable list with rows:
- Left: currency code + name (e.g., “TND — Tunisian Dinar”)
- Right: radio selection (selected uses `#4CD964`)
- Divider between rows color `#E8ECF0`

### Footer
- Primary button “Confirm” full width height 56 radius 16 bg `#1F2C37` text white

International UX:
- Support long currency names; wrap to 2 lines.
- RTL mirrors close icon and alignment.

---

## Prompt 4 — Dark Mode (Bottom Sheet Modal)

Create a **bottom sheet modal** named **“Appearance”**.

Style: white sheet, radius 24, grabber, title “Appearance” and close button.

Content:
- 3 radio options in a white list:
  1) System default (subtitle: “Match device settings”)
  2) Light
  3) Dark
- Selected radio uses `#4CD964`.

Footer:
- Primary button “Apply” (bg `#1F2C37`).

International UX:
- Keep option labels short.
- Provide subtitle only for System option.
- RTL support.

---

## Prompt 5 — Privacy & Security (New Page)

Create a mobile screen **375×812** named **“Privacy & Security”**.

### Header
Back button + centered title “Privacy & Security”.

### Content
Use stacked cards (white, radius 24, shadow sm, margin 20).

Card A: **Security** rows with chevrons:
- Change Password (subtitle “Update your password regularly”)
- Biometric Lock (row with toggle)
- App Passcode (subtitle “Require passcode on open”)

Card B: **Privacy**
- Data & Permissions (subtitle “Manage access and sharing”)
- Download my data (subtitle “Export as JSON/CSV”)
- Delete account (danger accent: title `#FF3B30`, icon tile lightly tinted danger 10%)

Confirm patterns:
- Delete account row opens a confirmation modal (not designed here) with strong warnings.

International UX:
- Mark destructive action clearly.
- Use concise, scannable subtitles.
- RTL support.

---

## Prompt 6 — Help & Support (New Page)

Create a mobile screen **375×812** named **“Help & Support”**.

### Header
Back + centered title.

### Content
Card 1: **Search FAQ**
- Search field like Currency search.

Card 2: **FAQ list**
- Accordion-style list items (title + chevron) inside a white card.
Examples:
- “How do I add a transaction?”
- “How do budgets work?”
- “How to change currency?”

Card 3: **Contact**
Two big action buttons (secondary style):
- “Email Support” (icon mail)
- “Live Chat” (icon message)

International UX:
- Keep FAQ titles short; allow 2 lines.
- RTL support.

---

## Prompt 7 — Edit Photo (Bottom Sheet Action Menu)

Create a **bottom sheet action menu** named **“Profile Photo”**.

Sheet:
- White background, radius 24, grabber, title “Profile Photo” + close.

Actions list (each row height ~56, icon left, label, no subtitle):
- Take Photo
- Choose from Library
- Remove Photo (text and icon in danger `#FF3B30`)

International UX:
- Use clear verbs.
- Destructive action separated with extra top margin or subtle divider.
- RTL support.

---

## Prompt 8 — Settings (New Page, optional)

Create a screen **“Settings”** that reuses the same settings list card from Profile, but adds a top section for “App” preferences.

Header: back + title “Settings”.

Content:
- Card: App
  - Language (subtitle: “English (United States)”)
  - Currency (subtitle: “TND — Tunisian Dinar”)
  - Appearance (subtitle: “System default”)
- Card: Account
  - Account Settings
  - Privacy & Security
- Card: Support
  - Help & Support

Use same row style: icon tile 40×40, padding 20/16, divider indent 72, chevrons `#A5B0B9`.

International UX:
- Language selector uses bottom sheet list with search.
- RTL support.
