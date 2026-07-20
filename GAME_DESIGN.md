# Game design

Read the context.md, plans.md, progress.md, game-setting.md, optimizations.md first

Update the progress.md to contain the progress on the new plans I'm about to tell you

I want you to replace the current plans in plans.md with these ones

## Global idea

The current state of the game is hard to call raw. It's worse than raw. It's unplayable in terms of fun. In order to make it just a tiny bit fun, a throughout remaking is required with a much better game design. Here are the top 3 things to rework in the game

### Reworking the players

There are too many players in the game. Not in terms of count, but in terms of mindlessly added characters.
Let's remake the players from scratch. I want quality over quantity.
We'll start with just 3 players.

Every player has these base stats:
- move speed — 30
- armor — 0

**The Newbie**. No one knows his name, he's just a rookie who tries to find his way of cooking. He's awkward but has a huge potential. He's got some hidden powers waiting to be unleashed. Initial Stats:
- 90HP
- -12% damage
- +18% attack speed
- +24% crit change
- +12% luck

**Mr. Barret**. He didn't want to become a cook, but his talent forced him to. He dreamed of becoming a business man but he was quite a failure at it. So he became doing the only thing he could — cooking. Now he wears a suite thinking one day he can open his own restaurant and become the business man he wanted to be.
- 120HP
- +24% damage
- 0% attack speed
- +4% crit change
- 0% luck

**Natsumi**. A Japanese girl with a big dream of becoming the best sushi maker in Japan. She traveled all the way to Tokyo to learn from the best. Now she wants to explore every single cousine there is to understand the foundations of cooking. Her dream is to reinvent the food itself. To become the Einstein of cooking.
- 80HP
- +12% damage
- +12% attack speed
- +12% crit change
- +6% luck

Also, let's rework the players' sprites. Let's stop generating grids of players. Let's generate each one by one instead. Each player should be generated inside a perfect circle. Add this perfect circle to assets/base/PlayerCircle.png. We'll generate each player from this png image so they have almost identical shape but different looks.

I want you to add a docs/players/TheNewbie.md, docs/players/MrBarret.md and docs/players/Natsumi.md for each player. Don't copy my description as is — English ins't my first language so be sure to fix any mistakes and add a little bit of details by yourself. Also, add docs/players/index.md as an index file for the players in the format of `- player-name (the shortest possible description, just a few words basically) — path/to/the/docs/md/file`

### Reworking the weapons & upgrades

Same problem — too many mindlessly added weapons & upgrades. Let's fix it the same way as the players problem.

I want a different system for the weapons & upgrades. There should be 5 types of things to buy/select for the player:
- weapons — already in the game but need reworking from scratch. Remove all the present weapons with these ones:
  - Kitchen Knife (melee weapon)
    - Attack speed: 1 attack per 0.8s
    - Damage per attack: 25
    - Area of attack: 20
    - Attack range: 10
  - Frying Pan (melee weapon)
    - Attack speed: 1 attack per 1.9s
    - Damage per attack: 60
    - Area of attack: 25
    - Attack range: 15
  - Rotten Tomato (ranged weapon, projectiles are rotten tomatoes)
    - Attack speed: 1 attack per 1.2s
    - Damage per attack: 40
    - Area of attack: 10
    - Attack range: 80
- level upgrades — already in the game but need reworking. Replace all the level upgrades with these ones:
  - Armor +1
  - HP +5%
  - Attack speed +10%
  - Damage +10%
  - Area +5%
  - Move speed +5%
  - Luck +5%
  - Evasion +4%
- perks — upgrades that can be bought in the shop:
  - "Bring me more" — +5% more enemies
  - "The crazy one" — -2 armor, +%10 attack speed
  - "Getting fatty" — -3% move speed, +1 armor
- skills — not actually attached to the player like weapons. We'll start with just 3 skills:
  - "Heavy Fridge" — A falling fridge from the sky that damages enemies heavily in an area. Random enemy is picked for the fridge to fall on.
    - Falls once per 3 seconds.
    - 60 Damage
    - 60 area of damage
    - each level of upgrade gives + 10% damage and + 5% area. Max upgrades — 6
  - "Wraith of Cooking God" — A cooking God damaging some of the enemies ruthlessly with lightnings
    - Fires once per 6 seconds.
    - 300 Damage
    - 10 area of damage
    - each level of upgrade gives + 10% damage and + 1 more hit. Max upgrades — 5
  - "Garlic Stench" — an aura of terrible garlic stench constantly damaging enemies in an area around the player:
    - Ticks once per 0.2s
    - 10 damage
    - 30 area of damage
    - each level of upgrade gives + 10% faster ticks, +15% area. Max upgrades — 6
- pets/structures/traps — not weapons as well, so they're not attached to the player. We'll start with just a one for each:
  - Nasty Cat (pet) — fights the enemies. Doesn't take any damage from any sources.
    - Attack speed: 1 attack per second.
    - Damage per attack: 40
    - Area of attack: 20
    - Attack range: 10
    - Move speed: 30
  - Bean Shooter (structure) — shoots beans at the nearest enemies. Can't move.
    - Attacks once per 0.5s
    - Damage per attack: 50
    - Area of attack: none (only hits one target)
    - Attack range: 240
    - Move speed: none
  - Banana Mine (trap) — places a banana mine on a random point on the map in a radius 30-240 from the player.
    - Spawns once per 2s
    - 50 damage
    - 40 area of damage
    - each level of upgrade gives + 10% damage, +20% faster spawn rate and + 10% area. Max upgrades — 6

### Stats explanation

**Area** — the radius or distance of effects / weapons. 10 area means the Player's radius. So 20 is the players' diameter. 100 is 5 players' diameters.

**Attack range** — the maximum distance something (weapon/pet/skill and so on) can hit a target. The same size measurements as in the **area**.

**Luck** increases the chance of:
- getting an item in the shop that's already in your inventory (e.g. getting a "Heavy Fridge" upgrade when you already have "Heavy Fridge")
- getting an exp/grease drop

**Evasion** chance of evading an enemy attack (gives the invulnerability just like if the player was hit though but without taking damage)

**Armor** reduces all the damage taken by some %.

**Move speed** — how fast an entity moves. 1 move speed is traveling 1 area per second. So 100 move speed is traveling 100 area per second.

Write some docs for stats explanation. I will modify the text in the future and ask you to update the code accordingly
