# Spec Delta

## Purpose

Defines the autonomous behavior of a stalker wounded by the `wounded` scheme: when it treats itself, when it calls the actor for help, and how long it survives without treatment.

## ADDED Requirements

### Requirement: Delayed heal-or-SOS decision

After an eligible NPC becomes wounded, the scheme SHALL wait a random delay of 5 to 10 game minutes before making a single heal-or-SOS decision for that wound.

#### Scenario: Waiting period

- **WHEN** a non-story, non-protected stalker enters the wounded state
- **THEN** no self-treatment, no SOS SMS and no `map_sos` marker occur before the decision deadline

#### Scenario: Deadline is per wound

- **WHEN** the wounded state ends and the same NPC is wounded again later
- **THEN** a new random deadline is chosen for the new wound

### Requirement: Self-treatment when a medkit is available

At the decision deadline the scheme SHALL let the NPC treat itself when self-treatment is enabled and the NPC carries a `medkit` item, and SHALL NOT send an SOS in that case.

#### Scenario: NPC treats itself

- **WHEN** the decision deadline passes and the NPC has `use_medkit` enabled and a `medkit` item
- **THEN** the NPC consumes the medkit and leaves the wounded state without sending an SMS or adding a map marker

#### Scenario: Only the plain medkit counts

- **WHEN** the decision deadline passes and the NPC has no `medkit` item
- **THEN** the NPC is treated as unable to self-heal, even if other medical items exist

### Requirement: SOS notification when treatment is unavailable

At the decision deadline, if the NPC cannot treat itself, the scheme SHALL send the wounded SOS SMS and add the `map_sos` marker once per wound, except for enemy NPCs.

#### Scenario: Friendly NPC calls for help

- **WHEN** the decision deadline passes, the NPC cannot self-heal, and the NPC is not an enemy of the actor
- **THEN** the scheme sends one SOS SMS with the NPC name and adds one `map_sos` marker

#### Scenario: Enemy NPC stays silent

- **WHEN** the decision deadline passes and the NPC cannot self-heal but is an enemy of the actor
- **THEN** no SOS SMS and no `map_sos` marker are produced for that NPC

#### Scenario: No duplicate notification

- **WHEN** the NPC remains wounded after the SOS was sent
- **THEN** no further SOS SMS or marker is produced for the same wound

### Requirement: Configurable decision delay

The delay range SHALL be read from section `[xr_wounded]` of `config/olr_script_configs.ltx` as `decision_delay_min_minutes` and `decision_delay_max_minutes`, with defaults of 5 and 10 game minutes.

#### Scenario: Configured range is used

- **WHEN** the section defines a valid min and max
- **THEN** each wound receives a random deadline inside that range

#### Scenario: Invalid or missing values fall back

- **WHEN** the keys are missing, non-numeric or the maximum is lower than the minimum
- **THEN** the scheme uses the 5 to 10 game minute defaults

### Requirement: Death timer is independent of the decision delay

The health drain and the death deadline SHALL remain anchored to the wound moment and SHALL NOT be postponed by the decision delay.

#### Scenario: Untreated NPC still dies on schedule

- **WHEN** the NPC never receives treatment
- **THEN** its health drains from the wound moment and it dies at the 2-game-hour deadline

### Requirement: Story and protected NPC exceptions

Story and `olr_protected` NPCs SHALL keep the current behavior: no timer-driven self-treatment, no timer death and no SOS.

#### Scenario: Story NPC is skipped

- **WHEN** a story or protected NPC becomes wounded
- **THEN** the delayed decision, the SOS and the timer death do not apply to it

### Requirement: Deadline survives save and load

The decision deadline SHALL persist across save and load so the decision happens once, at the same time.

#### Scenario: Load during the waiting period

- **WHEN** the player saves and loads a game while a wounded NPC is still waiting for its decision
- **THEN** the NPC keeps the same deadline and produces at most one decision outcome
