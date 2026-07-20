# Players

The starting roster. Quality over quantity — three distinct, hand-tuned characters.

Every player shares the same base stats: **move speed 30**, **armor 0**. Each one
then applies its own modifiers on top (see the individual docs, and
[stats.md](../stats.md) for what each stat does).

- The Newbie (fragile late-bloomer, crits & attack speed) — [TheNewbie.md](TheNewbie.md)
- Mr. Barret (tanky heavy hitter) — [MrBarret.md](MrBarret.md)
- Natsumi (balanced all-rounder) — [Natsumi.md](Natsumi.md)

## Art direction

Each player is generated **one at a time** from the shared circle template at
[assets/base/PlayerCircle.png](../../assets/base/PlayerCircle.png) — never as a grid
sheet. Generating from the same base circle keeps every character on an almost
identical round silhouette while giving each a distinct look. Exports are
256×256 RGBA with a transparent background, following the visual rules in
[game-setting.md](../../game-setting.md).
