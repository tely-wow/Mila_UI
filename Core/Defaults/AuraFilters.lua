local _, MilaUI = ...

-- Initialize defaults table if it doesn't exist
MilaUI.Defaults = MilaUI.Defaults or {}

-- AuraFilters defaults with new ACL-style system
MilaUI.Defaults.AuraFilters = {
    
    -- Available filter rule types and their configurations
    RuleTypes = {
        duration = {
            name = "Duration Filter",
            description = "Filter based on aura duration",
            params = {
                maxDuration = {type = "number", default = 60, min = 1, max = 3600, description = "Maximum duration in seconds"},
                minDuration = {type = "number", default = 0, min = 0, max = 3600, description = "Minimum duration in seconds"}, 
                includePermanent = {type = "boolean", default = true, description = "Include permanent auras (duration = 0)"}
            },
            size = {type = "number", default = 32, min = 8, max = 64, step = 1, description = "Aura size in pixels"}
        },
        spellList = {
            name = "Spell List",
            description = "Filter specific spells by ID (use with Allow/Deny action)",
            params = {
                spellIds = {type = "table", default = {}, description = "List of spell IDs to match"}
            },
            size = {type = "number", default = 32, min = 8, max = 64, step = 1, description = "Aura size in pixels"}
        },
        caster = {
            name = "Caster Filter",
            description = "Filter based on who cast the aura",
            params = {
                player = {type = "boolean", default = false, description = "Show if cast by player"},
                pet = {type = "boolean", default = false, description = "Show if cast by pet"},
                vehicle = {type = "boolean", default = false, description = "Show if cast by vehicle"},
                boss = {type = "boolean", default = false, description = "Show if cast by boss"},
                others = {type = "boolean", default = true, description = "Show if cast by others"}
            },
            size = {type = "number", default = 32, min = 8, max = 64, step = 1, description = "Aura size in pixels"}
        },
        dispellable = {
            name = "Dispellable Filter",
            description = "Filter dispellable auras",
            params = {
                magic = {type = "boolean", default = false, description = "Show Magic dispellable"},
                disease = {type = "boolean", default = false, description = "Show Disease dispellable"},
                poison = {type = "boolean", default = false, description = "Show Poison dispellable"},
                curse = {type = "boolean", default = false, description = "Show Curse dispellable"},
                onlyIfCanDispel = {type = "boolean", default = true, description = "Only show if player can actually dispel"}
            },
            size = {type = "number", default = 32, min = 8, max = 64, step = 1, description = "Aura size in pixels"}
        },
        stealable = {
            name = "Stealable Filter", 
            description = "Filter stealable buffs (mages only)",
            params = {
                onlyIfCanSteal = {type = "boolean", default = true, description = "Only show if player can steal (is mage)"}
            },
            size = {type = "number", default = 32, min = 8, max = 64, step = 1, description = "Aura size in pixels"}
        },
        personal = {
            name = "Personal Auras",
            description = "Show only auras that directly affect the player",
            params = {},
            size = {type = "number", default = 32, min = 8, max = 64, step = 1, description = "Aura size in pixels"}
        },
        boss = {
            name = "Boss Auras",
            description = "Show only auras applied by boss units",
            params = {},
            size = {type = "number", default = 32, min = 8, max = 64, step = 1, description = "Aura size in pixels"}
        },
        noDuration = {
            name = "Permanent Auras",
            description = "Filter permanent auras (no duration)",
            params = {},
            size = {type = "number", default = 32, min = 8, max = 64, step = 1, description = "Aura size in pixels"}
        },
        any = {
            name = "Any/Catch-All",
            description = "Matches any aura - use as final cleanup rule",
            params = {},
            size = {type = "number", default = 32, min = 8, max = 64, step = 1, description = "Aura size in pixels"}
        }
    },
    
    -- Unit filter configurations - each unit has separate buff and debuff filters
    UnitFilters = {
        Player = {
            Buffs = {
                enabled = true,
                rules = {
                    {
                        order = 1,
                        enabled = false,
                        type = "duration",
                        action = "deny",
                        name = "Hide Long Buffs",
                        params = {
                            maxDuration = 60,
                            includePermanent = true
                        },
                        size = 32
                    },
                    {
                        order = 2,
                        enabled = true,
                        type = "spellList",
                        action = "deny",
                        name = "Blocked Buff Spells",
                        params = {
                            spellIds = {}
                        },
                        size = 32
                    },
                    {
                        order = 3,
                        enabled = true,
                        type = "any",
                        action = "allow",
                        name = "Allow Everything Else",
                        params = {},
                        size = 32
                    }
                }
            },
            Debuffs = {
                enabled = true,
                rules = {
                    {
                        order = 1,
                        enabled = true,
                        type = "spellList",
                        action = "deny",
                        name = "Blocked Debuff Spells",
                        params = {
                            spellIds = {}
                        },
                        size = 32
                    },
                    {
                        order = 3,
                        enabled = true,
                        type = "any",
                        action = "allow",
                        name = "Allow Everything Else",
                        params = {},
                        size = 32
                    }
                }
            }
        },
        Target = {
            Buffs = {
                enabled = true,
                rules = {
                    {
                        order = 1,
                        enabled = false,
                        type = "duration",
                        action = "deny",
                        name = "Hide Long Buffs",
                        params = {
                            maxDuration = 60,
                            includePermanent = true
                        },
                        size = 32
                    },
                    {
                        order = 2,
                        enabled = false,
                        type = "caster",
                        action = "allow",
                        name = "Player Cast Only",
                        params = {
                            player = true,
                            pet = false,
                            vehicle = false,
                            boss = false,
                            others = false
                        },
                        size = 32
                    },
                    {
                        order = 3,
                        enabled = false,
                        type = "stealable",
                        action = "allow",
                        name = "Show Stealable",
                        params = {
                            onlyIfCanSteal = true
                        },
                        size = 32
                    },
                    {
                        order = 4,
                        enabled = true,
                        type = "spellList",
                        action = "deny",
                        name = "Blocked Buff Spells",
                        params = {
                            spellIds = {}
                        },
                        size = 32
                    },
                    {
                        order = 3,
                        enabled = true,
                        type = "any",
                        action = "allow",
                        name = "Allow Everything Else",
                        params = {},
                        size = 32
                    }
                }
            },
            Debuffs = {
                enabled = true,
                rules = {
                    {
                        order = 1,
                        enabled = false,
                        type = "caster",
                        action = "allow",
                        name = "Player Cast Only",
                        params = {
                            player = true,
                            pet = true,
                            vehicle = false,
                            boss = false,
                            others = false
                        }
                    },
                    {
                        order = 2,
                        enabled = false,
                        type = "dispellable",
                        action = "allow",
                        name = "Show Dispellable",
                        params = {
                            magic = true,
                            disease = true,
                            poison = true,
                            curse = true,
                            onlyIfCanDispel = true
                        },
                        size = 32
                    },
                    {
                        order = 3,
                        enabled = true,
                        type = "spellList",
                        action = "deny",
                        name = "Blocked Debuff Spells",
                        params = {
                            spellIds = {}
                        },
                        size = 32
                    },
                    {
                        order = 3,
                        enabled = true,
                        type = "any",
                        action = "allow",
                        name = "Allow Everything Else",
                        params = {},
                        size = 32
                    }
                }
            }
        },
        Focus = {
            Buffs = {
                enabled = true,
                rules = {
                    {
                        order = 1,
                        enabled = true,
                        type = "spellList",
                        action = "deny",
                        name = "Blocked Buff Spells",
                        params = {
                            spellIds = {}
                        },
                        size = 32
                    },
                    {
                        order = 3,
                        enabled = true,
                        type = "any",
                        action = "allow",
                        name = "Allow Everything Else",
                        params = {},
                        size = 32
                    }
                }
            },
            Debuffs = {
                enabled = true,
                rules = {
                    {
                        order = 1,
                        enabled = true,
                        type = "spellList",
                        action = "deny",
                        name = "Blocked Debuff Spells",
                        params = {
                            spellIds = {}
                        },
                        size = 32
                    },
                    {
                        order = 3,
                        enabled = true,
                        type = "any",
                        action = "allow",
                        name = "Allow Everything Else",
                        params = {},
                        size = 32
                    }
                }
            }
        },
        Pet = {
            Buffs = {
                enabled = true,
                rules = {
                    {
                        order = 1,
                        enabled = true,
                        type = "duration",
                        action = "deny",
                        name = "Hide Long Buffs",
                        params = {
                            maxDuration = 30,
                            includePermanent = true
                        },
                        size = 32
                    }
                },
                {
                    order = 2,
                    enabled = true,
                    type = "any",
                    action = "allow",
                    name = "Allow Everything Else",
                    params = {},
                    size = 1.0
                }
            },
            Debuffs = {
                enabled = true,
                rules = {
                    {
                        order = 1,
                        enabled = false,
                        type = "dispellable",
                        action = "allow",
                        name = "Show Dispellable",
                        params = {
                            magic = true,
                            disease = true,
                            poison = true,
                            curse = true,
                            onlyIfCanDispel = true
                        }
                    }
                },
                {
                    order = 2,
                    enabled = true,
                    type = "any",
                    action = "allow",
                    name = "Allow Everything Else",
                    params = {},
                    size = 1.0
                }
            }
        },
        TargetTarget = {
            Buffs = {
                enabled = false,
                rules = {
                    {
                        order = 1,
                        enabled = true,
                        type = "any",
                        action = "deny",
                        name = "Hide All",
                        params = {},
                        size = 32
                    }
                }
            },
            Debuffs = {
                enabled = false,
                rules = {
                    {
                        order = 1,
                        enabled = true,
                        type = "any",
                        action = "deny",
                        name = "Hide All",
                        params = {},
                        size = 32
                    }
                }
            }
        },
        FocusTarget = {
            Buffs = {
                enabled = false,
                rules = {
                    {
                        order = 1,
                        enabled = true,
                        type = "any",
                        action = "deny",
                        name = "Hide All",
                        params = {},
                        size = 32
                    }
                }
            },
            Debuffs = {
                enabled = false,
                rules = {
                    {
                        order = 1,
                        enabled = true,
                        type = "any",
                        action = "deny",
                        name = "Hide All",
                        params = {},
                        size = 32
                    }
                }
            }
        },
        Boss = {
            Buffs = {
                enabled = true,
                rules = {
                    {
                        order = 1,
                        enabled = true,
                        type = "caster",
                        action = "allow",
                        name = "Player/Pet Cast Only",
                        params = {
                            player = true,
                            pet = true,
                            vehicle = false,
                            boss = false,
                            others = false
                        }
                    },
                    {
                        order = 2,
                        enabled = true,
                        type = "duration",
                        action = "deny",
                        name = "Hide Long Buffs",
                        params = {
                            maxDuration = 30,
                            includePermanent = true
                        },
                        size = 32
                    },
                    {
                        order = 3,
                        enabled = false,
                        type = "any",
                        action = "deny",
                        name = "Hide Everything Else",
                        params = {}
                    }
                },
                {
                    order = 2,
                    enabled = true,
                    type = "any",
                    action = "allow",
                    name = "Allow Everything Else",
                    params = {},
                    size = 1.0
                }
            },
            Debuffs = {
                enabled = true,
                rules = {
                    {
                        order = 1,
                        enabled = true,
                        type = "caster",
                        action = "allow",
                        name = "Player/Pet Cast Only",
                        params = {
                            player = true,
                            pet = true,
                            vehicle = false,
                            boss = false,
                            others = false
                        }
                    },
                    {
                        order = 2,
                        enabled = false,
                        type = "dispellable",
                        action = "allow",
                        name = "Show Dispellable",
                        params = {
                            magic = true,
                            disease = true,
                            poison = true,
                            curse = true,
                            onlyIfCanDispel = true
                        }
                    }
                },
                {
                    order = 3,
                    enabled = true,
                    type = "any",
                    action = "deny",
                    name = "Hide Everything Else",
                    params = {},
                    size = 1.0
                }
            }
        }
    }
}