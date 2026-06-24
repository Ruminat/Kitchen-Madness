extends RefCounted

const PLAYER := 1
const ENEMY := 2
const PROJECTILE := 4
const WALL := 8

const PLAYER_MASK := WALL
const ENEMY_MASK := WALL | ENEMY
