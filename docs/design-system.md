# Quickshell Design System (QDS)

## Philosophy: The Calm Workspace

In the era of the attention economy, an operating system shell should not fight for the user's focus. The Quickshell Design System (QDS) is built upon the principle of the **Calm Workspace**. 

System states, notifications, and background tasks should be strictly informative, remaining in the peripheral vision until intentionally engaged by the user. UI elements must provide reassurance without inducing anxiety or "alert fatigue."

## 1. Color Semantics & Hierarchy

QDS utilizes the **Gruvbox Dark** palette, inherently designed to reduce eye strain through lower contrast ratios and warm, retro-inspired tones.

Colors in QDS are not merely decorative; they are strictly semantic. We avoid using pure, highly saturated "bright" accents for persistent background states.

### 1.1 Structural Colors
- **`bg0_hard` (`#1d2021`)**: Base shell background (maximum depth).
- **`bg0` (`#282828`)**: Standard surfaces.
- **`bg1` (`#3c3836`)**: Elevated surfaces (cards, popup backgrounds).
- **`bg2` (`#504945`)**: Interactive elements (buttons, inputs) in their resting state.

### 1.2 Foreground & Typography
- **`fg1` (`#ebdbb2`)**: Primary text (active/focused items).
- **`fg2` (`#d5c4a1`)**: Secondary text (standard informational text).
- **`fg3` (`#bdae93`)**: Tertiary text (muted details, timestamps).

## 2. Privacy & Status Indicators (Monochrome Restraint)

The most critical application of the *Calm Workspace* philosophy is how we handle system security and privacy alerts (Camera, Microphone, and Screencasting).

### 2.1 The Problem with "Alert Colors"
Historically, UIs have used bright reds, oranges, or a "traffic light" array of colors (green for camera, yellow for mic) to denote active recording. However, introducing multiple highly saturated colors to a persistent top panel completely shatters the aesthetic unity of the shell and creates visual noise. When a user is in a one-hour video call, a bright colored dot is not a helpful warning; it is a distraction that constantly fights for attention.

### 2.2 Shape Over Color
QDS firmly rejects the multi-color approach in favor of **Monochrome Restraint**. We rely on two principles to convey privacy states:
1. **Presence**: The simple appearance of the icon on the panel is the alert.
2. **Shape**: We rely on the universally recognized silhouettes of a camera, microphone, or screen.

| Indicator | QDS Mapping | Hex | Purpose |
| :--- | :--- | :--- | :--- |
| **All Privacy Alerts** | `privacyIndicator` (`fg2`) | `#d5c4a1` | Seamlessly blends with other informational icons (Wi-Fi, Volume). |

**Design Rule:** Privacy indicators must use the `fg2` (Secondary Text) color. They should look exactly like standard system icons. They inform the user through their quiet *presence*, respecting the user's focus and maintaining the absolute cleanliness of the visual environment.

## 3. Iconography

Icons must follow a strict rendering hierarchy to maintain panel consistency:

1. **System Control Icons (HUDBar):** Must use `iconColor` overrides to enforce single-color or semantic-color rendering (e.g., matching text color or privacy semantic colors).
2. **Application Icons:** Must *never* be color-overridden. Applications (Chrome, Discord, Steam) are brands; altering their colors destroys recognition.
3. **Missing Icons (The Monogram Fallback):** When an application lacks a provided icon, QDS uses a procedurally generated, aesthetically pleasing "Monogram" (First letter centered on a harmoniously hashed colored background) rather than ugly system placeholders (e.g., missing-texture pink/black grids).