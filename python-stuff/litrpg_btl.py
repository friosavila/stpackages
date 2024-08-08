import random
import time

class Character:
    def __init__(self, name, hp, attack, defense, speed):
        self.name = name
        self.hp = hp
        self.max_hp = hp
        self.attack = attack
        self.defense = defense
        self.speed = speed
        self.abilities = []
        self.special_attack_uses = 3

    def add_ability(self, ability):
        self.abilities.append(ability)

    def is_alive(self):
        return self.hp > 0

class Enemy:
    def __init__(self, name, hp, attack, defense, speed):
        self.name = name
        self.hp = hp
        self.max_hp = hp
        self.attack = attack
        self.defense = defense
        self.speed = speed
        self.abilities = []

    def add_ability(self, ability):
        self.abilities.append(ability)

    def is_alive(self):
        return self.hp > 0

class Ability:
    def __init__(self, name, effect, target_type, description):
        self.name = name
        self.effect = effect
        self.target_type = target_type
        self.description = description

def create_characters():
    characters = [
        Character("Aric the Warrior", 120, 18, 12, 8),
        Character("Elara the Mage", 90, 22, 6, 14),
        Character("Thorne the Rogue", 100, 20, 8, 16),
        Character("Lyra the Cleric", 110, 14, 10, 12),
        Character("Gareth the Paladin", 130, 16, 14, 9)
    ]
    
    abilities = [
        Ability("Fireball", lambda target: setattr(target, 'hp', target.hp - 25), "single_enemy", "Hurls a devastating ball of fire"),
        Ability("Divine Heal", lambda target: setattr(target, 'hp', min(target.hp + 40, target.max_hp)), "single_ally", "Channels divine energy to heal wounds"),
        Ability("Venomous Strike", lambda target: setattr(target, 'attack', target.attack - 7), "single_enemy", "Poisons the target, weakening their attacks"),
        Ability("Shield Wall", lambda target: setattr(target, 'defense', target.defense + 8), "self", "Raises a magical barrier, increasing defense"),
        Ability("Battle Cry", lambda target: setattr(target, 'attack', target.attack + 6), "all_allies", "Inspires allies, boosting their attack power")
    ]

    for character in characters:
        character.add_ability(random.choice(abilities))
        character.add_ability(random.choice(abilities))

    return characters

def create_enemies():
    enemies = [
        Enemy("Gruk the Goblin Chieftain", 70, 12, 7, 11),
        Enemy("Morg the Orc Warlord", 100, 17, 10, 8),
        Enemy("Grognak the Troll Berserker", 140, 22, 16, 6),
        Enemy("Vex'ila the Dark Elf Assassin", 85, 20, 8, 14),
        Enemy("Zyrathax the Ancient Dragon", 220, 28, 22, 10)
    ]

    abilities = [
        Ability("Frenzied Assault", lambda target: setattr(target, 'hp', target.hp - 20), "single_enemy", "Launches into a wild, powerful attack"),
        Ability("Terrifying Roar", lambda target: setattr(target, 'attack', target.attack - 4), "all_enemies", "Releases a bone-chilling roar, weakening foes"),
        Ability("Primal Regeneration", lambda target: setattr(target, 'hp', min(target.hp + 30, target.max_hp)), "self", "Rapidly heals wounds"),
        Ability("Inferno Breath", lambda target: setattr(target, 'hp', target.hp - 30), "all_enemies", "Bathes enemies in searing flames"),
        Ability("Shadow Strike", lambda target: setattr(target, 'hp', target.hp - 22), "single_enemy", "Strikes from the shadows with deadly precision")
    ]


    for enemy in enemies:
        enemy.add_ability(random.choice(abilities))

    return enemies

def narrate(message, delay=0):
    print(message)
    time.sleep(delay)

def get_character_action_description(character, action, target=None):
    class_actions = {
        "Warrior": {
            "quick_strike": f"{character.name}'s blade flashes in the sunlight, striking with precision.",
            "power_attack": f"{character.name} channels all their might into a devastating sword swing.",
            "special_attack": f"{character.name} unleashes a whirlwind of steel, their weapon a blur of motion.",
            "defend": f"{character.name} raises their shield, creating an impenetrable wall of defense."
        },
        "Mage": {
            "quick_strike": f"{character.name} weaves a quick spell, sending a bolt of energy towards the enemy.",
            "power_attack": f"{character.name}'s eyes glow with arcane power as they summon a massive spell.",
            "special_attack": f"{character.name} chants in an otherworldly language, reality bending to their will.",
            "defend": f"{character.name} conjures a shimmering barrier of magical energy around themselves."
        },
        "Rogue": {
            "quick_strike": f"{character.name} darts in and out of the shadows, blade glinting.",
            "power_attack": f"{character.name} waits for the perfect moment to strike, then attacks with lethal precision.",
            "special_attack": f"{character.name} vanishes from sight, only to reappear behind their target.",
            "defend": f"{character.name} adopts a nimble stance, ready to dodge incoming attacks."
        },
        "Cleric": {
            "quick_strike": f"{character.name} invokes divine power, smiting the enemy with holy energy.",
            "power_attack": f"{character.name}'s weapon glows with celestial light as they strike.",
            "special_attack": f"{character.name} calls upon their deity, channeling divine wrath.",
            "defend": f"{character.name} is surrounded by a halo of protective light."
        },
        "Paladin": {
            "quick_strike": f"{character.name}'s righteous blade cuts through the air with a holy gleam.",
            "power_attack": f"{character.name} charges forward, their weapon blazing with divine fury.",
            "special_attack": f"{character.name} raises their weapon high, calling down judgment from above.",
            "defend": f"{character.name}'s unwavering faith manifests as an aura of divine protection."
        }
    }

    class_type = character.name.split()[-1]
    return class_actions[class_type][action]

def generate_character_image_prompt(character):
    if isinstance(character, Character):
        class_descriptions = {
            "Warrior": "a muscular human warrior with plate armor and a large sword",
            "Mage": "a robed human mage with a staff, surrounded by magical energy",
            "Rogue": "a nimble human rogue in leather armor with daggers",
            "Cleric": "a human cleric in ornate robes with a holy symbol",
            "Paladin": "a human paladin in shining armor with a sword and shield"
        }
        class_type = character.name.split()[-1]
        return f"Create a fantasy character portrait of {character.name}, {class_descriptions[class_type]}, looking determined and heroic."
    elif isinstance(character, Enemy):
        enemy_descriptions = {
            "Chieftain": "a goblin leader with a cruel and cunning expression",
            "Warlord": "a massive orc with battle scars and a menacing glare",
            "Berserker": "a towering troll with wild eyes and a savage demeanor",
            "Assassin": "a dark elf with a stealthy and deadly appearance",
            "Dragon": "an ancient dragon with scales of steel and fiery breath"
        }
        enemy_type = character.name.split()[-1]
        return f"Create a menacing fantasy monster portrait of {character.name}, {enemy_descriptions[enemy_type]}, looking fierce and threatening."

def get_enemy_action_description(enemy, action):
    enemy_actions = {
        "Goblin": {
            "attack": f"{enemy.name} cackles maniacally, swinging its crude weapon with surprising speed.",
            "special": f"{enemy.name}'s eyes gleam with cunning as it prepares a devious trick."
        },
        "Orc": {
            "attack": f"{enemy.name} roars with bloodlust, bringing its massive weapon to bear.",
            "special": f"{enemy.name}'s muscles bulge as it channels its rage into a powerful attack."
        },
        "Troll": {
            "attack": f"{enemy.name} lumbers forward, its enormous fists ready to crush anything in their path.",
            "special": f"{enemy.name}'s wounds begin to close as its regenerative powers kick in."
        },
        "Dark Elf": {
            "attack": f"{enemy.name} moves with liquid grace, twin blades dancing in a deadly arc.",
            "special": f"{enemy.name} weaves shadows around itself, preparing for a lethal strike."
        },
        "Dragon": {
            "attack": f"{enemy.name}'s ancient eyes blaze with fury as it unleashes its terrifying might.",
            "special": f"{enemy.name}'s scales begin to glow as it summons its legendary power."
        }
    }

    enemy_type = enemy.name.split()[-1]
    return enemy_actions[enemy_type][action]

def get_battle_intensity(round_num, total_combatants, remaining_combatants):
    intensity = min(1.0, (round_num / 10) + (1 - (remaining_combatants / total_combatants)))
    if intensity < 0.3:
        return "The battle begins, tension filling the air."
    elif intensity < 0.6:
        return "The clash of steel and magic echoes across the battlefield as the fight intensifies."
    elif intensity < 0.9:
        return "The very ground trembles beneath the fury of combat, neither side willing to yield."
    else:
        return "With victory hanging in the balance, both sides summon their last reserves of strength for a final, desperate push."

def combat(characters, enemies):
    narrate("The air grows thick with tension as our heroes face their foes...")
    round_num = 1
    total_combatants = len(characters) + len(enemies)

    while any(character.is_alive() for character in characters) and any(enemy.is_alive() for enemy in enemies):
        remaining_combatants = len([c for c in characters if c.is_alive()]) + len([e for e in enemies if e.is_alive()])
        intensity_description = get_battle_intensity(round_num, total_combatants, remaining_combatants)
        narrate(f"\n--- Round {round_num}: {intensity_description} ---")
        
        combatants = sorted(characters + enemies, key=lambda x: x.speed, reverse=True)
        
        for combatant in combatants:
            if isinstance(combatant, Character) and combatant.is_alive():
                narrate(f"\n{combatant.name} stands ready, determination burning in their eyes.")
                print(f"HP: {combatant.hp}/{combatant.max_hp}")
                print("1. Quick Strike (Faster, but weaker)")
                print("2. Power Attack (Slower, but stronger)")
                print(f"3. Special Attack ({combatant.special_attack_uses} uses left)")
                print("4. Defend (Increase defense for this round)")
                
                choice = input("Choose your action (1-4): ")
                
                if choice == "1":
                    target = random.choice([e for e in enemies if e.is_alive()])
                    damage = max(0, int(combatant.attack * 0.8) - target.defense)
                    target.hp -= damage
                    action_desc = get_character_action_description(combatant, "quick_strike")
                    narrate(f"{action_desc} {target.name} takes {damage} damage!")
                elif choice == "2":
                    target = random.choice([e for e in enemies if e.is_alive()])
                    damage = max(0, int(combatant.attack * 1.2) - target.defense)
                    target.hp -= damage
                    action_desc = get_character_action_description(combatant, "power_attack")
                    narrate(f"{action_desc} {target.name} staggers, taking {damage} massive damage!")
                elif choice == "3" and combatant.special_attack_uses > 0:
                    combatant.special_attack_uses -= 1
                    ability = random.choice(combatant.abilities)
                    action_desc = get_character_action_description(combatant, "special_attack")
                    if ability.target_type == "single_enemy":
                        target = random.choice([e for e in enemies if e.is_alive()])
                        ability.effect(target)
                        narrate(f"{action_desc} {combatant.name} uses {ability.name}! {ability.description} against {target.name}!")
                    elif ability.target_type == "all_enemies":
                        for enemy in enemies:
                            if enemy.is_alive():
                                ability.effect(enemy)
                        narrate(f"{action_desc} {combatant.name} uses {ability.name}! {ability.description}, affecting all enemies!")
                    elif ability.target_type in ["single_ally", "all_allies", "self"]:
                        target = combatant if ability.target_type == "self" else random.choice([c for c in characters if c.is_alive()])
                        ability.effect(target)
                        narrate(f"{action_desc} {combatant.name} uses {ability.name}! {ability.description} on {target.name if target != combatant else 'themself'}!")
                elif choice == "4":
                    defense_boost = int(combatant.defense * 0.5)
                    combatant.defense += defense_boost
                    action_desc = get_character_action_description(combatant, "defend")
                    narrate(f"{action_desc} {combatant.name}'s defense increases by {defense_boost}!")
                else:
                    narrate(f"{combatant.name} hesitates, losing their opportunity to act!")
            
            elif isinstance(combatant, Enemy) and combatant.is_alive():
                narrate(f"\n{combatant.name} prepares to strike, malice gleaming in their eyes.")
                if random.random() < 0.7:
                    target = random.choice([c for c in characters if c.is_alive()])
                    damage = max(0, combatant.attack - target.defense)
                    target.hp -= damage
                    action_desc = get_enemy_action_description(combatant, "attack")
                    narrate(f"{action_desc} {target.name} suffers {damage} points of vicious damage!")
                else:
                    ability = random.choice(combatant.abilities)
                    action_desc = get_enemy_action_description(combatant, "special")
                    if ability.target_type == "single_enemy":
                        target = random.choice([c for c in characters if c.is_alive()])
                        ability.effect(target)
                        narrate(f"{action_desc} {combatant.name} uses {ability.name}! {ability.description} against {target.name}!")
                    elif ability.target_type == "all_enemies":
                        for character in characters:
                            if character.is_alive():
                                ability.effect(character)
                        narrate(f"{action_desc} {combatant.name} unleashes {ability.name}! {ability.description}, affecting all heroes!")
                    elif ability.target_type == "self":
                        ability.effect(combatant)
                        narrate(f"{action_desc} {combatant.name} uses {ability.name}! {ability.description}!")
        
        # Reset defense for characters who defended this round
        for character in characters:
            if character.defense > character.max_hp * 0.2:  # Assuming base defense is about 20% of max HP
                character.defense = int(character.max_hp * 0.2)
        
        # Remove defeated enemies and characters
        enemies = [e for e in enemies if e.is_alive()]
        characters = [c for c in characters if c.is_alive()]
        
        round_num += 1

    if any(character.is_alive() for character in characters):
        narrate("\nWith a final, earth-shattering blow, the last enemy falls. Our heroes stand victorious, their courage and skill having overcome the forces of darkness!")
        narrate("The dust settles, revealing the battered but triumphant forms of the survivors. They have written a new chapter in the annals of legend.")
    else:
        narrate("\nAs the final hero falls, a terrible silence descends upon the battlefield. The forces of evil have prevailed, and darkness threatens to engulf the world.")
        narrate("But even in defeat, the heroes' bravery shall be remembered, a beacon of hope for future generations to rekindle the flame of resistance.")


def main():
    narrate("Welcome, brave adventurer, to a world of magic and peril!")
    characters = create_characters()
    enemies = create_enemies()
    
    narrate("\nBehold, our gallant heroes:")
    for character in characters:
        narrate(f"{character.name} - A valiant {character.name.split()[-1]} with {character.hp} HP, {character.attack} Attack, {character.defense} Defense, and {character.speed} Speed.")
        narrate(f"  Special Abilities: {', '.join(ability.name for ability in character.abilities)}")
        print(f"\nImage generation prompt for {character.name}:")
        print(generate_character_image_prompt(character))
        print()
    
    narrate("\nAnd now, face the terrors that await:")
    for enemy in enemies:
        narrate(f"{enemy.name} - A fearsome foe with {enemy.hp} HP, {enemy.attack} Attack, {enemy.defense} Defense, and {enemy.speed} Speed.")
        narrate(f"  Special Ability: {enemy.abilities[0].name}")
        print(f"\nImage generation prompt for {enemy.name}:")
        print(generate_character_image_prompt(enemy))
        print()
    
    input("\nSteel your nerves and press Enter to begin the epic battle...")
    combat(characters, enemies)

if __name__ == "__main__":
    main()